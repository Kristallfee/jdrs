-- -----------------------------------------------------------------------------
--
--                           Simone Esch  |       ######
--        Institut fuer Kernphysik (IKP)  |    #########
--        Forschungszentrum Juelich GmbH  |   #########   ##
--              D-52425 Juelich, Germany  |  #########   ####
--                                        |  ########   #####
--             (+49)2461 61 3101 :   Tel  |   #   ##   #####
--             (+49)2461 61 3930 :   FAX  |    ##     #####
--          s.esch@fz-juelich.de : EMail  |       ######
--
-- -----------------------------------------------------------------------------
-- =============================================================================
--
--	project:		PANDA-MVD
--	module:		LTC2604 
--	author:		S.Esch IKP.FZJ
-- description: Module to configure two LTC2604 DAC in daisychain configuratoin
--
-- History
-- Date     | Rev | Author    | What
-- ---------+-----+-----------+-------------------------------------------------
-- 01.05.12 | 0.0 | S.Esch    | begin of new development
-- 13.05.14 | 1.1 | S.Esch    | Move fifo into this moduel 

-- ======================================================================= --

--! @file
--! @brief Module to configurate two LTC2604 in daisychain configuration
--! @details Module to configurate two LTC2604 in daisychain configuration (the output of the first LTC is the input of the next one)
--! The data for configuration is stored in a FIFO. The SM takes two words from the FIFO and clocks it via the serial input into the LTC.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util_pack.all;

entity SM_LTC2604 is
port (
	BUSY					: out std_logic;							--! Busy signal for SM
	LTC_SCK				: out std_logic;							--! Serial Clock for LTC
	LTC_SDI				: out std_logic;							--! Serical data in (into LTC)
	LTC_CSLD				: out std_logic;							--! Chip Select/Load Input
	CLOCK					: in  std_logic;							--! 10 MHz clock of LTC
	RESET					: in  std_logic;							--! Synchronus reset
	START					: in  std_logic;							--! Start of LTC configuration
	FIFO_WR_CLK       : in  std_logic;							--! Clock of registermodule 
	FIFO_WR_EN			: in  std_logic;							--! Write enable 
	FIFO_DATA_IN		: in  std_logic_vector(31 downto 0);--! Datapath into the fifo
	FIFO_DATA_COUNT 	: out std_logic_vector(9 downto 0) 	--! Number of FIFO entries
	);
end SM_LTC2604;

architecture arc_SM_LTC2604 of SM_LTC2604 is

	type ltcstate is (l_idle, l_waitforfirstdata, l_getfirstdata,l_waitforseconddata, l_getseconddata, l_sendneg, l_sendpos, l_nextword, l_flushfifo);
	signal ltcclock			: std_logic;
	signal cslddata			: std_logic_vector(63 downto 0);
	signal shiftdata			: std_logic_vector(63 downto 0);
	signal state				: ltcstate;
	signal datacount  		: std_logic_vector(31 downto 0);
	signal fifo_empty 		: std_ulogic;									
	signal fifo_datacount	: std_logic_vector( 9 downto 0);	
   signal fifo_dataout     : std_logic_vector(31 downto 0);	
	signal fifo_flush			: std_logic;
	signal fifo_re_en 		: std_logic;							--! fifo read enable 

