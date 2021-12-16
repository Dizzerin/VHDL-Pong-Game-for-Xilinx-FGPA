----------------------------------------------------------------------------------
-- Game Clock Manager
----------------------------------------------------------------------------------
--	Caleb Nelson
-- 	12/12/2021
--
-- Description:
--		This module is a clock divider which takes mclk and divides it down to create
--		a slower clk_out signal.
--		The clk_out signal can be one of 16 speeds.  The speed selection is determined by
--		SS_reset (speed setting reset) and SH_count (successful hits count)
--		The speed setting is increment by 1 every other successful hit.
----------------------------------------------------------------------------------
library IEEE;
library UNISIM;  			-- for Xilinx primitives
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use UNISIM.VComponents.all;	-- for Xilinx primitives like special clock lines

entity Game_Clock_Manager is
    Port( 	mclk : in  STD_LOGIC;
			SH_count : in  STD_LOGIC_VECTOR(7 downto 0);
			SH_pulse : in STD_LOGIC;
			SS_reset : in  STD_LOGIC;
			clk_out : out  STD_LOGIC;
			led : out STD_LOGIC_VECTOR(15 downto 8)
		);
end Game_Clock_Manager;

architecture Behavioral of Game_Clock_Manager is
	-- Signals
	signal count : UNSIGNED(22 downto 0);
	signal clk_next, clk_reg : UNSIGNED(22 downto 0);
	signal t_next, t_reg : STD_LOGIC;
	
	-- speed signals
	signal current_speed_setting, next_speed_setting: UNSIGNED(3 downto 0);

begin
	
	-- Display speed setting info on upper 8 LED's
	led(15 downto 12) <= STD_LOGIC_VECTOR(current_speed_setting);
	led(11 downto 8) <= STD_LOGIC_VECTOR(next_speed_setting);
	
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--    Derived Clock generator.  Generates square waves
	--		Note: mclk is 50 Mhz
	--		slow_clock = mclk/(2*(count+1))
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	process(mclk)
	begin
		 -- trigger on rising edges of mclk
		 if (mclk'event and mclk='1') then
			  clk_reg <= clk_next;
			  t_reg <= t_next;
		 end if;
	end process;

	clk_next <= (others=>'0') when clk_reg=count else clk_reg+1;
	t_next <= (not t_reg) when clk_reg=count else t_reg;

	-- Put t_reg on a buffered clock line
	Clk_Buffer: BUFG
		port map ( I => t_reg, O => clk_out);
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	
	----------------------------------------------------------------------------
	-- State machine memory for speed setting counter
	----------------------------------------------------------------------------
	process(SH_pulse, SS_reset)
	begin
		-- Reset
		-- 	Note this is in the sensitivity list becuase it needs to reset even when
		--		there are no successful hit pulses
		if (SS_reset='1') then
			current_speed_setting <= "0000";
		-- trigger on rising edges of the successful hit pulse
		-- (update speed every time a hit is successful)
		elsif (SH_pulse'event and SH_pulse='1') then
			current_speed_setting <= next_speed_setting;
		end if;
	end process;
	--------------------------------------------------------------------------
	-- Next state logic for speed setting counter
	--------------------------------------------------------------------------
	-- Set next speed setting
	next_speed_setting <= 	"1111" when (current_speed_setting=15) else 		-- hold max value
							current_speed_setting+1 when (SH_count(0)='1') else	-- increment on first hit and then every other successful hit (when count is odd)
							current_speed_setting;								-- hold current value

	----------------------------------------------------------------------------
	-- current speed setting is used by the clock generator to set the derived clock speed
	----------------------------------------------------------------------------
	-- Set clock divider
	with current_speed_setting select
		count <= 	to_unsigned(4999999, 23) when to_unsigned(0, 4), 	-- 5Hz (starting rate)
					to_unsigned(3124999, 23) when to_unsigned(1, 4), 	-- 8Hz
					to_unsigned(2272726, 23) when to_unsigned(2, 4),	-- 11Hz
					to_unsigned(1785713, 23) when to_unsigned(3, 4), 	-- 14Hz
					to_unsigned(1470587, 23) when to_unsigned(4, 4), 	-- 17Hz
					to_unsigned(1249999, 23) when to_unsigned(5, 4), 	-- 20Hz
					to_unsigned(1086955, 23) when to_unsigned(6, 4), 	-- 23Hz
					to_unsigned(961537, 23) when to_unsigned(7, 4), 	-- 26Hz
					to_unsigned(862068, 23) when to_unsigned(8, 4), 	-- 29Hz
					to_unsigned(781249, 23) when to_unsigned(9, 4), 	-- 32Hz
					to_unsigned(714284, 23) when to_unsigned(10, 4), 	-- 35Hz
					to_unsigned(657894, 23) when to_unsigned(11, 4), 	-- 38Hz
					to_unsigned(609755, 23) when to_unsigned(12, 4), 	-- 41Hz
					to_unsigned(568180, 23) when to_unsigned(13, 4), 	-- 44Hz
					to_unsigned(531915, 23) when to_unsigned(14, 4), 	-- 47Hz
					to_unsigned(499999, 23) when others;				-- 50Hz (max rate)

end Behavioral;