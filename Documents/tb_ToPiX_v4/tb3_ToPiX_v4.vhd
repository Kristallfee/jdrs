-- File>>> tb3_ToPiX_v4.vhd
--
-- Date: Thu Jan  9 13:20:58 CET 2014
-- Author: gianni
--
-- Revision history:
--
-- ToPiX_v4 test bench 3
--		This test bench generates one event per pixel starting from
--		column 0, cell 31 to column 3, cell 0. It is used to check
--		the busy propagation time.
--		The input events and the resulting outputs are stored
--		in two files :
--						./sim_results/tb3_ToPiXv4.datain
--						./sim_results/tb3_ToPiXv4.dataout

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;	-- I/O for logic types

library std;
use std.textio.all;				-- Basic I/O

library work;
use work.distributions.all;
use work.ToPiX_constants.all;
use work.util_pkg.all;

entity tb3e_ToPiX_v4 is
	generic (
		constant NPixels		: integer	:= 640;
		-- constant clock_period	: time 		:= 12.5 ns	-- 80 MHz
		-- constant clock_period	: time 		:= 8.33 ns		-- 120 MHz
		constant clock_period	: time 		:= 6.25 ns	-- 160 MHz
	);
end tb3e_ToPiX_v4;

architecture tb3a_ToPiX_v4 of tb3e_ToPiX_v4 is

	signal pixel_in_AL	: std_logic_vector(NPxShort-1 downto 0);
	signal pixel_in_AR	: std_logic_vector(NPxShort-1 downto 0);
	signal pixel_in_BL	: std_logic_vector(NPxLong-1 downto 0);
	signal pixel_in_BR	: std_logic_vector(NPxLong-1 downto 0);
	signal pixel_in_CL	: std_logic_vector(NPxLong-1 downto 0);
	signal pixel_in_CR	: std_logic_vector(NPxLong-1 downto 0);
	signal pixel_in_DL	: std_logic_vector(NPxShort-1 downto 0);
	signal pixel_in_DR	: std_logic_vector(NPxShort-1 downto 0);
	signal reset		: std_logic;
	signal cnt_rst		: std_logic;
	signal clock		: std_logic;
	signal serial_in	: std_logic;
	signal serial_en	: std_logic;
	signal serial_out	: std_logic;
	signal SDR_out		: std_logic;
	signal DDR_out		: std_logic;
	signal data_valid	: std_logic;
	signal data_wait	: std_logic;
	signal busy			: std_logic;
	signal SEU_fsm		: std_logic;
	signal SEU_reg		: std_logic;
	signal eoc			: std_logic;

		-- Testbench shift registers

	signal cmd_sr 		: std_logic_vector(CfgRegNBits downto 0);
	signal cmdPin 		: std_logic_vector(CfgRegNBits downto 0);
	signal cmdLoad		: std_logic;
	signal cmdShiftEn	: std_logic;
	signal cmdSin		: std_logic;

	signal cout_sr		: std_logic_vector(CfgRegNBits-1 downto 0);
	signal coutShiftEn	: std_logic;
	signal coutSin		: std_logic;

	signal dout_sr		: std_logic_vector(SerNBits-1 downto 0);
	signal doutShiftEn	: std_logic;
	signal doutSin		: std_logic;

		-- Signals for data storage into files

	signal dout_latch	: std_logic_vector(SerNBits-1 downto 0);
	signal dvalid_dly0	: std_logic;
	signal dvalid_dly1	: std_logic;

	-- signal initial_delay	: time;


	component ToPiX_v4
		port (
			pixel_in_AL	: in  std_logic_vector(NPxShort-1 downto 0);
			pixel_in_AR	: in  std_logic_vector(NPxShort-1 downto 0);
			pixel_in_BL	: in  std_logic_vector(NPxLong-1 downto 0);
			pixel_in_BR	: in  std_logic_vector(NPxLong-1 downto 0);
			pixel_in_CL	: in  std_logic_vector(NPxLong-1 downto 0);
			pixel_in_CR	: in  std_logic_vector(NPxLong-1 downto 0);
			pixel_in_DL	: in  std_logic_vector(NPxShort-1 downto 0);
			pixel_in_DR	: in  std_logic_vector(NPxShort-1 downto 0);
			reset		: in  std_logic;
			cnt_rst		: in  std_logic;
			clock		: in  std_logic;
			serial_in	: in  std_logic;
			serial_en	: in  std_logic;
			serial_out	: out std_logic;
			SDR_out		: out std_logic;
			DDR_out		: out std_logic;
			data_valid	: out std_logic;
			data_wait	: in  std_logic;
			busy		: out std_logic;
			SEU_fsm		: out std_logic;
			SEU_reg		: out std_logic;
			eoc			: out std_logic
		);
	end component;

