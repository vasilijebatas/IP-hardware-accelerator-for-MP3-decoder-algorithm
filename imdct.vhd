----------------------------------------------------------------------------------
-- Engineer: Milos Nedeljkovic
-- 
-- Create Date: 06/25/2023 01:24:23 PM
-- Design Name: 
-- Module Name: imdct - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity imdct is
    
    Port (
        -- clock and reset interface
        clk: in std_logic;
        reset: in std_logic;

        --register interface
        ready: out std_logic;
        start: in std_logic;
        gr: in std_logic_vector(7 downto 0);
        ch: in std_logic_vector(7 downto 0);
        block_type: in std_logic_vector(3 downto 0);

        --BRAM samples interface
        addrb: out std_logic_vector(15 downto 0);
        doutb: out std_logic_vector(31 downto 0);
        dinb: in std_logic_vector(31 downto 0);
        en: out std_logic;
        web: out std_logic_vector(3 downto 0);

        --ROM sine_block interface
        sine_addr_o: out std_logic_vector(7 downto 0);
        sine_data_i: in std_logic_vector(15 downto 0);
        sine_en: out std_logic;

        --BRAM sample_block interface	
        sb_addr_o: out std_logic_vector(15 downto 0);
        sb_data_i: in std_logic_vector(31 downto 0);
        sb_data_o: out std_logic_vector(31 downto 0);
        sb_en: out std_logic;
        sb_wen: out std_logic;

        --BRAM prev_samples interface
        ps_addr_o: out std_logic_vector(15 downto 0);
        ps_data_i: in std_logic_vector(31 downto 0);
        ps_data_o: out std_logic_vector(31 downto 0);
        ps_en: out std_logic;
        ps_wen: out std_logic
    );
end imdct;

architecture two_seg_arch of imdct is

    attribute use_dsp : string;
    attribute use_dsp of two_seg_arch : architecture is "yes";

    type state_type is (IDLE, INIT_S, INIT_B, WIN_ZERO, I_ZERO, XI_K_ZERO, SB_CAL, WIN_CAL, SB_L1, SB_L2a, SB_L2b, SB_L3a, SB_L3b, SB_L3c, SB_L4a, SB_L4b, SB_L4c, SB_L5a, SB_L5b, SB_L6, J_ZERO, SAM_W, PSAM_W );
    signal state_reg, state_next: state_type;
    signal n_reg, n_next: unsigned(7 downto 0);
    signal n_half_reg, n_half_next: unsigned(7 downto 0);
    signal sample_reg, sample_next: unsigned(9 downto 0);
    signal block_reg, block_next: unsigned(7 downto 0);
    signal win_reg, win_next: unsigned(7 downto 0);
    signal i_reg, i_next: unsigned(7 downto 0);
    signal k_reg, k_next: unsigned(7 downto 0);
    signal xi_reg, xi_next: unsigned(15 downto 0);
    signal m_reg, m_next: unsigned(7 downto 0);
    signal temp_reg, temp_next: unsigned(31 downto 0);
    signal j_reg, j_next: unsigned(7 downto 0);

