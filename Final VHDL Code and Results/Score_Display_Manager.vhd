----------------------------------------------------------------------------------
-- Score Display Manager
----------------------------------------------------------------------------------
--	Caleb Nelson
-- 	12/12/2021
--
-- Description:
-- 	This module is responsible for displaying the 2 players scores on the 4 digit
--		7-segment display.  The leftmost digit is used for player 1's score while
--		the rightmost digit is used for player 2's score
--		The primary inputs are:
--			score1		--> player 1's score (4 bits)
--			score2		--> player 2's score (4 bits)
--			slow_clock	--> a clock used for muxing between the two digits (can be about 500Hz)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Score_Display_Manager is
    Port ( 	score1 : in  STD_LOGIC_VECTOR (3 downto 0);	-- 4 bit binary (not BCD)
			score2 : in  STD_LOGIC_VECTOR (3 downto 0);	-- 4 bit binary (not BCD)
			slow_clock : in  STD_LOGIC;
			anode : out  STD_LOGIC_VECTOR (4 downto 0);
			cath : out  STD_LOGIC_VECTOR (7 downto 0)
		  );
end Score_Display_Manager;

architecture Behavioral of Score_Display_Manager is
	-- Signals
	signal score1_BCD, score2_BCD, display_data: STD_LOGIC_VECTOR (3 downto 0);	
	-- Counter signals
	signal count : STD_LOGIC;
	-- TODO could change BCD converter so this is no longer needed
	signal unused : STD_LOGIC_VECTOR (3 downto 0);
	
	--	Notes:
	-- anode 0 <--> left hand digit
	-- anode 1 <--> left innner digit
	-- anode 2 <--> right inner digit
	-- anode 3 <--> right hand digit
	-- anode 4 <--> colon
	
begin

	-- Components
	BIN_TO_BCD : entity work.bin2bcd_top port map (
		b0 => score1(0),
		b1 => score1(1),
		b2 => score1(2),
		b3 => score1(3),
		b4 => '0',
		b5 => '0',
		b6 => '0',
		b7 => '0',
		grp0 => score1_BCD(3 downto 0),	-- ones
		grp1 => unused,					-- tens
		grp2 => unused					-- hundreds
	);
	BIN_TO_BCD2 : entity work.bin2bcd_top port map (
		b0 => score2(0),
		b1 => score2(1),
		b2 => score2(2),
		b3 => score2(3),
		b4 => '0',
		b5 => '0',
		b6 => '0',
		b7 => '0',
		grp0 => score2_BCD(3 downto 0),	-- ones
		grp1 => unused,					-- tens
		grp2 => unused					-- hundreds
	);
	SEGMENT_DECODER : entity work.bcd2_7seg port map (
		data => display_data,			-- BCD of player's score
		cath_out => cath(7 downto 0)
	);

	-- Turn off the inner two digits and the colon
	anode(1) <= '1';	-- left innner digit
	anode(2) <= '1';	-- right inner digit
	anode(4) <= '1';	-- colon
	
	----------------------------------------------------------------------------
	--  1 bit counter - used to select which digit should be lit
	----------------------------------------------------------------------------
	process(slow_clock)
	begin
		-- trigger on rising edges
		 if (slow_clock'event and slow_clock='1') then
			  count <= not(count);
		 end if;
	end process;
	----------------------------------------------------------------------------
	-- Decoder:
	----------------------------------------------------------------------------
	-- power/light proper digit
	-- alternates between which digit is lit
	-- note these are active low!
	anode(0) <=	count;			-- left digit is on when count is 0	(active low)
	anode(3) <= not(count);		-- right digit is on when count is 1 (active low)
	----------------------------------------------------------------------------
	-- Mux:
	----------------------------------------------------------------------------
	-- Select which score to display based on which digit is active
	display_data <= score1_BCD when (count='0') else
					score2_BCD;
	----------------------------------------------------------------------------
	
end Behavioral;

