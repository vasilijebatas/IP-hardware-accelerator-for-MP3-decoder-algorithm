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
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity roms_tsp is
    Generic(
        WIDTH_D: positive := 16;
        WIDTH_A: positive := 8;
        DEPTH: positive := 145
    );
    Port (
        clk: in std_logic;

        addr_i: in std_logic_vector(WIDTH_A-1 downto 0);
        data_o: out std_logic_vector(WIDTH_D-1 downto 0);

        en: in std_logic
    );
end roms_tsp;

architecture syn of roms_tsp is

    type rom_type is array(DEPTH-1 downto 0) of std_logic_vector(WIDTH_D-1 downto 0);
    signal ROM: rom_type :=(
        x"2D58", x"849C", x"DCEF", x"1363", x"180F", x"2F7A", x"3729", x"4E41",
        x"56CC", x"5E53", x"663B", x"6B93", x"70C4", x"75E6", x"79C0", x"7C98",
        x"7E82", x"7FBE", x"7FBE", x"7E82", x"7C98", x"79C0", x"75E6", x"70C4",
        x"6B93", x"663B", x"5E53", x"56CC", x"4E41", x"3729", x"2F7A", x"180F",
        x"1363", x"DCEF", x"849C", x"2D58", x"2D58", x"849C", x"DCEF", x"1363",
        x"180F", x"2F7A", x"3729", x"4E41", x"56CC", x"5E53", x"663B", x"6B93",
        x"70C4", x"75E6", x"79C0", x"7C98", x"7E82", x"7FBE", x"7FBE", x"7FBE",
        x"7FBE", x"7FBE", x"7FBE", x"7E82", x"75E6", x"663B", x"4E41", x"180F", 
        x"849C", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"849C", 
        x"180F", x"4E41", x"663B", x"6B93", x"7E82", x"7E82", x"6B93", x"663B", 
        x"4E41", x"180F", x"849C", x"0000", x"0000", x"0000", x"0000", x"0000", 
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
        x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
        x"0000", x"0000", x"0000", x"849C", x"180F", x"4E41", x"663B", x"6B93", 
        x"7E82", x"7FFF", x"7FFF", x"7FFF", x"7FFF", x"7FFF", x"7FFF", x"7FBE", 
        x"7E82", x"7C98", x"79C0", x"75E6", x"70C4", x"6B93", x"663B", x"5E53", 
        x"56CC", x"4E41", x"3729", x"2F7A", x"180F", x"1363", x"DCEF", x"849C", 
        x"2D58"
    );
begin
    process(clk)
    begin
        if clk'event and clk = '1' then
            if en = '1' then
                data_o <= ROM(to_integer(unsigned(addr_i)));
            end if;
        end if;
    end process;

end syn;





