begin

	U_LTC_FIFO : entity work.ltc_fifo
   PORT MAP (
	 rst					=>	fifo_flush,
	 wr_clk 				=> FIFO_WR_CLK,
	 rd_clk 				=> CLOCK,
	 din 					=> FIFO_DATA_IN,
	 wr_en 				=> FIFO_WR_EN,
	 rd_en 				=> fifo_re_en,
	 dout 				=> fifo_dataout,
	 full 				=> open,
	 empty 				=> fifo_empty,
	 valid 				=> open,
	 rd_data_count 	=> fifo_datacount
   );

	LTC_SCK 				<= ltcclock;
	LTC_SDI 				<= shiftdata(0);
	LTC_CSLD 			<= cslddata(0);
	FIFO_DATA_COUNT 	<= fifo_datacount;

	LTC2604CFG_0 : process(CLOCK)
	begin
		if rising_edge(CLOCK) then
			if RESET = '1' then
				state 		<= l_idle;
				BUSY 			<= '0';
				shiftdata	<= "0000000000000000000000000000000000000000000000000000000000000000";
				cslddata  	<= "1111111111111111111111111111111111111111111111111111111111111111";
				ltcclock 	<= '0';
				fifo_flush 	<= '1';
			else
				case state is
				when l_idle =>
					if START = '1' and fifo_empty='0' then  		--start state machine 
						if fifo_datacount(0 downto 0) = "1" then 	-- we always need a even number of words, since two ltc are in daisychain configuration, if just one word, flush fifo 
						state 		<= l_flushfifo; 					
						BUSY 			<= '1';
						else
						state 		<= l_waitforfirstdata;
						BUSY 			<= '1';
						fifo_re_en 	<= '1';
						cslddata 	<= "0000000000000000000000000000000000000000000000000000000000000000";
						end if;
					else
						state 		<= l_idle;
						BUSY 			<= '0';
						fifo_re_en	<='0';
						shiftdata 	<= "0000000000000000000000000000000000000000000000000000000000000000";
						cslddata  	<= "1111111111111111111111111111111111111111111111111111111111111111";
					end if;
					ltcclock 	<= '0';
					fifo_flush 	<= '0';
				-- negative clock edge and data change
				when l_waitforfirstdata =>
					state			<= l_getfirstdata;
					BUSY 			<= '1';
					fifo_re_en 	<= '0';
					ltcclock 	<= '0';
				when l_getfirstdata =>
					state 		<= l_waitforseconddata;
					shiftdata 	<= "00000000000000000000000000000000" & fifo_dataout;
					fifo_re_en 	<= '1';
					BUSY 			<= '1';
					ltcclock 	<= '0';
				when l_waitforseconddata =>
					state			<= l_getseconddata;
					BUSY 			<= '1';
					fifo_re_en 	<= '0';
					ltcclock 	<= '0';
				when l_getseconddata =>
					state 		<= l_sendpos;
					shiftdata 	<= shiftdata(31 downto 0) & fifo_dataout;
					fifo_re_en 	<= '0';
					BUSY 			<= '1';
					ltcclock 	<= '0';
				when l_sendneg =>
					state 		<= l_sendpos;
					BUSY 			<= '1';
					shiftdata 	<= '0' & shiftdata(63 downto 1);
					cslddata 	<= '1' & cslddata(63 downto 1);
					ltcclock 	<= '0';
				-- positive clock edge and end of data determination
				when l_sendpos =>
					if cslddata = "1111111111111111111111111111111111111111111111111111111111111111" then -- wait till all bits are shifted
						state 	<= l_nextword;
					else
						state 	<= l_sendneg;
					end if;
					BUSY 			<= '1';
					shiftdata 	<= shiftdata;
					cslddata 	<= cslddata;
					ltcclock 	<= '1';
				when l_nextword =>
					if fifo_empty = '1' then 
						state 		<= l_idle;
						fifo_re_en 	<= '0';
						ltcclock 	<= '1';
					elsif fifo_datacount(0 downto 0) = "1" then -- todo: if there is an odd number of entries
						state 		<= l_flushfifo;
					else
						state 		<= l_waitforfirstdata;
						cslddata 	<= "0000000000000000000000000000000000000000000000000000000000000000";
						fifo_re_en 	<= '1';
						ltcclock 	<= '1';
					end if;
					BUSY <= '1';
				when l_flushfifo =>
						fifo_flush 	<= '1';
						state 		<= l_idle;
						BUSY 			<= '0';
				end case;
			end if;
		end if;
	end process;

end arc_SM_LTC2604;