----------------------------------------------------------------------------------
-- Score Manager
----------------------------------------------------------------------------------
--	Caleb Nelson
-- 	12/12/2021
--
-- Description:
-- 	This module is responsible for keeping track of the 2 player's scores
--		It has 5 main inputs:
--			score_pulse1		--> signal to indicate player 1 has scored a point
--			score_pulse2		--> signal to indicate player 2 has scored a point
--			score1_reset		--> signal to reset player 1's score
--			score2_reset		--> signal to reset player 2's score
--			current_ball_pos	--> current ball position (column number, 0 is leftmost, 15 is rightmost)
--		And provides 4 main outputs:
--			max_pulse1			--> pulse to indicate when player 1 has reached the max score (won)
--			max_pulse2			--> pulse to indicate when player 2 has reached the max score (won)
--			score1				--> player 1's score (4 bits)
--			score2				--> player 2's score (4 bits)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Score_Manager is
    Port ( 	clk : in  STD_LOGIC;
			current_ball_pos : in  STD_LOGIC_VECTOR (3 downto 0);
			score1_reset : in  STD_LOGIC;
			score2_reset : in  STD_LOGIC;
			score_pulse1 : in  STD_LOGIC;
			score_pulse2 : in  STD_LOGIC;
			max_pulse1 : out  STD_LOGIC;
			max_pulse2 : out  STD_LOGIC; 
			score1 : out  STD_LOGIC_VECTOR (3 downto 0);
			score2 : out  STD_LOGIC_VECTOR (3 downto 0)
		 );
end Score_Manager;

architecture Behavioral of Score_Manager is
	-- Signals
	-- Unsigned type to allow incrementing
	signal current_score1, next_score1 : UNSIGNED(3 downto 0);
	signal current_score2, next_score2 : UNSIGNED(3 downto 0);

begin
	----------------------------------------------------------------------------
	-- State machine memory
	----------------------------------------------------------------------------
	process(clk)
	begin
		-- trigger on rising edges
		if (clk'event and clk='1') then
			current_score1 <= next_score1;
			current_score2 <= next_score2;
		end if;
	end process;

	----------------------------------------------------------------------------
	-- Next state logic
	----------------------------------------------------------------------------
	next_score1 <= 	"0000" when (score1_reset='1') else					-- asynch reset (could also do synchronous but it doesn't matter)
					"1001" when (current_score1=9) else					-- hold max value
					current_score1+1 when (score_pulse1='1') else		-- increment value
					current_score1;										-- hold current value
	
	next_score2 <= 	"0000" when (score2_reset='1') else					-- asynch reset (could also do synchronous but it doesn't matter)
					"1001" when (current_score2=9) else					-- hold max value
					current_score2+1 when (score_pulse2='1') else		-- increment value
					current_score2;										-- hold current value
	
	----------------------------------------------------------------------------
	-- Outputs and output logic
	----------------------------------------------------------------------------
	-- scores -- (cast output to standard logic vector type)
	score1 <= STD_LOGIC_VECTOR(current_score1);
	score2 <= STD_LOGIC_VECTOR(current_score2);
	
	-- max score pulses
	max_pulse1 <= 	'1' when (current_score1=9) else
					'0';
	max_pulse2 <= 	'1' when (current_score2=9) else
					'0';
					
end Behavioral;

