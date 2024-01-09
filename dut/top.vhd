----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2023 05:26:54 PM
-- Design Name: 
-- Module Name: top - Behavioral
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
-- arithmetic functions with unsigned or unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Generic(
        WIDTH_D_SB: positive := 32;
        WIDTH_A_SB: positive := 16;
        DEPTH_SB: positive := 72;

        WIDTH_D_PS: positive := 32;
        WIDTH_A_PS: positive := 16;
        DEPTH_PS: positive := 1152;

        WIDTH_D_SINE: positive := 16;
        WIDTH_A_SINE: positive := 8;
        DEPTH_SINE: positive := 144;
        
        WIDTH_A_COS: positive := 16; 
        WIDTH_D_COS: positive := 16;
        DEPTH_COS: positive := 360
        
    );
    Port (
        top_clk: in std_logic;
        top_reset: in std_logic;

        top_ready: out std_logic;
        top_start: in std_logic;
        top_gr: in std_logic_vector(1 downto 0);
        top_ch: in std_logic_vector(1 downto 0);
        top_block_type: in std_logic_vector(3 downto 0);

        top_addrb: out std_logic_vector(15 downto 0);
        top_doutb: out std_logic_vector(31 downto 0);
        top_dinb: in std_logic_vector(31 downto 0);
        top_en: out std_logic;
        top_web: out std_logic_vector(3 downto 0)
    );
end top;

architecture struct of top is
    signal sine_addr_o_s: std_logic_vector(7 downto 0);
    signal sine_data_i_s: std_logic_vector(15 downto 0);
    signal sine_en_s: std_logic;
    
    signal sb_addr_o_s: std_logic_vector(15 downto 0);
    signal sb_data_i_s: std_logic_vector(31 downto 0);
    signal sb_data_o_s: std_logic_vector(31 downto 0);
    signal sb_en_s: std_logic;
    signal sb_wen_s: std_logic;
    
    signal ps_addr_o_s: std_logic_vector(15 downto 0);
    signal ps_data_i_s: std_logic_vector(31 downto 0);
    signal ps_data_o_s: std_logic_vector(31 downto 0);
    signal ps_en_s: std_logic;
    signal ps_wen_s: std_logic;
    
    signal angle_o_s: std_logic_vector(15 downto 0);
    signal cos_i_s: std_logic_vector(15 downto 0);
    signal cos_en_s: std_logic;

begin

    imdct: entity work.imdct(two_seg_arch)
        port map (
            clk => top_clk,
            reset => top_reset,
            start => top_start,
            gr => top_gr,
            ch => top_ch,
            block_type => top_block_type,

            addrb => top_addrb,
            doutb => top_doutb,
            dinb => top_dinb,
            en => top_en,
            web => top_web,
            
            sine_addr_o => sine_addr_o_s,
            sine_data_i => sine_data_i_s,
            sine_en => sine_en_s,

            sb_addr_o => sb_addr_o_s,
            sb_data_i => sb_data_i_s,
            sb_data_o => sb_data_o_s,
            sb_en => sb_en_s,
            sb_wen => sb_wen_s,

            ps_addr_o => ps_addr_o_s,
            ps_data_i => ps_data_i_s,
            ps_data_o => ps_data_o_s,
            ps_en => ps_en_s,
            ps_wen => ps_wen_s,
            
            angle => angle_o_s,
            cos => cos_i_s,
            cos_en => cos_en_s
        );
        
    ram_sb: entity work.rams_tsp_rf(syn)
    generic map(
        WIDTH_A => WIDTH_A_SB,
        WIDTH_D => WIDTH_D_SB,
        DEPTH => DEPTH_SB
    )
    port map (
        clk => top_clk,
        addr_i => sb_addr_o_s,
        data_i => sb_data_o_s,
        data_o => sb_data_i_s,
        en => sb_en_s,
        we => sb_wen_s
    );  
    
    ram_ps: entity work.rams_tsp_rf(syn)
    generic map(
        WIDTH_A => WIDTH_A_PS,
        WIDTH_D => WIDTH_D_PS,
        DEPTH => DEPTH_PS
    )
    port map (
        clk => top_clk,
        addr_i => ps_addr_o_s,
        data_i => ps_data_o_s,
        data_o => ps_data_i_s,
        en => ps_en_s,
        we => ps_wen_s
    ); 
   
    rom_sine: entity work.roms_tsp(syn)
    generic map(
        WIDTH_A => WIDTH_A_SINE,
        WIDTH_D => WIDTH_D_SINE,
        DEPTH => DEPTH_SINE
    )
    port map (
        clk => top_clk,
        addr_i => sine_addr_o_s,
        data_o => sine_data_i_s,
        en => sine_en_s
    );
    
    rom_cos: entity work.rom_cos(syn)
    generic map(
        WIDTH_A => WIDTH_A_COS,
        WIDTH_D => WIDTH_D_COS,
        DEPTH => DEPTH_COS
    )
    port map (
        clk => top_clk,
        angle => angle_o_s,
        cos => cos_i_s,
        en => cos_en_s
    );



end struct;



















