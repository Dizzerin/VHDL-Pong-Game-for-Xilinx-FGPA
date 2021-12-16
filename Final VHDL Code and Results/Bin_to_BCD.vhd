----------------------------------------------------------------------------------
-- Company:  Walla Walla University
-- Engineer: L.Aamodt
-- 
-- Create Date:    10:56:13 10/13/2020 
-- File Name:      bin_to_bcd.vhd
-- Module Name:    bin2bcd - Behavioral 
-- Project Name:   Lab5
-- Target Devices:  
-- Tool versions: 
-- Description:  A module used to convert 8 bits binary to 3 BCD digits
--
-- Dependencies: 
--
-- Revision: 
-- Revision 1.0 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_module is
    port (B4,B3,B2,B1 : in std_logic;
          D4,D3,D2,D1 : out std_logic
		  );
end bcd_module;

architecture functional of bcd_module is
begin
    D1 <= (B4 and (not B1)) or ((not B4) and (not B3) and B1) or 
          (B3 and B2 and (not B1));
    D2 <= (B2 and B1) or (B4 and (not B1)) or ((not B3) and B2 and (not B1));
    D3 <= (B3 and (not B2) and (not B1)) or (B4 and B1);
    D4 <= B4 or (B3 and B1) or (B3 and B2);
end functional;

-----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bin2bcd_top is
    port (b0,b1,b2,b3,b4,b5,b6,b7 : in  STD_LOGIC;
          grp0 : out  STD_LOGIC_VECTOR (3 downto 0);	-- ones
          grp1 : out  STD_LOGIC_VECTOR (3 downto 0);	-- tens
          grp2 : out  STD_LOGIC_VECTOR (3 downto 0));	-- hundreds
end bin2bcd_top;

architecture Behavioral of bin2bcd_top is

    component bcd_module
    port (B4,B3,B2,B1 : in std_logic;
          D4,D3,D2,D1 : out std_logic);
    end component;
	
    signal p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12 : std_logic;
    signal p13,p14,p15,p16,p17,p18,p19 : std_logic;
begin
    module1 : bcd_module port map ('0',b7,b6,b5,p4,p3,p2,p1);
    module2 : bcd_module port map (p3,p2,p1,b4,p8,p7,p6,p5);
    module3 : bcd_module port map (p7,p6,p5,b3,p12,p11,p10,p9);
    module4 : bcd_module port map ('0',p4,p8,p12,grp2(1),p19,p18,p17);
    module5 : bcd_module port map (p11,p10,p9,b2,p16,p15,p14,p13);
    module6 : bcd_module port map (p19,p18,p17,p16,grp2(0),grp1(3),grp1(2),grp1(1));
    module7 : bcd_module port map (p15,p14,p13,b1,grp1(0),grp0(3),grp0(2),grp0(1));

    grp2(3) <= '0';
    grp2(2) <= '0';
    grp0(0) <= b0;
end Behavioral;

