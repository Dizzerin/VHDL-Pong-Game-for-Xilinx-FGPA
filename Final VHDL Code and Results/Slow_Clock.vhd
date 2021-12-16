----------------------------------------------------------------------------------
-- Slow Clock Generator
----------------------------------------------------------------------------------
--	Caleb Nelson
-- 	12/12/2021
--
-- Description:
-- 	This module is responsible for generating a slow square wave clock signal
--		as setup, it generates a 500Hz clock signal and is used by the Score Display Manager
-- 	for muxing between the digits in the 4 digit, 7-segment display
----------------------------------------------------------------------------------
library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use UNISIM.VComponents.all;  -- allow instantiating Xilinx primitives in this code

entity Slow_Clock is
    Port ( mclk : in  STD_LOGIC;
           slow_clock : out  STD_LOGIC
		 );
end Slow_Clock;

architecture Behavioral of Slow_Clock is
	-- signals
	signal clk_next, clk_reg : unsigned(16 downto 0);
	signal t_next, t_reg : std_logic;

begin
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--      Derived Clock generator.  Generates square waves
	--      As shown, if mclk is 50 Mhz, t_reg and slow_clock are 500 Hz
	--		essentially just divides the clock by 100,000
	---------------- clock generator -------------------------------------------
	----------------------------------------------------------------------------
	process(mclk)
	begin
		 -- trigger on rising edges
		 if (mclk'event and mclk='1') then
			  clk_reg <= clk_next;
			  t_reg <= t_next;     --  T-f/f register
		 end if;
	end process;

	clk_next <= (others=>'0') when clk_reg=49999 else clk_reg+1;
	t_next <= (not t_reg) when clk_reg = 49999 else t_reg;

	Clk_Buffer: BUFG                   -- Put t_reg on a buffered clock line
		 port map ( I => t_reg, O => slow_clock);
		 -- slow_clock is a square wave with 500 Hz frequency
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------

end Behavioral;