begin

	DUT : ToPiX_v4
		port map (
			pixel_in_AL	=> pixel_in_AL,		pixel_in_AR	=> pixel_in_AR,
			pixel_in_BL	=> pixel_in_BL,		pixel_in_BR	=> pixel_in_BR,
			pixel_in_CL	=> pixel_in_CL,		pixel_in_CR	=> pixel_in_CR,
			pixel_in_DL	=> pixel_in_DL,		pixel_in_DR	=> pixel_in_DR,
			reset		=> reset,			cnt_rst		=> cnt_rst,
			clock		=> clock,			serial_in	=> serial_in,
			serial_en	=> serial_en,		serial_out	=> serial_out,
			SDR_out		=> SDR_out,			DDR_out		=> DDR_out,
			data_valid	=> data_valid,		data_wait	=> data_wait,
			busy		=> busy,			eoc			=> eoc,
			SEU_fsm		=> SEU_fsm,			SEU_reg		=> SEU_reg);

	generate_clock : process 
	begin
		clock   <= '1';
		wait for clock_period/2;
		clock   <= '0';
		wait for clock_period/2;
	end process;


	test_patterns : process

		variable tt_avg		: time;
		variable wt_avg		: time;
		variable at_avg		: integer;


			-- Write to file/screen

		variable initial_delay	: time;
		variable L				: LINE;
		FILE screen				: text is out "/dev/tty";
		FILE fd_datain			: text is out "./sim_results/tb3_ToPiXv4.datain";


	begin

			-- Initial values

		pixel_in_AL		<= conv_std_logic_vector(0,NPxShort);
		pixel_in_AR		<= conv_std_logic_vector(0,NPxShort);
		pixel_in_BL		<= conv_std_logic_vector(0,NPxLong);
		pixel_in_BR		<= conv_std_logic_vector(0,NPxLong);
		pixel_in_CL		<= conv_std_logic_vector(0,NPxLong);
		pixel_in_CR		<= conv_std_logic_vector(0,NPxLong);
		pixel_in_DL		<= conv_std_logic_vector(0,NPxShort);
		pixel_in_DR		<= conv_std_logic_vector(0,NPxShort);
		reset			<= '1';
		cnt_rst			<= '1';
		serial_en		<= '0';
		data_wait		<= '0';

		cmdPin			<= conv_std_logic_vector(0,CfgRegNBits+1);
		cmdLoad			<= '0';

		wait for (4*clock_period);
		wait for 500 ns;
		reset   <= '0';
		wait for (4*clock_period);
		cnt_rst <= '1';
		wait for (6*clock_period);

			-- Write CCR0

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#20#,CfgRegIBits);
		-- cmdPin(CfgRegDBits-1 downto 0) <=  conv_std_logic_vector(16#904#,CfgRegDBits);		-- Normal readout speed
		cmdPin(CfgRegDBits-1 downto 0) <=  conv_std_logic_vector(16#90C#,CfgRegDBits);	-- Slow readout speed
		-- cmdPin(CfgRegDBits-1 downto 0) <=  conv_std_logic_vector(16#984#,CfgRegDBits);	-- Counter half frequency
		cmdLoad 	<= '1';
		wait for clock_period;
		cmdLoad 	<= '0';
		wait for clock_period;
		serial_en 	<= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en  	<= '0';
		wait for (10*clock_period);


			-- Select column 0 (Double column 0 left)

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#03#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Set config mode

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#02#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write pixel configuration

		for i in 0 to NPxShort loop

				-- Write pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#04#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);		-- Enable pixel
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

				-- Move to the next pixel

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#07#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

		end loop;


			-- Select column 1 (Double column 0 right)

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#03#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0001#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write pixel configuration

		for i in 0 to NPxShort loop

				-- Write pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#04#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);		-- Enable pixel
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

				-- Move to the next pixel

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#07#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

		end loop;


			-- Select column 2 (Double column 1 left)

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#03#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0002#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write pixel configuration

		for i in 0 to NPxLong loop

				-- Write pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#04#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);		-- Enable pixel
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

				-- Move to the next pixel

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#07#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

		end loop;


			-- Select column 3 (Double column 1 right)

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#03#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0003#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write pixel configuration

		for i in 0 to NPxLong loop

				-- Write pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#04#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);		-- Enable pixel
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

				-- Move to the next pixel

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#07#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

		end loop;


			-- Select column 4 (Double column 2 left)

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#03#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0004#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write pixel configuration

		for i in 0 to NPxLong loop

				-- Write pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#04#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);		-- Enable pixel
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

				-- Move to the next pixel

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#07#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

		end loop;


			-- Select column 5 (Double column 2 right)

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#03#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0005#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write pixel configuration

		for i in 0 to NPxLong loop

				-- Write pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#04#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);		-- Enable pixel
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

				-- Move to the next pixel

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#07#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

		end loop;


			-- Select column 6 (Double column 3 left)

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#03#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0006#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write pixel configuration

		for i in 0 to NPxShort loop

				-- Write pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#04#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);		-- Enable pixel
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

				-- Move to the next pixel

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#07#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

		end loop;


			-- Select column 7 (Double column 3 right)

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#03#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0007#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write pixel configuration

		for i in 0 to NPxShort loop

				-- Write pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#04#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);		-- Enable pixel
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

				-- Move to the next pixel

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#07#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			cmdLoad <= '1';
			wait for clock_period;
			cmdLoad <= '0';
			wait for clock_period;
			serial_en   <= '1';
			wait for (CfgRegNBits*clock_period);
			serial_en   <= '0';
			wait for (2*clock_period);

		end loop;

			-- Set normal mode

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#01#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (100*clock_period);


			-- Data taking phase

		cnt_rst			<= '0';			-- Start the counter
		initial_delay	:= NOW;			-- In ns
		wait for (6*clock_period);

			-- Column 0

		for i in NPxShort-1 downto 0 loop

			pixel_in_AL(i)	<= '1';
			wait for 6.4*clock_period;
			pixel_in_AL(i)	<= '0';
			wait for 0.6*clock_period;
			wait for 120*clock_period;

		end loop;

		wait for 200*clock_period;

			-- Column 1

		for i in NPxShort-1 downto 0 loop

			pixel_in_AR(i)	<= '1';
			wait for 12.8*clock_period;
			pixel_in_AR(i)	<= '0';
			wait for 0.2*clock_period;
			wait for 120*clock_period;

		end loop;

		wait for 200*clock_period;

			-- Column 2

		for i in NPxLong-1 downto 0 loop

			pixel_in_BL(i)	<= '1';
			wait for 8.4*clock_period;
			pixel_in_BL(i)	<= '0';
			wait for 0.6*clock_period;
			wait for 120*clock_period;

		end loop;

		wait for 200*clock_period;

			-- Column 3

		for i in NPxLong-1 downto 0 loop

			pixel_in_BR(i)	<= '1';
			wait for 14.8*clock_period;
			pixel_in_BR(i)	<= '0';
			wait for 0.2*clock_period;
			wait for 120*clock_period;

		end loop;

		wait for 200*clock_period;

			-- Column 4

		for i in NPxLong-1 downto 0 loop

			pixel_in_CL(i)	<= '1';
			wait for 10.4*clock_period;
			pixel_in_CL(i)	<= '0';
			wait for 0.6*clock_period;
			wait for 120*clock_period;

		end loop;

		wait for 200*clock_period;

			-- Column 5

		for i in NPxLong-1 downto 0 loop

			pixel_in_CR(i)	<= '1';
			wait for 16.8*clock_period;
			pixel_in_CR(i)	<= '0';
			wait for 0.2*clock_period;
			wait for 120*clock_period;

		end loop;

		wait for 200*clock_period;

			-- Column 6

		for i in NPxShort-1 downto 0 loop

			pixel_in_DL(i)	<= '1';
			wait for 12.4*clock_period;
			pixel_in_DL(i)	<= '0';
			wait for 0.6*clock_period;
			wait for 120*clock_period;

		end loop;

		wait for 200*clock_period;

			-- Column 7

		for i in NPxShort-1 downto 0 loop

			pixel_in_DR(i)	<= '1';
			wait for 18.8*clock_period;
			pixel_in_DR(i)	<= '0';
			wait for 0.2*clock_period;
			wait for 120*clock_period;

		end loop;

		wait for (2000*clock_period);

			-- End of simulation
		assert FALSE report "End of simulation" severity FAILURE;

	end process;


		-- Command shift register

	cmdSin			<= '0';
	cmdShiftEn		<= serial_en;
	serial_in		<= cmd_sr(CfgRegNBits-1);

	cmd_process : process (reset, clock)
	begin
		if (reset = '1') then
			cmd_sr	<= (others => '0') after 500 ps;
		elsif (clock'event and clock = '1') then
			if (cmdLoad = '1') then
				cmd_sr	<= cmdPin after 500 ps;
			elsif (cmdShiftEn = '1') then
				cmd_sr	<= cmd_sr(CfgRegNBits-1 downto 0) & '0' after 500 ps;
			end if;
		end if;
	end process;


		-- Command output shift register

	coutSin			<= serial_out;
	coutShiftEn		<= serial_en after (2*clock_period);

	co_process : process (reset, clock)
	begin
		if (reset = '1') then
			cout_sr	<= (others => '0') after 500 ps;
		elsif (clock'event and clock = '1') then
			if (coutShiftEn = '1') then
				cout_sr	<= cout_sr(CfgRegNBits-2 downto 0) & coutSin after 500 ps;
			end if;
		end if;
	end process;

		-- Output shift register

	doutSin			<= SDR_out;
	-- doutSin			<= DDR_out;
	doutShiftEn		<= data_valid after clock_period;

	dout_process : process (reset, clock)
	begin
		if (reset = '1') then
			dout_sr	<= (others => '0') after 500 ps;
		elsif (clock'event and clock = '1') then
			if (doutShiftEn = '1') then
				dout_sr	<= dout_sr(SerNBits-2 downto 0) & doutSin after 500 ps;
			end if;
		end if;
	end process;

		-- Data valid latch

	dvalid_dly0		<= data_valid  after clock_period;
	dvalid_dly1		<= dvalid_dly0 after clock_period;

	dlatch_process : process(reset, dvalid_dly0)
	begin
		if (reset = '1') then
			dout_latch <= conv_std_logic_vector(0,SerNBits);
		elsif (dvalid_dly0'event and dvalid_dly0 = '0') then
			dout_latch	<= dout_sr;
		end if;
	end process;

		-- Write to file

	write_process : process(reset, dvalid_dly1)
		variable L : line;
		FILE fd_dataout			: text is out "./sim_results/tb3_ToPiXv4.dataout";
	begin
		if (reset = '0' and dvalid_dly1'event and dvalid_dly1 = '0') then

			-- write(L,NOW-initial_delay,LEFT,0);
			write(L,NOW,LEFT,20);
			case dout_latch(39 downto 38) is

				when "00" =>
					write(L,string'("S "),LEFT,0);
					hwrite(L, "00" & dout_latch(39 downto 38),LEFT,8);
					hwrite(L, "00" & dout_latch(37 downto 36),LEFT,8);
					hwrite(L, dout_latch(35 downto 20),LEFT,8);
					hwrite(L, dout_latch(19 downto 4),LEFT,8);
					hwrite(L, dout_latch(3 downto 0),LEFT,8);
					writeline(fd_dataout,L);

				when "01" =>
					write(L,string'("H "),LEFT,0);
					hwrite(L, "00" & dout_latch(39 downto 38),LEFT,8);
					hwrite(L, "0000" & dout_latch(37 downto 26),LEFT,8);
					hwrite(L, dout_latch(25 downto 18),LEFT,8);
					hwrite(L, "0000" & dout_latch(17 downto 6),LEFT,8);
					hwrite(L, "00" & dout_latch(5 downto 0),LEFT,8);
					writeline(fd_dataout,L);

				when "10" =>
					write(L,string'("T "),LEFT,0);
					hwrite(L, "00" & dout_latch(39 downto 38),LEFT,8);
					hwrite(L, dout_latch(37 downto 22),LEFT,8);
					hwrite(L, dout_latch(21 downto 6),LEFT,8);
					hwrite(L, "00" & dout_latch(5 downto 0),LEFT,8);
					write(L,string'("00"),LEFT,8);	-- Just to have 5 fields
					writeline(fd_dataout,L);

				when "11" =>
					write(L,string'("D "),LEFT,0);
					hwrite(L,  "00" & dout_latch(39 downto 38),LEFT,8);
					hwrite(L,  "0" & dout_latch(37 downto 31),LEFT,8);
					hwrite(L,  "0" & dout_latch(30 downto 24),LEFT,8);
					hwrite(L,  "0000" & dout_latch(23 downto 12),LEFT,8);
					hwrite(L,  "0000" & dout_latch(11 downto 0),LEFT,8);
					writeline(fd_dataout,L);
				when others => 
					write(L,string'("Illegal header"),LEFT,0);
					writeline(fd_dataout,L);
			end case;
		end if;
	end process;

end tb3a_ToPiX_v4;

	-- Test bench configuration file

configuration tb3c_ToPiX_v4 of tb3e_ToPiX_v4 is
	for tb3a_ToPiX_v4
		for all: ToPiX_v4
			use entity work.ToPiX_v4(rtl);
		end for;
	end for;
end tb3c_ToPiX_v4;


