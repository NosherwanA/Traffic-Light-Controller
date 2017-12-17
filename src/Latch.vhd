library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Ltch is port(
	clk        : in  std_logic;
	enable	  : in std_logic;
	rst_n	     : in std_logic;
	synch		  : in std_logic;
	LCR		  : in std_logic;
	datout	  : out std_logic


);
end entity;

architecture int of Ltch is 

signal input1	:std_logic;
signal input2	:std_logic;
signal input3	:std_logic;
signal output	:std_logic;

BEGIN



	process(clk, enable, rst_n, input3)
		
		BEGIN
--------------------------------- creating the input for the  latch----------------------		
			input1 <=  NOT LCR;
			input2 <=  synch OR output;
			input3 <=  input2 AND input1;
-----------------------------------------------------------------------------------------

			if (rst_n = '0') then ---- if reset is activated the output must be 0
					output <= '0';			
			elsif (enable = '1') then
				
				if(rising_edge(clk)) THEN ---- only when on the rising edge of the clock should the input be outputed
					output <= input3;

				else
					output <= output;
				end if;
			
			else

			end if;
			
			-- output from the flip flop
			datout <=  output;
			
		end process;

end architecture int;