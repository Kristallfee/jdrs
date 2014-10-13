 library ieee;
 use ieee.std_logic_1164.all;
 use work.util_pack.all;
 use work.sample_package.all;
 
 entity Testbench is
 end Testbench;
 
 architecture topix_data of Testbench is
	 signal clock_topix_160mhz      : std_logic;
	 signal clock_register_66mhz    : std_logic;
	 signal ilreset                 : std_logic := '0';
	 signal busy_out                : std_logic;
	 signal start_in                : std_logic := '0';
	 signal register_module_wr_en   : std_logic := '0';
	 signal module_register_data    : std_logic_vector(39 downto 0);
	 signal module_register_rd_en   : std_logic :='0';
	 signal to_topix_data_wait		: std_logic :='0';
	 signal from_topix_data_valid	: std_logic;
	 signal shift_data				: std_logic_vector(39 downto 0);
	 signal TPX_SDR_OUT				: std_logic;
	 signal MODULE_FIFO_DATA 		: std_logic_vector(39 downto 0);
 	signal MODULE_FIFO_DATA_WR_EN   : std_logic;

	constant clk160_period   : time := 6.25 ns; -- 160 MHz clock

	constant idle_package	:	std_logic_vector(39 downto 0) := x"3a55aa55aa";
	constant data_package	:	std_logic_vector(39 downto 0) := x"ca55aa55aa";	

	 begin
	 
	 clock_160mhz : process
	 begin
	 clock_topix_160mhz <= '0';
	 wait for clk160_period/2;
	 clock_topix_160mhz <= '1';
	 wait for clk160_period/2;  
	 end process clock_160mhz;
	 
	 Main : process
	 
	 procedure data_arrives
	 is
	 begin

		report "Data from ToPix arrives ";
		
		shift_data <= data_package;
		TPX_SDR_OUT	<= shift_data(39);
		wait until rising_edge(clock_topix_160mhz);
		serializer: for I in 0 to 39 loop
			from_topix_data_valid <= '1';	
			shift_data <= shift_data(38 downto 0) &'0';

			wait for clk160_period;

		end loop serializer;

		from_topix_data_valid <= '0';
		wait for clk160_period;	



	end data_arrives;

			 
	begin
			

	data_arrives;
	data_arrives;
			
	end process Main;
	 

	 U_ToPix_data: entity work.u_topix_data 
	 PORT MAP(
		CLOCK 					=> clock_topix_160mhz,
		RESET 					=> ilreset,
		BUSY 					=> busy_out,
		TPX_SDR_OUT 			=> TPX_SDR_OUT,
		MODULE_FIFO_DATA		=> MODULE_FIFO_DATA,
		TPX_DATA_VALID 			=> from_topix_data_valid,
		TPX_DATA_WAIT 			=> to_topix_data_wait,
		MODULE_FIFO_DATA_WR_EN 	=> MODULE_FIFO_DATA_WR_EN
	 );
	 
	 
 end topix_data;