library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- 7-segment display driver. It displays a 4-bit number on a 7-segment
-- This is created as an entity so that it can be reused many times easily
--

entity SevenSegment is port (
   
   hex	   :  in  std_logic_vector(4 downto 0);   -- The 4 bit data to be displayed
   
   sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end SevenSegment;

architecture Behavioral of SevenSegment is

-- 
-- The following statements convert a 4-bit input, called dataIn to a pattern of 7 bits
-- The segment turns on when it is '1' otherwise '0'
--
begin
   with hex select						     --GFEDCBA        3210      -- data in   
	sevenseg  <=				    			   
										  
										 "1000000" when "00100", --- amber
										 "0000001" when "01000", --- red
										 "0001000" when "00001"; --- green
										 
										 
end architecture Behavioral; 
----------------------------------------------------------------------
