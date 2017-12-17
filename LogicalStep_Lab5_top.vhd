
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab5_top IS
   PORT
	(
   clkin_50		: in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb				: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors

	);
END LogicalStep_Lab5_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab5_top IS

		--Cycle generator to create custom clock systems
   component cycle_generator port (
          clkin      		: in  std_logic;
			 rst_n				: in  std_logic;
			 modulo 				: in  integer;	
			 strobe_out			: out	std_logic;
			 full_cycle_out	: out std_logic
  );
   end component;
	
	component Moore_SM  port (
	
		clk_input		: in std_logic; --1 Hz clock from cycle generator
		clk_input_five : in std_logic; --5 Hz clock from cycle generator
		rst_n				: in std_logic; --Reset Line
		NS_VS				: in std_logic; -- North South Vehicle detection
		WE_VS				: in std_logic; -- West East Vehicle detection
		NM					: in std_logic; -- Night Mode Signal 
		RM					: in std_logic; -- Reduced Mode Mode Signal 
		NORTH_SOUTH		: out std_logic_vector(6 downto 0); --Display Signal for seven Seg Display for North South
		WEST_EAST		: out std_logic_vector(6 downto 0); --Display Signal for seven Seg Display for West East
		NSLCR				: out std_logic; --North South Latch Clear Signal 
		WELCR				: out	std_logic; --West East Latch Clear Signal
		State_Num		: out std_logic_vector(3 downto 0) -- Hex output representing the current state
	);
	end Component;


   component segment7_mux port (
          clk        : in  std_logic := '0';
			 DIN2 		: in  std_logic_vector(6 downto 0);	
			 DIN1 		: in  std_logic_vector(6 downto 0); 
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;	--Digit 2
			 DIG1			: out	std_logic 	--Digit 1
   );
   end component;
	

	
		--Sync Component to sync the inputs to the clock
	component Sync port(
	
		clk				: in std_logic;	--Clock
		reset				: in std_logic;	--Reset Line
		ctrl				: in std_logic;	--Input to control
		data_out			: out std_logic   --Data ouput
	);
	end component;
	
		--Latch 
	component Ltch port (
			clk        : in  std_logic; --Clock 
			enable	  : in std_logic;  --Enable Signal 
			rst_n	     : in std_logic;  --Reset line
			synch		  : in std_logic;  --Signal input
			LCR		  : in std_logic;	 --Latch Clear Signal 
			datout	  : out std_logic  --Data output
   );
   end component;
	
----------------------------------------------------------------------------------------------------
	CONSTANT	SIM							:  boolean := True;

	CONSTANT CNTR1_modulo				: 	integer :=25000000;    		-- modulo count for 1Hz cycle generator 1 with 50Mhz clocking input
   CONSTANT CNTR2_modulo				: 	integer :=5000000;    		-- modulo count for 5Hz cycle generator 2 with 50Mhz clocking input
   CONSTANT CNTR1_modulo_sim			: 	integer := 199;   			-- modulo count for cycle generator 1 during simulation
   CONSTANT CNTR2_modulo_sim			: 	integer :=  39;   			-- modulo count for cycle generator 2 during simulation
	
   SIGNAL CNTR1_modulo_value			: 	integer ;   					-- modulo count for cycle generator 1 
   SIGNAL CNTR2_modulo_value			: 	integer ;   					-- modulo count for cycle generator 2 

   SIGNAL clken1,clken2					:  STD_LOGIC; 						-- clock enables 1 & 2

	SIGNAL strobe1, strobe2				:  std_logic;						-- strobes 1 & 2 with each one being 50% Duty Cycle
	SIGNAL NORTH_SOUTH					:	std_logic_vector(6 downto 0);
	SIGNAL WEST_EAST						:	std_logic_vector(6 downto 0);	
	signal outputNSsynch					: 	std_logic; --NS Sync component output
	signal outputWEsynch					: 	std_logic; --WE Sync component output
	signal outputforLatchWE				:	std_logic; --NS Latch component output
	signal outputforLatchNS				:	std_logic; --WE Latch component output
	signal LCR1								:	std_logic; ---nS latch clear signal 
	signal LCR2								: 	std_logic; ---we latch clear signal
	signal Night_Mode						:	std_logic;	--Night Mode input signal  
	signal NM_SO							: 	std_logic;	-- Night mode sync output signal
	signal Reserved_Mode					:	std_logic; -- Reserved mode input signal
	signal RM_SO							: 	std_logic; -- Reserved mode sync output signal
	--SIGNAL seg7_A, seg7_B				:  STD_LOGIC_VECTOR(6 downto 0); -- signals for inputs into seg7_mux.
	
BEGIN
----------------------------------------------------------------------------------------------------


MODULO_1_SELECTION:	CnTR1_modulo_value <= CNTR1_modulo when SIM = FALSE else CNTR1_modulo_sim; 

MODULO_2_SELECTION:	CNTR2_modulo_value <= CNTR2_modulo when SIM = FALSE else CNTR2_modulo_sim;

-- Assigning input switch signals to the local signals
Night_Mode <= sw(0);
Reserved_Mode <= sw(1); 
						

----------------------------------------------------------------------------------------------------
-- Component Hook-up:					

--Cycle generator (1 Hz)
GEN1: 	cycle_generator port map(clkin_50, rst_n, CNTR1_modulo_value, strobe1, clken1);	

--Cycle generator (5 Hz)
GEN2: 	cycle_generator port map(clkin_50, rst_n, CNTR2_modulo_value, strobe2, clken2);	

--More state machine to control traffic lights
SM:		Moore_SM port map(strobe1, strobe2, rst_n, outputNSsynch, outputWEsynch, NM_SO, RM_SO, NORTH_SOUTH, WEST_EAST, LCR1, LCR2,leds(5 downto 2));

--Seven seg Mux for seven seg display
NSWE:		segment7_mux port map(clkin_50, NORTH_SOUTH, WEST_EAST,seg7_data, seg7_char1, seg7_char2);

--Sync component for north south vehicle detection
TBSR1:	Sync port map(clkin_50, rst_n, not(pb(1)), outputNSsynch); --- NS

--Latch Component for north south vehicle detection
L1:		Ltch port map(clkin_50, clken2, rst_n, outputNSsynch, LCR1, outputforLatchNS);

--Sync component for West East vehicle detection
TBSR2:	Sync port map(clkin_50, rst_n, not(pb(0)), outputWEsynch); ---WE

--Latch Component for north south vehicle detection
L2:		Ltch port map(clkin_50, clken2, rst_n, outputNSsynch, LCR2, outputforLatchWE);

--Sync component for Night mode
TBSR3: 	Sync port map(clkin_50, rst_n, Night_Mode, NM_SO);	

--Sync component for reserved mode
TBSR4:	Sync port map(clkin_50, rst_n, Reserved_mode, RM_SO);	





	--Strobe output
	leds(1 downto 0) <= Strobe1 & Strobe2;
	
	--Push button (Vehicle detection) displayed on led to show if on or off
	leds(7) <= (not(pb(0))) or (not(pb(1))) ;
	
	--Switch (Special Mode) displayed on led to show if on or off
	leds(6) <= (sw(1) OR sw(0));
	

-- used for simulations
--	leds(0) <= clken1;
--	leds(1) <= Strobe1;
--	leds(2) <= clken2;
--	leds(3) <= Strobe2;
--	leds(7 downto 4) <= Stae Machine state numbers


END SimpleCircuit;