begin
    -- State and data registers
    process(clk, reset)
    begin
        if (reset = '1') then
            state_reg <= IDLE;
            n_reg <= (others => '0');
            n_half_reg <= (others => '0');
            sample_reg <= (others => '0');
            block_reg <= (others => '0');
            win_reg <= (others => '0');
            i_reg <= (others => '0');
            k_reg <= (others => '0');
            xi_reg <= (others => '0');
            m_reg <= (others => '0');
            temp_reg <= (others => '0');
            j_reg <= (others => '0');

        elsif (clk'event and clk = '1') then
            state_reg <= state_next;
            n_reg <= n_next;
            n_half_reg <= n_half_next;
            sample_reg <= sample_next;
            block_reg <= block_next;
            win_reg <= win_next;
            i_reg <= i_next;
            k_reg <= k_next;
            xi_reg <= xi_next;
            m_reg <= m_next;
            temp_reg <= temp_next;
            j_reg <= j_next;

        end if;
    end process;

    --Combinatorial circuits
    process (state_reg, state_next, start, gr, ch, block_type, dinb, sine_data_i, sb_data_i, ps_data_i, n_half_next, n_half_reg, n_next, n_reg, sample_next, sample_reg, block_next, block_reg, win_reg, win_next, i_next, i_reg, j_next, j_reg, k_next, k_reg, xi_next, xi_reg, m_next, m_reg, temp_next, temp_reg)
    begin


        case state_reg is
            when IDLE =>
                ready <= '1';
                if (start = '1') then
                    if (block_type = "0010") then
                        state_next <= INIT_S;
                    else
                        state_next <= INIT_B;
                    end if;
                else
                    state_next <= IDLE;
                end if;

            when INIT_S =>
                n_next <= to_unsigned(12, n_next'length);
                n_half_next <= to_unsigned(6, n_half_next'length);
                sample_next <= to_unsigned(0, sample_next'length);
                block_next <= to_unsigned(0, block_next'length);

                state_next <= WIN_ZERO;

            when INIT_B =>
                n_next <= to_unsigned(36, n_next'length);
                n_half_next <= to_unsigned(18, n_half_next'length);
                sample_next <= to_unsigned(0, sample_next'length);
                block_next <= to_unsigned(0, block_next'length);

                state_next <= WIN_ZERO;

            when WIN_ZERO =>
                win_next <= to_unsigned(0 ,win_next'length);

                state_next <= I_ZERO;

            when I_ZERO =>
                i_next <= to_unsigned(0,i_next'length);

                state_next <= XI_K_ZERO;

            when XI_K_ZERO =>
                xi_next <= to_unsigned (0,xi_next'length);
                k_next <= to_unsigned (0,k_next'length);

                state_next <= SB_CAL;

            when SB_CAL =>
                addrb <= std_logic_vector(resize((to_unsigned(4, gr'length)* unsigned(gr)) + (to_unsigned(2, ch'length)* unsigned(ch)) + (to_unsigned(18,block_reg'length)*block_reg+n_half_reg*win_reg+k_reg), addrb'length));
                en <= '1';
                web <= std_logic_vector(to_unsigned(0,web'length));
                xi_next <= xi_reg + resize(unsigned(dinb), xi_reg'length); --cosine missing
                k_next <= k_reg + to_unsigned(1,k_reg'length);

                if (k_reg = n_half_reg) then
                    sine_addr_o <= std_logic_vector(resize(to_unsigned(4,block_type'length)*unsigned(block_type),i_reg'length) + i_reg);
                    sb_data_o <= std_logic_vector(resize(xi_reg*unsigned(sine_data_i),sb_data_o'length));
                    sb_addr_o <= std_logic_vector(resize(win_reg*(n_reg + i_reg),sb_addr_o'length));
                    sine_en <= '1';
                    sb_wen <= '1';
                    i_next <= i_reg + to_unsigned(1, i_reg'length);

                    if (i_reg = n_reg) then
                        state_next <= WIN_CAL;
                    else
                        state_next <= XI_K_ZERO;
                    end if;
                else
                    state_next <= SB_CAL;
                end if;

            when WIN_CAL =>
                win_next <= win_reg + to_unsigned(1, win_reg'length);

                if (block_type = "0010") then
                    if (win_reg = to_unsigned(3, win_reg'length)) then
                        if (block_type = "0010") then
                            m_next <= to_unsigned(0,m_next'length);
                            state_next <= SB_L1;
                        else
                            state_next <= J_ZERO;
                        end if;
                    else
                        state_next <= I_ZERO;
                    end if;
                else
                    if (win_reg = to_unsigned(1, win_reg'length)) then
                        if (block_type = "0010") then
                            m_next <= to_unsigned(0,m_next'length);
                            state_next <= SB_L1;
                        else
                            state_next <= J_ZERO;
                        end if;
                    else
                        state_next <= I_ZERO;
                    end if;
                end if;

            when SB_L1 =>
                sb_addr_o <= std_logic_vector(resize(m_reg,sb_addr_o'length));
                sb_data_o <= std_logic_vector(to_unsigned (0,sb_data_o'length));
                sb_en <= '1';
                sb_wen <= '1';

                m_next <= m_reg + to_unsigned(1, m_reg'length);

                if (m_reg = to_unsigned(6,m_reg'length)) then
                    state_next <= SB_L2a;
                else
                    state_next <= SB_L1;
                end if;

            when SB_L2a =>
                sb_addr_o <= std_logic_vector(resize(m_reg - to_unsigned(6,m_reg'length), sb_addr_o'length));
                sb_wen <= '0';
                sb_en <= '1';
                state_next <= SB_L2b;

            when SB_L2b =>
                sb_addr_o <= std_logic_vector(resize(m_reg,sb_addr_o'length));
                sb_data_o <= sb_data_i;
                sb_wen <= '1';
                sb_en <= '1';

                m_next <= m_reg + to_unsigned(1, m_reg'length);

                if (m_reg = to_unsigned(12,m_reg'length)) then
                    state_next <= SB_L3a;
                else
                    state_next <= SB_L2a;
                end if;

            when SB_L3a =>
                sb_addr_o <= std_logic_vector(resize(m_reg - to_unsigned(6,m_reg'length), sb_addr_o'length));
                sb_wen <= '0';
                sb_en <= '1';
                temp_next <= unsigned(sb_data_i);

                state_next <= SB_L3b;

            when SB_L3b =>
                sb_addr_o <= std_logic_vector(resize(m_reg,sb_addr_o'length));
                sb_wen <= '0';
                sb_en <= '1';

                state_next <= SB_L3c;

            when SB_L3c =>
                sb_addr_o <= std_logic_vector(resize(m_reg,sb_addr_o'length));
                sb_data_o <= std_logic_vector(resize(temp_reg + unsigned(sb_data_i), sb_data_o'length));
                sb_wen <= '1';
                sb_en <= '1';

                m_next <= m_reg + to_unsigned(1, m_reg'length);

                if (m_reg = to_unsigned(18,m_reg'length)) then
                    state_next <= SB_L4a;
                else
                    state_next <= SB_L3a;
                end if;

            when SB_L4a =>
                sb_addr_o <= std_logic_vector(resize(m_reg + to_unsigned(6,m_reg'length), sb_addr_o'length));
                sb_wen <= '0';
                sb_en <= '1';

                temp_next <= unsigned(sb_data_i);

                state_next <= SB_L4b;

            when SB_L4b =>
                sb_addr_o <= std_logic_vector(resize(m_reg, sb_addr_o'length));
                sb_wen <= '0';
                sb_en <= '1';

                state_next <= SB_L4c;

            when SB_L4c =>
                sb_addr_o <= std_logic_vector(resize(m_reg,sb_addr_o'length));
                sb_data_o <= std_logic_vector(resize(temp_reg + unsigned(sb_data_i), sb_data_o'length));
                sb_wen <= '1';
                sb_en <= '1';

                m_next <= m_reg + to_unsigned(1, m_reg'length);

                if (m_reg = to_unsigned(24,m_reg'length)) then
                    state_next <= SB_L5a;
                else
                    state_next <= SB_L4a;
                end if;

            when SB_L5a =>
                sb_addr_o <= std_logic_vector(resize(m_reg + to_unsigned(6,m_reg'length),sb_addr_o'length));
                sb_wen <= '0';
                sb_en <= '1';

                state_next <= SB_L5a;

            when SB_L5b =>
                sb_addr_o <= std_logic_vector(resize(m_reg, sb_addr_o'length));
                sb_data_o <= sb_data_i;
                sb_wen <= '1';
                sb_en <= '1';

                m_next <= m_reg + to_unsigned(1, m_reg'length);

                if (m_reg = to_unsigned(30,m_reg'length)) then
                    state_next <= SB_L6;
                else
                    state_next <= SB_L5a;
                end if;

            when SB_L6 =>
                sb_addr_o <= std_logic_vector(resize(m_reg,sb_addr_o'length));
                sb_data_o <= std_logic_vector(to_unsigned(0, sb_data_o'length));
                sb_wen <= '1';
                sb_en <= '1';

                m_next <= m_reg + to_unsigned(1, m_reg'length);

                if (m_reg = to_unsigned(36,m_reg'length)) then
                    state_next <= J_ZERO;
                else
                    state_next <= SB_L6;
                end if;

            when J_ZERO =>
                j_next <= to_unsigned(0, j_next'length);

                state_next	<= SAM_W;

            when SAM_W =>
                sb_addr_o <= std_logic_vector(resize(j_reg, sb_addr_o'length));
                sb_wen <= '0';
                sb_en <= '1';

                ps_addr_o <= std_logic_vector(resize((to_unsigned(64, ch'length)*unsigned(ch)) + (to_unsigned(32, block_reg'length)*block_reg) + resize(j_reg,2*(j_reg'length)), ps_addr_o'length));

                addrb <= std_logic_vector(resize((to_unsigned(4,gr'length)*unsigned(gr)) + (to_unsigned(2, ch'length)*unsigned(ch)) + resize(sample_reg + resize(j_reg, sample_reg'length),2*(ch'length)), addrb'length));
                doutb <= std_logic_vector(unsigned(ps_data_i) + unsigned(sb_data_i));
                web <= std_logic_vector(to_unsigned(1,web'length));

                state_next <= PSAM_W;

            when PSAM_W =>
                sb_addr_o <= std_logic_vector(resize(to_unsigned(18,j_reg'length) + j_reg, sb_addr_o'length));
                sb_wen <= '0';
                sb_en <= '1';

                ps_addr_o <= std_logic_vector(resize((to_unsigned(64,gr'length)*unsigned(gr)) + (to_unsigned(32,block_reg'length)*block_reg) + resize(j_reg, 2*(j_reg'length)), ps_addr_o'length));
                ps_data_o <= sb_data_i;
                ps_wen <= '1';
                ps_en <= '1';

                j_next <= j_reg + to_unsigned(1, j_reg'length);

                if (j_reg = to_unsigned(18 ,j_reg'length)) then
                    sample_next <= sample_reg + to_unsigned(18, sample_reg'length);
                    block_next <= block_reg + to_unsigned(1, block_reg'length);
                    if (block_reg = to_unsigned(32,block_reg'length)) then
                        state_next <= IDLE;
                    else
                        state_next <= WIN_ZERO;
                    end if;
                else
                    state_next <= SAM_W;
                end if;
        end case;
    end process;
end two_seg_arch;




















