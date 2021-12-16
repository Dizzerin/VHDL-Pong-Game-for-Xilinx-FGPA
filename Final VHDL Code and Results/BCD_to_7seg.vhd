----------------------------------------------------------------------------------
-- Company:       Walla Walla University
-- Engineer:      L.Aamodt
-- 
-- Create Date:   16:42:06 10/13/2020 
-- Design Name:   Binary to 7-segment decoder
-- Module Name:   bcd2_7seg - Behavioral 
-- Project Name: 
--
-- Description:   Converts 4-bit binary representing one BCD digit
--                  to 7-segment display encoding
-- Dependencies:  WWU FPGA3 board
--
-- Revision: 
-- Revision 1.0 - File Created
-- Additional Comments:
--   Cathode signals asserted low to turn on the segment.
--   The cathode that controls the decimal point is always turned off.
--   Segment a of the display is cath_out(0) and segment g is cath_out(6).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd2_7seg is
    port ( data : in  STD_LOGIC_VECTOR (3 downto 0);
           cath_out : out  STD_LOGIC_VECTOR (7 downto 0)
		 );
end bcd2_7seg;

architecture Behavioral of bcd2_7seg is

begin
    process(data)
    begin
        case data is
            when "0000" => cath_out <= "11000000";
            when "0001" => cath_out <= "11111001";
            when "0010" => cath_out <= "10100100";
            when "0011" => cath_out <= "10110000";
            when "0100" => cath_out <= "10011001";
            when "0101" => cath_out <= "10010010";
            when "0110" => cath_out <= "10000010";
            when "0111" => cath_out <= "11111000";
            when "1000" => cath_out <= "10000000";
            when "1001" => cath_out <= "10011000";
            when others => cath_out <= "10000110";			
        end case;
    end process;
end Behavioral;
