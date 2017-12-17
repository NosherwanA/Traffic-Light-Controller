 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


Entity Moore_SM IS Port
(
		clk_input		: in std_logic; --1 hz strobe
		clk_input_five : in std_logic; --5hz strobe
		rst_n				: in std_logic; --Reset Line
		NS_VS				: in std_logic; --NS Vehicle Sensing /Pedestrian Request
		WE_VS				: in std_logic; --EW Vehicle Sensing /Pedestrian Request
		NM					: in std_logic; --Night Mode
		RM					: in std_logic; -- Reduced System Mode Switch
		NORTH_SOUTH		: out std_logic_vector(6 downto 0); -- output to seven seg display for North South
		WEST_EAST		: out std_logic_vector(6 downto 0); -- output to seven seg display for East West
		NSLCR				: out std_logic; -- Latch Clear Signal for North South
		WELCR				: out	std_logic; -- Latch Clear Signal for East West
		State_Num		: out std_logic_vector(3 downto 0) -- Current state output to leds
		
 );
End Entity;


Architecture SM of Moore_SM is

	Type States is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, SA, SB, SC, SD, SE, SF, SR, SN);
	SIGNAL current_state, next_state	:  States;   -- signals of type STATE_NAMES for local use
	
	
	
	
	
BEGIN

Register_Section: PROCESS (clk_input, rst_n, next_state)  -- this process synchronizes the activity to a clock

	BEGIN
		IF (rst_n = '0') THEN
			current_state <= S0;
		ELSIF(rising_edge(clk_input)) THEN
			current_state <= next_State;
		ELSE
			current_state <= current_state;
		END IF;
	END PROCESS;
	

	
Transition_Section: PROCESS (clk_input, current_state)  -- this process the transistion form 1 state to another

	BEGIN
     
	  CASE current_state IS
         WHEN S0 =>
				if (WE_VS = '1') then -- If a vehicle is detected of the WE road then jump to State 6
					next_state <= S6;
			
				else
					next_state <= S1;
				end if;

				
			WHEN S1 =>	
					
				if (WE_VS = '1') then -- If a vehicle is detected of the WE road then jump to State 6
					next_state <= S6;
				else
					next_state <= S2;
				end if;

			
			WHEN S2 =>	
				if (WE_VS = '1') then -- If a vehicle is detected of the WE road then jump to State 6
					next_state <= S6;
			
				else
					next_state <= S3;
				end if;
			

			WHEN S3 =>	
				if (WE_VS = '1') then -- If a vehicle is detected of the WE road then jump to State 6
					next_state <= S6;	
	
				else
					next_state <= S4;	
				end if;

			WHEN S4 =>	

				if (WE_VS = '1') then -- If a vehicle is detected of the WE road then jump to State 6
					next_state <= S6;
			
				else
					next_state <= S5;
				end if;

			WHEN S5 =>	
		
				next_state <= S6;	

			
			WHEN S6 =>	
		
				next_state <= S7;

			
			WHEN S7 =>	
		
				if (RM = '1') then -- If in Reduced System Mode switch is on jump to reduced mode
				
					next_state <= SR;
					
				else
					
					if (NM = '1') then  -- If in Reduced System Mode switch is off and Night Mode switch is onn jump to Night Mode
						
						next_state <= SN;
					
					else
					
						next_state <= S8;
						
					end if;
				
				end if;
					

			
			WHEN S8 =>	
					
					
				if (NS_VS = '1') then -- If a vehicle is detected of the NS road then jump to State 14
					next_state <=SE;
		
				else
					next_state <= S9;
				end if;

			
			WHEN S9 =>	
		
				if (NS_VS = '1') then -- If a vehicle is detected of the NS road then jump to State 14
					next_state <=SE;	
			
				else
					next_state <= SA;
				
				end if;

			WHEN SA =>	
		
				if (NS_VS = '1') then -- If a vehicle is detected of the NS road then jump to State 14
					next_state <=SE;
			
				else
					next_state <= SB;	
				end if;
			

			
			WHEN SB =>	
				if (NS_VS = '1') then -- If a vehicle is detected of the NS road then jump to State 14
					next_state <=SE;
		
				else	
					next_state <= SC;
				end if;

			
			WHEN SC =>		
			
				if (NS_VS = '1') then -- If a vehicle is detected of the NS road then jump to State 14
					next_state <=SE;
					
				else	
					next_state <= SD;
				end if;
	
			WHEN SD =>		
			
				next_state <= SE;

