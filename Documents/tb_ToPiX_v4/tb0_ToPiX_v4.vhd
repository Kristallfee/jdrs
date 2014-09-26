-- File>>> tb0_ToPiX_v4.vhd
--
-- Date: Thu Jan  9 13:20:58 CET 2014
-- Author: gianni
--
-- Revision history:
--
-- ToPiX_v4 test bench 0

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.ToPiX_constants.all;
use work.util_pkg.all;

entity tb0e_ToPiX_v4 is
	generic (
		clock_period: time := 6 ns
	);
end tb0e_ToPiX_v4;

architecture tb0a_ToPiX_v4 of tb0e_ToPiX_v4 is

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

		wait for (4*clock_period);
		wait for 500 ps;
		reset   <= '0';
		wait for (4*clock_period);
		cnt_rst <= '1';
		wait for (6*clock_period);

			-- Write CCR0

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#20#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) <=  conv_std_logic_vector(16#f34#,CfgRegDBits);
		cmdLoad 	<= '1';
		wait for clock_period;
		cmdLoad 	<= '0';
		wait for clock_period;
		serial_en 	<= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en  	<= '0';
		wait for (10*clock_period);

			-- Write CCR1

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#21#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) <= conv_std_logic_vector(16#5a5#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);

			-- Write CCR2

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#22#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#787#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for (CfgRegNBits*clock_period);
		serial_en   <= '0';
		wait for (10*clock_period);


			-- Read CCR0

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#30#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for ((CfgRegNBits)*clock_period);
		serial_en   <= '0';
		wait for (4*clock_period); 		-- NOP insertion
		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#00#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;

			-- Read CCR1

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#31#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for ((CfgRegNBits)*clock_period);
		serial_en   <= '0';
		wait for (4*clock_period); 		-- NOP insertion
		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#00#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;

			-- Read CCR2

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#32#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		cmdLoad <= '0';
		wait for clock_period;
		serial_en   <= '1';
		wait for ((CfgRegNBits)*clock_period);
		serial_en   <= '0';
		wait for (4*clock_period); 		-- NOP insertion
		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#00#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
		cmdLoad <= '1';
		wait for clock_period;
		serial_en   <= '1';
		wait for ((CfgRegNBits)*clock_period);
		serial_en   <= '0';
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
			if ( i rem 2 = 0) then
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0055#,CfgRegDBits);
			else
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#00AA#,CfgRegDBits);
			end if;
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
			if ( i rem 2 = 0) then
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0066#,CfgRegDBits);
			else
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0099#,CfgRegDBits);
			end if;
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
			if ( i rem 2 = 0) then
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#007E#,CfgRegDBits);
			else
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0081#,CfgRegDBits);
			end if;
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
			if ( i rem 2 = 0) then
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
			else
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#00FF#,CfgRegDBits);
			end if;
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
			if ( i rem 2 = 0) then
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#00A5#,CfgRegDBits);
			else
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#005A#,CfgRegDBits);
			end if;
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
			if ( i rem 2 = 0) then
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0078#,CfgRegDBits);
			else
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0087#,CfgRegDBits);
			end if;
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
			if ( i rem 2 = 0) then
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#000F#,CfgRegDBits);
			else
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#00F0#,CfgRegDBits);
			end if;
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
			if ( i rem 2 = 0) then
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0069#,CfgRegDBits);
			else
				cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0096#,CfgRegDBits);
			end if;
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

			-- Read pixel configuration

		for i in 0 to NPxShort loop

				-- Read pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#05#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
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

		wait for (20*clock_period);

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

			-- Read pixel configuration

		for i in 0 to NPxShort loop

				-- Read pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#05#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
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

		wait for (20*clock_period);


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

			-- Read pixel configuration

		for i in 0 to NPxLong loop

				-- Read pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#05#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
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

		wait for (20*clock_period);


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

			-- Read pixel configuration

		for i in 0 to NPxLong loop

				-- Read pixel configuration

			cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#05#,CfgRegIBits);
			cmdPin(CfgRegDBits-1 downto 0) 	<= conv_std_logic_vector(16#0000#,CfgRegDBits);
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

		wait for (20*clock_period);


		wait for (10*clock_period);
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
	doutShiftEn		<= data_valid;

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

end tb0a_ToPiX_v4;


	-- Test bench configuration file

configuration tb0c_ToPiX_v4 of tb0e_ToPiX_v4 is
	for tb0a_ToPiX_v4
		for all: ToPiX_v4
			use entity work.ToPiX_v4(rtl);
		end for;
	end for;
end tb0c_ToPiX_v4;


