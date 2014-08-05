 library ieee;
 use ieee.std_logic_1164.all;
 use work.util_pack.all;
 use work.sample_package.all;
 
 entity Testbench is
 end Testbench;
 
 architecture topix_sdata of Testbench is
	 signal clock_topix_150mhz      : std_logic;
	 signal clock_register_66mhz    : std_logic;
	 signal ilreset                 : std_logic := '0';
	 signal datalength_in           : std_logic_vector(9 downto 0);
	 signal sdata_to_topix          : std_logic;
	 signal sdata_en_to_topix       : std_logic;
	 signal sdata_from_topix        : std_logic := '1';
	 signal busy_out                : std_logic;
	 signal start_in                : std_logic := '0';
	 signal register_module_data    : std_logic_vector(31 downto 0) := x"00000000";
	 signal register_module_wr_en   : std_logic := '0';
	 signal module_register_data    : std_logic_vector(31 downto 0);
	 signal module_register_rd_en   : std_logic :='0';
	 signal fifo_empty              : std_logic;
	 signal write_data_count        : std_logic_vector(31 downto 0);
	 signal read_data_count         : std_logic_vector(31 downto 0);

	 begin
	 
	 clock_150mhz : process
	 begin
	 clock_topix_150mhz <= '0';
	 wait for 3.33333 ns;
	 clock_topix_150mhz <= '1';
	 wait for 3.33333 ns;  
	 end process clock_150mhz;
	 
	 Dummy_ToPix_response : process
	 begin
	 sdata_from_topix <= '1';
	 wait for 6.6667 ns;
	 sdata_from_topix <= '0';
	 wait for 6.6667 ns;  
	 end process Dummy_ToPix_response;
	 
	 clock_66mhz : process
	 begin
	 clock_register_66mhz <= '0';
	 wait for 7.5757576 ns;
	 clock_register_66mhz <= '1';
	 wait for 7.5757576 ns;  
	 end process clock_66mhz;
	 
	 Main : process
	 
	 procedure read_from_module
	 is
	 begin

		report "Read dataword from module";
		module_register_rd_en <= '1';
		wait for 16 ns;
		module_register_rd_en <= '0';
		wait for 16 ns;

	 end read_from_module;
	 
	 procedure write_to_module
			(
				 value : integer
			 ) is
				 
				 variable value_slv  : T_SLV32 := INT2SLV(value);
				 
				 begin
				 report "Write dataword to module";  
					 
				 register_module_data <= value_slv;
				 
				 register_module_wr_en <= '1';
				 wait for 16 ns;
				 register_module_wr_en <= '0';
				 wait for 16 ns;
	 end write_to_module;
			 
		begin
			
			datalength_in <= "0000010010";
			
			wait for 50 ns;

			write_to_module(16#55555555#);

			wait for 10 ns;
			
			report "Start module to send written words to ToPix";
			
			start_in <= '1';
			wait for 8 ns;
			start_in <= '0';
			
			wait for 300 ns;
			
			read_from_module;
			
			wait for 500 ns;
			
		end process Main;
	 

	 U_ToPix_sdata: entity work.u_topix_sdata 
	 PORT MAP(
		 CLOCK_TOPIX											=> clock_topix_150mhz,
		 CLOCK_REGISTER 						      => clock_register_66mhz,
		 SDATA_OUT 								        => sdata_to_topix,
		 SDATA_EN_OUT	 						        => sdata_en_to_topix,
		 SDATA_IN 								        => sdata_from_topix,
		 REGISTER_MODULE_DATA_IN 			    => register_module_data,
		 MODULE_REGISTER_DATA_OUT 			  => module_register_data,
		 REGISTER_MODULE_DATA_WR_EN_IN 	  => register_module_wr_en,
		 MODULE_REGISTER_DATA_RD_EN_IN 	  => module_register_rd_en,
		 MODULE_REGISTER_DATA_EMPTY_OUT   => fifo_empty,
		 MODULE_REGISTER_DATA_COUNT_OUT 	=> write_data_count,
		 REGISTER_MODULE_DATA_COUNT_OUT 	=> read_data_count,
		 START_IN 								        => start_in,
		 BUSY_OUT 								        => busy_out,
		 DATALENGTH_IN 							      => datalength_in,
		 RESET_IN 								        => ilreset
	 );
	 
	 
 end topix_sdata;