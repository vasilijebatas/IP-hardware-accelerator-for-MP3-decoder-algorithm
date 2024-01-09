----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2023 04:13:28 PM
-- Design Name: 
-- Module Name: RAM - Behavioral
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

entity rams_tsp_rf is
    Generic(
        WIDTH_D: positive;
        WIDTH_A: positive;
        DEPTH: positive   
    );
    Port ( 
        clk: in std_logic;
        
        addr_i: in std_logic_vector(WIDTH_A-1 downto 0);
        data_o: out std_logic_vector(WIDTH_D-1 downto 0);
        data_i: in std_logic_vector(WIDTH_D-1 downto 0);
        
        en: in std_logic;
        we: in std_logic
    );
end rams_tsp_rf;

architecture syn of rams_tsp_rf is
    
    type ram_type is array(DEPTH-1 downto 0) of std_logic_vector(WIDTH_D-1 downto 0);
    signal RAM : ram_type := (others => (others => '0'));

begin
    process(clk)
    begin
        if clk'event and clk = '1' then
            if en = '1' then
                data_o <= RAM(to_integer(unsigned(addr_i)));
                if we = '1' then
                    RAM(to_integer(unsigned(addr_i))) <= data_i;
                end if;
            end if;
        end if;
    end process;

end syn;





