--			
			WHEN SE =>	
		
			
				next_state <= SF;

			
			WHEN SF =>	
			
				if (RM = '1') then  -- If in Reduced System Mode switch is on jump to reduced mode
				
					next_state <= SR;
					
				else
					
					if (NM = '1') then  -- If in Reduced System Mode switch is off and Night Mode switch is onn jump to Night Mode
						
						next_state <= SN;
					
					else
					
						next_state <= S0;
					
					end if;
					
				end if;

--			--Reduced Mode State		
			WHEN SR =>
			
				if (RM = '1') then -- If in Reduced System Mode switch is on remain to reduced mode
					
					next_state <= SR; 
					
				else
					
					if (NM = '1') then  -- If in Reduced System Mode switch is off and Night Mode switch is onn jump to Night Mode
						
						next_state <= SN;
					
					else
						
						next_state <= S6; -- If both switches are off jump back to state 6
					
					end if;
					
				end if;
--			
--			--Night Mode State
			WHEN SN =>
			
				if (RM = '1') then -- If in Reduced System Mode switch is on jump to reduced mode
					
					next_state <= SR;
					
				else
					
					if (NM = '1') then -- If in Reduced System Mode switch is off and Night Mode switch is onn remain in Night Mode
						
						next_state <= SN;
					
					else
						
						next_state <= S6; -- If both switches are off jump back to state 6
					
					end if;
					
				end if;
--				
				
			WHEN others => --ERROR CONDITION: RESET BACK TO S0
				next_state <= S0;
			
		END CASE;
		
 END PROCESS; 

Decoder_Section: PROCESS (current_state) --this process translates the state of the state machine to the binary representation of the state (equivilent to hex number)

	BEGIN
	
		CASE current_state IS
		
         WHEN S0 =>
				NORTH_SOUTH <= "000" & clk_input_five & "000" ; --- flashing green by anding with 5 hz clock
				WEST_EAST <=   "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "0000";
				
				
			WHEN S1 =>		
				NORTH_SOUTH <= "000" & clk_input_five & "000" ; --- flashing green by anding with 5 hz clock
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "0001";
				
			WHEN S2 =>		
				NORTH_SOUTH <= "0001000"; --- solid green
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "0010";
				
			WHEN S3 =>		
				NORTH_SOUTH <= "0001000"; --- solid green
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "0011";
				
			WHEN S4 =>		
				NORTH_SOUTH <= "0001000"; --- solid green
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "0100";
				
			WHEN S5 =>		
 				NORTH_SOUTH <= "0001000"; --- solid green
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "0101";
			
			WHEN S6 =>		
				NORTH_SOUTH <= "1000000"; -- solid amber
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "0110";
				
			WHEN S7 =>		
				NORTH_SOUTH <= "1000000"; -- solid amber
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '1'; -- sending latch clear signal for NS
				WELCR <= '1'; -- sending latch clear signal for WE
				State_Num <= "0111";
				
			WHEN S8 =>		
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <= "000" & clk_input_five & "000" ; --- flashing green
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "1000";
				
			WHEN S9 =>		
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <= "000" & clk_input_five & "000" ;  --- flashing green
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "1001";
				
			WHEN SA =>		
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <="0001000"; --- solid green
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "1010";
				
			WHEN SB =>		
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <= "0001000"; --- solid green
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "1011";
		
			WHEN SC =>
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <="0001000"; --- solid green
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "1100";
				
			WHEN SD =>		 
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <="0001000"; --- solid green
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "1101";
				
			WHEN SE =>		
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <= "1000000"; --- solid amber
				NSLCR <= '0';
				WELCR <= '0';
				State_Num <= "1110";
			
			WHEN SF =>		
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <= "1000000";  --- solid amber
				NSLCR <= '1'; -- sending latch clear signal for NS
				WELCR <= '1'; -- sending latch clear signal for WE
				State_Num <= "1111";
			
			WHEN SR =>
				NORTH_SOUTH <= clk_input & "000000"; --- flashing amber
				WEST_EAST <= "000000" & clk_input; --- flashing red
				NSLCR <= '0';
				WELCR <= '0';
				
			WHEN SN =>
				NORTH_SOUTH <= "0001000"; --- solid green
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
				
			WHEN others =>
				NORTH_SOUTH <= "0000001"; --- solid red
				WEST_EAST <= "0000001"; --- solid red
				NSLCR <= '0';
				WELCR <= '0';
			
		END CASE;
		

END PROCESS;

 

END SM;
