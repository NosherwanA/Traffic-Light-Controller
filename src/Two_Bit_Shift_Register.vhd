library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Sync is port
(
		clk				: in std_logic;	--Clock
		reset				: in std_logic;	--Reset Line
		ctrl				: in std_logic;	--Input to control
		data_out			: out std_logic
		
		
);
end entity;


architecture internal of Sync is 

	-- Temp Signals used within 

 signal output				: std_logic; 
 signal intermediate		: std_logic;
 
		

begin


Left_Register	: process (clk,reset) is 
		
		begin

		
		If (reset = '0') then --If reset, reset the latch to 0
			
			intermediate <= '0';
		
		elsif (rising_edge(clk)) then --on the rising the edge, store the value from ctrl
			
			intermediate <= ctrl;
			
		else
			
			intermediate <= intermediate;
			
		end if;
		
		
end process;


Right_Register	: process (clk,reset) is 
		
		begin
			
		
		If (reset = '0') then --If reset, reset the forst latch to 0
			output <= '0';

		elsif (rising_edge(clk)) then --on the rising the edge, store the value from the intermediate
			output <= intermediate;
			
		else
			output <= intermediate;
		end if;
		

		
end process;
		
		--output of the component from the second flip flop 
		data_out <= output;



end architecture internal;
		