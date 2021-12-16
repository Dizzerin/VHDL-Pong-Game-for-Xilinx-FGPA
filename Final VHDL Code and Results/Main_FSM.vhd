----------------------------------------------------------------------------------
-- Main FSM
----------------------------------------------------------------------------------
--	Caleb Nelson
--	12/12/2021
--
-- Description:
-- 	This is the game's main finite state machine.  It controls the overall game
-- 	mechanics and progression between 6 states.
--		The states are:
--			Initial state
--			Ball moving left state
--			Ball moving right state
--			Player 1 has scored state
--			Player 2 has scored state
--			Game over state
-- 	The primary outputs are:
--			SS_reset					--> signal to reset the game's speed setting
--			score_pulse1_out			--> signal to indicate player 1 has scored a point
--			score_pulse2_out			--> signal to indicate player 2 has scored a point
--			score1_reset				--> signal to reset player 1's score
--			score2_reset				--> signal to reset player 2's score
--			current_ball_pos_out		--> current ball position (column number, 0 is leftmost, 15 is rightmost)
--			SH_count					--> successful hit count
--			SH_pulse					--> successful hit pulse
--		For more information on the outputs, logic, and state diagrams etc. see the
--		write up or read the code.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Main_FSM is
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			start : in  STD_LOGIC;
			paddle1 : in  STD_LOGIC;
			paddle2 : in  STD_LOGIC;
			score1 : in  STD_LOGIC_VECTOR(3 downto 0);
			score2 : in  STD_LOGIC_VECTOR(3 downto 0);
			max_pulse1 : in  STD_LOGIC;
			max_pulse2 : in  STD_LOGIC;
			score_pulse1_out : out STD_LOGIC;
			score_pulse2_out : out  STD_LOGIC;
			SS_reset : out  STD_LOGIC;
			score1_reset : out  STD_LOGIC;
			score2_reset : out  STD_LOGIC;
			current_ball_pos_out : out  STD_LOGIC_VECTOR(3 downto 0);
			SH_count : out  STD_LOGIC_VECTOR(7 downto 0);
			SH_pulse : out STD_LOGIC
		  );
end Main_FSM;

architecture Behavioral of Main_FSM is
	-- Custom state types
	type main_FSM_state_type is (	MFSM_state_INIT,
									MFSM_state_MR,
									MFSM_state_ML,
									MFSM_state_P1SC,
									MFSM_state_P2SC,
									MFSM_state_GMVR
								);
	-- Internal signals
	signal current_state: main_FSM_state_type := MFSM_state_INIT;
	signal next_state: main_FSM_state_type := MFSM_state_INIT;
	signal return1, return2: STD_LOGIC;
	signal score_pulse1, score_pulse2 : STD_LOGIC;	-- Note these are used internally, the _out versions are outputs
	-- Unsigned types (to support math operations)
	signal current_ball_pos : UNSIGNED(3 downto 0) := "1110"; 	-- Default to 14th column on powerup
	signal next_ball_pos: UNSIGNED(3 downto 0) := "1110";		-- Default to 14th column on powerup
	signal current_SH_count, next_SH_count : UNSIGNED(7 downto 0) := (others=>'0');


