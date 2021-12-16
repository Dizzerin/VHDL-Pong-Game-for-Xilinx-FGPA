----------------------------------------------------------------------------------
-- Display Logic
----------------------------------------------------------------------------------
--	Caleb Nelson
-- 	12/12/2021
--
-- Description:
-- 	This module is responsible for writing to the Display Driver (which controls
--		the 16x8 LED matrix display.
--		This module currently basically performs a continual raster scan update
--		of the display.  This module doesn't have to do that as the Display Driver
--		module can handle that, but I chose to architect it this way for reasons
--		which can be found in the paper.  Ultimately, this module takes the following
--		inputs:
--			paddle1				--> signal indicating if player 1's paddle is active
--			paddle2				--> signal indicating if player 2's paddle is active
--			current_ball_pos	--> current ball position (column number, 0 is leftmost, 15 is rightmost)
--		and then determines what LED's in the current column should be lit based on
--		those inputs, sends that information on to the Display Driver, and then 
--		increments the current column to the next column
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display_Logic is
    Port ( 	paddle1 : in  STD_LOGIC;
			paddle2 : in  STD_LOGIC;
			mclk : in  STD_LOGIC;
			current_ball_pos : in STD_LOGIC_VECTOR(3 downto 0);
			column_data : out  STD_LOGIC_VECTOR(7 downto 0);
			write_enable : out  STD_LOGIC;
			current_column_out : out  STD_LOGIC_VECTOR(3 downto 0)
		  );
end Display_Logic;

architecture Behavioral of Display_Logic is

	-- Internal signals (of type unsigned so we can do math on them)
	signal next_column: UNSIGNED(3 downto 0);
	signal current_column: UNSIGNED(3 downto 0);

begin
	----------------------------------------------------------------------------
	-- State machine memory
	----------------------------------------------------------------------------
	process(mclk)
	begin
		-- trigger on rising edges
		if (mclk'event and mclk='1') then
			current_column <= next_column;
		end if;
	end process;

	----------------------------------------------------------------------------
	-- Next state logic
	----------------------------------------------------------------------------
	-- Increment Count
	next_column <= current_column+1;
	
	----------------------------------------------------------------------------
	-- Outputs and output logic
	----------------------------------------------------------------------------
	-- Tie write_enable high
	write_enable <= '1';
	
	-- detemine what dots to light in the current column
	column_data <= "00111100" when (((current_column = 0) and paddle1='1') or 
									((current_column = 15) and paddle2='1')) else 				-- display paddles
					"00010000" when (current_ball_pos = STD_LOGIC_VECTOR(current_column)) else	-- display ball in row 4
					"00000000"; 																-- display nothing in that column
						
	-- Casts outputs to STD_LOGIC_VECTOR
	current_column_out <= STD_LOGIC_VECTOR(current_column);

end Behavioral;

