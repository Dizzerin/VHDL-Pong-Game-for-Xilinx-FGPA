----------------------------------------------------------------------------------
-- Company: 		Walla Walla University
-- Engineer:		Caleb Nelson
-- 
-- Completion Date:    	12/12/2021
-- Project Name: 	 	Display_Driver
-- Target Devices: 	 	Xilinx Artix 7 XC7A100T FGG676
-- Tool versions:	 	ISE 14.7
-- Description: 	 
--		Simple Rendition of the classic arcade game Pong for ENGR 433
-- 		(See final written report for more detailed description)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Project_Top is
    Port ( 	sw : in  STD_LOGIC_VECTOR (12 downto 9);
			anode : out  STD_LOGIC_VECTOR (4 downto 0);
			cath : out  STD_LOGIC_VECTOR (7 downto 0);
			extout : out  STD_LOGIC_VECTOR (7 downto 0);
			mclk: in STD_LOGIC;
			led : out STD_LOGIC_VECTOR (15 downto 0)
		 );
end Project_Top;

architecture Behavioral of Project_Top is
	-- Input Signals
	signal paddle1: STD_LOGIC;
	signal paddle2: STD_LOGIC;
	signal start: STD_LOGIC;
	signal reset: STD_LOGIC;
	
	-- Main FSM Signals
	signal score1 : STD_LOGIC_VECTOR(3 downto 0);
	signal score2 : STD_LOGIC_VECTOR(3 downto 0);
	signal score_pulse1 : STD_LOGIC;
	signal score_pulse2 : STD_LOGIC;
	signal max_pulse1 : STD_LOGIC;
	signal max_pulse2 : STD_LOGIC;
	signal SS_reset : STD_LOGIC;
	signal score1_reset : STD_LOGIC;
	signal score2_reset : STD_LOGIC;
	signal current_ball_pos: STD_LOGIC_VECTOR(3 downto 0) := "1110";	-- Default to 14th column on powerup
	signal SH_count : STD_LOGIC_VECTOR (7 downto 0);
	signal SH_pulse : STD_LOGIC;
	
	-- Display Signals
	signal column_data: STD_LOGIC_VECTOR(7 downto 0);
	signal write_enable: STD_LOGIC;
	signal current_column: STD_LOGIC_VECTOR(3 downto 0);
	
	-- Clock Signals
	signal clk : STD_LOGIC;
	signal slow_clock : STD_LOGIC;
	
begin
	-- Display the current successful hits count on the lower 8 LED's
	led(7 downto 0) <= SH_count;
	
	-- Map input signals
	paddle1 <= not(sw(10));
	paddle2 <= not(sw(12));
	start <= not(sw(11));
	reset <= not(sw(9));
	
	-- Components
	GAME_CLOCK_MANAGER: entity work.Game_Clock_Manager port map (
		mclk => mclk,
		clk_out => clk,
		SH_count => SH_count,
		SH_pulse => SH_pulse,
		SS_reset => SS_reset,
		led => led(15 downto 8)
	);
	MAIN_FSM : entity work.Main_FSM port map (
		clk => clk,
		reset => reset,
		start => start,
		paddle1 => paddle1,
		paddle2 => paddle2,
		score1 => score1,
		score2 => score2,
		max_pulse1 => max_pulse1,
		max_pulse2 => max_pulse2,
		score_pulse1_out => score_pulse1,
		score_pulse2_out => score_pulse2,
		SS_reset => SS_reset,
		score1_reset => score1_reset,
		score2_reset => score2_reset,
		current_ball_pos_out => current_ball_pos,
		SH_count => SH_count,
		SH_pulse => SH_pulse
	);
	DISPLAY_LOGIC : entity work.Display_Logic port map (
		paddle1 => paddle1,
		paddle2 => paddle2,
		mclk => mclk,
		current_ball_pos => current_ball_pos,
		column_data => column_data,
		write_enable => write_enable,
		current_column_out => current_column
	);
	DISPLAY_DRIVER : entity work.Display_Driver port map (
		mclk => mclk,
		sys_clk => mclk,
		we => write_enable,
		data_in => column_data,
		wrt_addr => current_column,
		out_to_display => extout
	);
	SCORE_MANAGER : entity work.Score_Manager port map (
		clk => clk,
		current_ball_pos => current_ball_pos,
		score1_reset => score1_reset,
		score2_reset => score2_reset,
		score_pulse1 => score_pulse1,
		score_pulse2 => score_pulse2,
		max_pulse1 => max_pulse1,
		max_pulse2 => max_pulse2,
		score1 => score1,
		score2 => score2
	);
	SLOW_CLOCK_GEN : entity work.Slow_Clock port map (
		mclk => mclk,
		slow_clock => slow_clock
	);
	SCORE_DISPLAY_MANAGER : entity work.Score_Display_Manager port map (
		score1 => score1,
		score2 => score2,
		slow_clock => slow_clock,
		anode => anode,
		cath => cath
	);
	
end Behavioral;