begin
	----------------------------------------------------------------------------
	-- State machine memory
	----------------------------------------------------------------------------
	process(clk)
	begin
		-- trigger on rising edges
		if (clk'event and clk='1') then
			current_state <= next_state;
			current_ball_pos <= next_ball_pos;
			current_SH_count <= next_SH_count;
		end if;
	end process;

	----------------------------------------------------------------------------
	-- Next state logic
	----------------------------------------------------------------------------
	process(current_state, start, reset, return1, return2, score_pulse1, score_pulse2, max_pulse1, max_pulse1)
	begin
		case current_state is 
			when MFSM_state_INIT =>
				if(start = '1') then
					next_state <= MFSM_state_ML;
				else
					next_state <= current_state;
				end if;
			when MFSM_state_ML =>
				if(score_pulse2 = '1') then
					next_state <= MFSM_state_P2SC;
				elsif (return1 = '1') then
					next_state <= MFSM_state_MR;
				else
					next_state <= current_state;
				end if;
			when MFSM_state_MR =>
				if(score_pulse1 = '1') then
					next_state <= MFSM_state_P1SC;
				elsif (return2 = '1') then
					next_state <= MFSM_state_ML;
				else
					next_state <= current_state;
				end if;
			when MFSM_state_P1SC =>
				if (max_pulse1 = '1') then
					next_state <= MFSM_state_GMVR;
				elsif(start = '1') then
					next_state <= MFSM_state_MR;
				else
					next_state <= current_state;
				end if;
			when MFSM_state_P2SC =>
				if (max_pulse2 = '1') then
					next_state <= MFSM_state_GMVR;
				elsif(start = '1') then
					next_state <= MFSM_state_ML;
				else
					next_state <= current_state;
				end if;
			when MFSM_state_GMVR =>
				if(reset = '1') then
					next_state <= MFSM_state_INIT;
				else
					next_state <= current_state;
				end if;
		end case;
	end process;
			
	----------------------------------------------------------------------------
	-- Outputs and output logic
	----------------------------------------------------------------------------
	-- Basic renamed/type cast outputs
	current_ball_pos_out <= STD_LOGIC_VECTOR(current_ball_pos);
	SH_count <= STD_LOGIC_VECTOR(current_SH_count);
	-- Map score_pulse outputs
	-- (have to rename them so they could be used internally as well)
	score_pulse1_out <= score_pulse1;
	score_pulse2_out <= score_pulse2;
	
	-- Current state specific output assignment
	process(current_state, clk)
	begin
		-- All output defaults
		next_ball_pos 	<= current_ball_pos;	-- Maintain current ball position
		next_SH_count 	<= current_SH_count;	-- Maintain current successful hit count
		SH_pulse 		<= '0';					-- Default no successful hit
		SS_reset 		<= '0';					-- Don't reset speed setting
		score1_reset 	<= '0';					-- Don't reset player 1's score
		score2_reset 	<= '0';					-- Don't reset player 1's score
		score_pulse1 	<= '0';					-- Player 1 isn't always scoring...
		score_pulse2 	<= '0';					-- Player 2 isn't always scoring...
		return1			<= '0';					-- Player 1 is not returning the ball
		return2 		<= '0';					-- Player 2 is not returning the ball
		
		-- Assign state dependent ouputs
		case current_state is
			when MFSM_state_INIT =>
				-- Reset all necessary counters/scores/and settings
				next_SH_count <= (others=>'0');		
				SS_reset <= '1';		
				score1_reset <= '1';
				score2_reset <= '1';
				
			when MFSM_state_ML =>
				-- Update ball position
				next_ball_pos <= current_ball_pos-1; 	-- move ball left
				
				-- If the ball is in the column in front of player 1's paddle....
				if (current_ball_pos = "0001") then
					-- And if player 1's paddle is active...
					if (paddle1='1') then
						return1 <= '1';							-- Player 1 successfully returned the ball
						next_SH_count <= current_SH_count+1;	-- Increment successful hit count
						SH_pulse <= '1';						-- Generate successful hit pulse
					-- else player 1 failed to return the ball so...
					else
						score_pulse2 <= '1';	-- Player 2 scores because player 1's paddle is not active
					end if;
				end if;
				
			when MFSM_state_MR =>
				-- Update ball position
				next_ball_pos <= current_ball_pos+1; -- move ball right
				
				-- If the ball is in the column in front of player 2's paddle....
				if (current_ball_pos = "1110") then
					-- And if player 2's paddle is active...
					if (paddle2='1') then
						return2 <= '1';							-- Player 2 successfully returned the ball
						next_SH_count <= current_SH_count+1;	-- Increment successful hit count
						SH_pulse <= '1';						-- Generate successful hit pulse
					-- else player 2 failed to return the ball so...
					else
						score_pulse1 <= '1';	-- Player 1 scores because player 2's paddle is not active
					end if;
				end if;
				
			when MFSM_state_P1SC =>
				next_ball_pos <= "0001"; -- set ball position to column 1 when player 1 scores
				
			when MFSM_state_P2SC =>
				next_ball_pos <= "1110"; -- set ball position to column 14 when player 2 scores
	
			when MFSM_state_GMVR =>
				-- Reset successful hits count, speed setting, and ball position
				next_SH_count <= (others=>'0');
				next_ball_pos <= "1110"; -- start on right
				SS_reset <= '1';
				
		end case;
	end process;
	
	----------------------------------------------------------------------------
	-- OLD METHOD (without process statement)
	----------------------------------------------------------------------------
--	-- (Optional add:) Assert proper winner signal when appropriate
--	winner1 <= '1' when (score1=9)else
--				  '0';
--	winner2 <= '1' when (score2=9)else
--				  '0';
--	
--	-- Reset successful hit count in INIT state
--	SHC_reset <= '1' when (current_state=MFSM_state_INIT)else
--					 '0';
--	-- Reset speed setting when in INIT state
--	SS_reset <= '1' when (current_state=MFSM_state_INIT)else
--					'0';
--   -- Reset score 1 when in INIT state
--	score1_reset <= '1' when (current_state=MFSM_state_INIT)else
--						 '0';
--   -- Reset score 2 when in INIT state
--	score2_reset <= '1' when (current_state=MFSM_state_INIT)else
--						 '0';
--
--	next_ball_pos <= (current_ball_pos+1) when (current_state=MFSM_state_MR) else -- move ball right
--						  (current_ball_pos-1) when (current_state=MFSM_state_ML) else	-- move ball left
--						  "0001" when (current_state=MFSM_state_P1SC) else					-- set to column 1 when player 1 scores
--						  "1110";																		-- default to column 14 (includes case when player 2 scores)
--		
--	-- player 1 scores if the ball is in the column in front of the opposing player's paddle and their paddle is not active
--	-- (equivalent to if their opponent doesn't return it) and the current state is -- ball moving right -- 
--	score_pulse1 <= 	'1' when ((current_ball_pos = "1110") and (paddle2='0') and (current_state=MFSM_state_MR)) else
--							'0';
--	-- player 2 scores if the ball is in the column in front of the opposing player's paddle and their paddle is not active
--	-- (equivalent to if their opponent doesn't return it) and the current state is -- ball moving left -- 
--	score_pulse2 <= 	'1' when ((current_ball_pos = "0001") and (paddle1='0') and (current_state=MFSM_state_ML)) else
--							'0';
--
--	-- player 1 succesffully returned the ball if their paddle is active when the ball is in the column in front of it
--	return1 <= 	'1' when ((current_ball_pos = "0001") and (paddle1='1')) else
--					'0';
--	-- player 2 succesffully returned the ball if their paddle is active when the ball is in the column in front of it
--	return2 <= 	'1' when ((current_ball_pos = "1110") and (paddle2='1')) else
--					'0';
--
--	-- With asynchronous reset
--	next_SH_count <= 	0 when (SHC_reset='1') else
--							current_SH_count+1 when (((return1='1') or (return2='1'))) else
--							current_SH_count;
--
--	-- With synchronous reset (implemented in process)
--	next_SH_count <= 	current_SH_count+1 when (((return1='1') or (return2='1'))) else
--							current_SH_count;
					
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------

end Behavioral;

