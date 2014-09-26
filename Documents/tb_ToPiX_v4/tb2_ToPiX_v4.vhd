-- File>>> tb2_ToPiX_v4.vhd
--
-- Date: Thu Jan  9 13:20:58 CET 2014
-- Author: gianni
--
-- Revision history:
--
-- ToPiX_v4 test bench 1
--		This test bench randomly generates events in the pixel
--		The input events and the resulting outputs are stored
--		in two files :
--						./sim_results/tb2_ToPiXv4.datain
--						./sim_results/tb2_ToPiXv4.dataout

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

entity tb2e_ToPiX_v4 is
	generic (
		constant NHits			: integer 	:= 1000;				-- Number of events
		constant NPixels		: integer	:= 640;
		constant PixelWidth		: real 		:= 0.1;
		constant PixelHeight	: real		:= 0.1;
		constant AvgTimePerMm2 	: real		:= 100.0/(15*0.001);	-- ns : 15 MHz/cm2
		constant AvgSigWidth	: real		:= 1000.0;				-- ns -> 5 fC x 200 ns/fC
		constant clock_period	: time 		:= 6.25 ns
	);
end tb2e_ToPiX_v4;

architecture tb2a_ToPiX_v4 of tb2e_ToPiX_v4 is

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

		type ttable_type 	is array(NHits-1 downto 0) of time;
		type dtable_type 	is array(NHits-1 downto 0) of integer;
		type event_type		is array(2*NHits-1 downto 0) of integer;
		type tevent_type	is array(2*NHits-1 downto 0) of time;
		type status_type	is array(NPixels-1 downto 0) of integer;

		variable timetable	: ttable_type;
		variable widthtable	: ttable_type;
		variable addrtable	: dtable_type;

		variable el_cell_number		: event_type;
		variable el_event_time		: tevent_type;
		variable el_event_type		: event_type; 	-- 1 -> rising, 0 -> falling
		variable el_related_event	: event_type;

		variable pixel_status	: status_type;
		variable pixel_addr		: integer;
		variable row_addr		: integer;
		variable col_addr		: integer;

		variable tt_avg		: time;
		variable wt_avg		: time;
		variable at_avg		: integer;

			-- For bubblesort

		variable swap		: integer;
		variable time_swap	: time;
		variable flag		: integer;
		variable ev_dly		: time;

		variable i,j		: integer;

		variable interval		: real;
		variable seed1, seed2	: real;
		variable seed3, seed4	: real;

			-- For hit density

		variable PixelArea 			: real		:= PixelWidth*PixelHeight;
		variable ChipArea			: real		:= real(NPixels)*PixelArea;
		variable AvgTimePerPixel	: real		:= AvgTimePerMm2/PixelArea;
		variable AvgTimePerChip		: real		:= AvgTimePerMm2/ChipArea;

			-- Write to file/screen

		variable initial_delay	: time;
		variable L				: LINE;
		FILE screen				: text is out "/dev/tty";
		FILE fd_datain			: text is out "./sim_results/tb2_ToPiXv4.datain";


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

		seed1			:= 0.8;
		seed2			:= 0.4;
		seed3			:= 0.2;
		seed4			:= 0.5;

		tt_avg := 0 ns;
		for i in 0 to NHits-1 loop
			EXPONENTIAL(seed1,AvgTimePerChip,interval);
			write(L,string'("Interval [ns] : "),LEFT,0);
			write(L,interval,LEFT,0);
			writeline(screen,L);
			tt_avg := tt_avg + (interval*1 ns);
			if (i = 0) then
				timetable(i) := (interval*1 ns);
			else
				timetable(i) := (interval*1 ns)+timetable(i-1);
			end if;
		end loop;
		tt_avg := tt_avg/real(NHits);
		write(L,string'("Average time between events [ns] : "),LEFT,0);
		write(L,tt_avg,LEFT,0);
		writeline(screen,L);

		wt_avg := 0 ns;
		for i in 0 to NHits-1 loop
			GAUSSIAN(seed2,seed3,real(AvgSigWidth),real(AvgSigWidth)/2.0,interval);
			if (interval<10.0) then
				interval := 10.0;
			end if;
			-- $display("%d",interval);
			wt_avg := wt_avg + interval*1 ns;
			widthtable(i) := interval*1 ns;
		end loop;
		wt_avg := wt_avg/real(NHits);
		write(L,string'("Average signal width [ns] : "),LEFT,0);
		write(L,wt_avg,LEFT,0);
		writeline(screen,L);

		at_avg := 0;
		for i in 0 to NHits-1 loop
			UNIFORM(seed4,0.0,real(NPixels-1),interval);
			at_avg := at_avg + integer(interval);
			-- $display("%d",interval);
			addrtable(i) := integer(interval);
		end loop;
		at_avg := at_avg/NHits;
		write(L,string'("Average pixel address : "),LEFT,0);
		write(L,at_avg,LEFT,0);
		writeline(screen,L);


			-- Generate the event list

		for i in 0 to NHits-1 loop
			el_cell_number(2*i) 	:= addrtable(i);
			el_event_time(2*i)  	:= timetable(i);
			el_event_type(2*i)  	:= 1;
			el_related_event(2*i)   := 2*i+1;

			el_cell_number(2*i+1)   := addrtable(i);
			el_event_time(2*i+1)	:= timetable(i)+widthtable(i);
			el_event_type(2*i+1)	:= 0;
			el_related_event(2*i+1) := 2*i;
		end loop;

			-- Print table

		for i in 0 to 2*NHits-1 loop
			write(L,el_cell_number(i),LEFT,10);
			write(L,el_event_time(i),LEFT,20);
			write(L,el_event_type(i),LEFT,10);
			write(L,i,LEFT,10);
			write(L,el_related_event(i),LEFT,10);
			writeline(screen,L);
		end loop;

			-- Event list re-ordering (bubblesort)

		flag := 1;
		while (flag = 1) loop
			flag := 0;
			for i in 0 to 2*NHits-2 loop
				if ( el_event_time(i) > el_event_time(i+1) ) then

					swap 					:= el_cell_number(i);
					el_cell_number(i)		:= el_cell_number(i+1);
					el_cell_number(i+1)		:= swap;
					time_swap 				:= el_event_time(i);
					el_event_time(i)		:= el_event_time(i+1);
					el_event_time(i+1)		:= time_swap;
					swap 					:= el_event_type(i);
					el_event_type(i)		:= el_event_type(i+1);
					el_event_type(i+1)		:= swap;
					swap 					:= el_related_event(i);
					el_related_event(i)		:= el_related_event(i+1);
					el_related_event(i+1)	:= swap;
					j						:= el_related_event(i);
					el_related_event(j)		:= i;
					j						:= el_related_event(i+1);
					el_related_event(j)		:= i+1;
					flag					:= 1;

				elsif ((el_event_time(i)  = el_event_time(i+1))  and
						 (el_cell_number(i) = el_cell_number(i+1)) and
						 (el_event_type(i) = 1)) then
					swap 					:= el_cell_number(i);
					el_cell_number(i)		:= el_cell_number(i+1);
					el_cell_number(i+1)		:= swap;
					time_swap 				:= el_event_time(i)+1 ns;
					el_event_time(i)		:= el_event_time(i+1);
					el_event_time(i+1)		:= time_swap;
					swap 					:= el_event_type(i);
					el_event_type(i)		:= el_event_type(i+1);
					el_event_type(i+1)		:= swap;
					swap 					:= el_related_event(i);
					el_related_event(i)		:= el_related_event(i+1);
					el_related_event(i+1)	:= swap;
					j						:= el_related_event(i);
					el_related_event(j)		:= i;
					j						:= el_related_event(i+1);
					el_related_event(j)		:= i+1;
					flag					:= 1;
				end if;
			end loop;
		end loop;

			-- Print ordered table

		for i in 0 to 2*NHits-1 loop
			write(L,el_cell_number(i),LEFT,10);
			write(L,el_event_time(i),LEFT,20);
			write(L,el_event_type(i),LEFT,10);
			write(L,i,LEFT,10);
			write(L,el_related_event(i),LEFT,10);
			writeline(screen,L);
		end loop;

		for i in 0 to (NPixels-1) loop
			pixel_status(i)	:= 0;
		end loop;

		wait for (4*clock_period);
		wait for 500 ns;
		reset   <= '0';
		wait for (4*clock_period);
		cnt_rst <= '1';
		wait for (6*clock_period);

			-- Write CCR0

		cmdPin(CfgRegNBits-1 downto CfgRegNBits-CfgRegIBits)   <= conv_std_logic_vector(16#20#,CfgRegIBits);
		cmdPin(CfgRegDBits-1 downto 0) <=  conv_std_logic_vector(16#944#,CfgRegDBits);		-- Double data rate
		-- cmdPin(CfgRegDBits-1 downto 0) <=  conv_std_logic_vector(16#904#,CfgRegDBits);		-- Single data rate
		-- cmdPin(CfgRegDBits-1 downto 0) <=  conv_std_logic_vector(16#90C#,CfgRegDBits);	-- Slow readout speed
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
		wait for (10*clock_period);

			-- Data taking phase

		cnt_rst			<= '0';			-- Start the counter
		initial_delay	:= NOW;			-- In ns
		wait for (6*clock_period);

		for i in 0 to (2*NHits-1) loop
			if (el_event_time(i) < 0 ns) then
				write(L,string'("Negative time due to integer overflow"),LEFT,0);
				writeline(screen,L);
				write(L,string'("Event skipped"),LEFT,0);
				writeline(screen,L);
			else
				ev_dly := el_event_time(i)+initial_delay-NOW;	-- In ns
				write(L,string'("Event delay :"),LEFT,20);
				write(L,ev_dly,LEFT,20);
				write(L,el_event_time(i),LEFT,20);
				write(L,initial_delay,LEFT,20);
				write(L,NOW,LEFT,0);
				writeline(screen,L);
				wait for ev_dly;
				pixel_addr := el_cell_number(i);		-- Just to make lines shorter
				if (pixel_addr < NPxShort) then
					row_addr	:= pixel_addr;
					col_addr	:= 0;
				elsif (pixel_addr < 2*NPxShort) then
					row_addr	:= pixel_addr-NPxShort;
					col_addr	:= 1;
				elsif (pixel_addr < 2*NPxShort+NPxLong) then
					row_addr	:= pixel_addr-2*NPxShort;
					col_addr	:= 2;
				elsif (pixel_addr < 2*NPxShort+2*NPxLong) then
					row_addr	:= pixel_addr-2*NPxShort-NPxLong;
					col_addr	:= 3;
				elsif (pixel_addr < 2*NPxShort+3*NPxLong) then
					row_addr	:= pixel_addr-2*NPxShort-2*NPxLong;
					col_addr	:= 4;
				elsif (pixel_addr < 2*NPxShort+4*NPxLong) then
					row_addr	:= pixel_addr-2*NPxShort-3*NPxLong;
					col_addr	:= 5;
				elsif (pixel_addr < 3*NPxShort+4*NPxLong) then
					row_addr	:= pixel_addr-2*NPxShort-4*NPxLong;
					col_addr	:= 6;
				elsif (pixel_addr < 4*NPxShort+4*NPxLong) then
					row_addr	:= pixel_addr-3*NPxShort-4*NPxLong;
					col_addr	:= 7;
				else
					assert FALSE report "Error : pixel number out of range" severity FAILURE;
				end if;

				-- write(L,string'("Current pixel address : "),LEFT,0);
				-- write(L,pixel_addr,LEFT,0);
				-- writeline(screen,L);

				-- write(L,string'("Current event type : "),LEFT,0);
				-- write(L,el_event_type(i),LEFT,0);
				-- writeline(screen,L);

				-- write(L,string'("Pixel status : "),LEFT,0);
				-- write(L,pixel_status(pixel_addr),LEFT,0);
				-- writeline(screen,L);

				if (el_event_type(i) = 0) then
					if (pixel_status(pixel_addr) = 1) then
						case col_addr is
							when 0 => pixel_in_AL(row_addr)   <= '0';
							when 1 => pixel_in_AR(row_addr)   <= '0';
							when 2 => pixel_in_BL(row_addr)   <= '0';
							when 3 => pixel_in_BR(row_addr)   <= '0';
							when 4 => pixel_in_CL(row_addr)   <= '0';
							when 5 => pixel_in_CR(row_addr)   <= '0';
							when 6 => pixel_in_DL(row_addr)   <= '0';
							when 7 => pixel_in_DR(row_addr)   <= '0';
							when others => assert FALSE report "Error : illegal col_addr value" severity FAILURE;
						end case;
					end if;
					pixel_status(pixel_addr) := pixel_status(pixel_addr)-1;
				else
					case col_addr is
						when 0 => pixel_in_AL(row_addr)   <= '1';
						when 1 => pixel_in_AR(row_addr)   <= '1';
						when 2 => pixel_in_BL(row_addr)   <= '1';
						when 3 => pixel_in_BR(row_addr)   <= '1';
						when 4 => pixel_in_CL(row_addr)   <= '1';
						when 5 => pixel_in_CR(row_addr)   <= '1';
						when 6 => pixel_in_DL(row_addr)   <= '1';
						when 7 => pixel_in_DR(row_addr)   <= '1';
						when others => assert FALSE report "Error : illegal col_addr value" severity FAILURE;
					end case;
					pixel_status(pixel_addr) := pixel_status(pixel_addr)+1;
					j := el_related_event(i);

						-- Write input events to file
					write(L,el_event_time(i),LEFT,20);
					write(L,el_event_time(j),LEFT,20);
					write(L,el_cell_number(i),LEFT,0);
					writeline(fd_datain,L);
				end if;
			end if;
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

	-- doutSin			<= SDR_out;
	doutSin			<= DDR_out;
	doutShiftEn		<= data_valid after clock_period/2;

	dout_process : process (reset, clock)
	begin
		if (reset = '1') then
			dout_sr	<= (others => '0') after 500 ps;
		elsif (clock'event and (clock = '1' or clock = '0')) then
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
		FILE fd_dataout			: text is out "./sim_results/tb2_ToPiXv4.dataout";
	begin
		if (reset = '0' and dvalid_dly1'event and dvalid_dly1 = '0') then

			-- write(L,NOW-initial_delay,LEFT,0);
			write(L,NOW,LEFT,20);
			case dout_latch(39 downto 38) is

				when "00" =>
					-- write(L,string'("S "),LEFT,0);
					hwrite(L, "00" & dout_latch(39 downto 38),LEFT,8);
					hwrite(L, "00" & dout_latch(37 downto 36),LEFT,8);
					hwrite(L, dout_latch(35 downto 20),LEFT,8);
					hwrite(L, dout_latch(19 downto 4),LEFT,8);
					hwrite(L, dout_latch(3 downto 0),LEFT,8);
					writeline(fd_dataout,L);

				when "01" =>
					-- write(L,string'("H "),LEFT,0);
					hwrite(L, "00" & dout_latch(39 downto 38),LEFT,8);
					hwrite(L, "0000" & dout_latch(37 downto 26),LEFT,8);
					hwrite(L, dout_latch(25 downto 18),LEFT,8);
					hwrite(L, "0000" & dout_latch(17 downto 6),LEFT,8);
					hwrite(L, "00" & dout_latch(5 downto 0),LEFT,8);
					writeline(fd_dataout,L);

				when "10" =>
					-- write(L,string'("T "),LEFT,0);
					hwrite(L, "00" & dout_latch(39 downto 38),LEFT,8);
					hwrite(L, dout_latch(37 downto 22),LEFT,8);
					hwrite(L, dout_latch(21 downto 6),LEFT,8);
					hwrite(L, "00" & dout_latch(5 downto 0),LEFT,8);
					write(L,string'("00"),LEFT,8);	-- Just to have 5 fields
					writeline(fd_dataout,L);

				when "11" =>
					-- write(L,string'("D "),LEFT,0);
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

end tb2a_ToPiX_v4;

	-- Test bench configuration file

configuration tb2c_ToPiX_v4 of tb2e_ToPiX_v4 is
	for tb2a_ToPiX_v4
		for all: ToPiX_v4
			use entity work.ToPiX_v4(rtl);
		end for;
	end for;
end tb2c_ToPiX_v4;


