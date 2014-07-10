-- -----------------------------------------------------------------------------
--
--                           Willi Erven  |       ######
-- Zentralinstitut fuer Elektronik (ZEL)  |    #########
--        Forschungszentrum Juelich GmbH  |   #########   ##
--              D-52425 Juelich, Germany  |  #########   ####
--                                        |  ########   #####
--             (+49)2461 61 4130 :   Tel  |   #   ##   #####
--             (+49)2461 61 3573 :   FAX  |    ##     #####
--         w.erven@fz-juelich.de : EMail  |       ######
--
-- -----------------------------------------------------------------------------
-- =============================================================================
--
--	project:		WASA
--	module:		sysctrl => system controller
--	author:		W.Erven ZEL.FZJ
--
-- History
-- Date     | Rev | Author    | What
-- ---------+-----+-----------+-------------------------------------------------
-- 19.07.02 | 0.0 | W.Erven   | begin of new DAQ system development

-- ======================================================================= --
--
--	timing
-- ilclk    -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
-- P_REG   ____------____  ____--------____
-- P_WR    ____------____  ________________
-- P_A     0===x=====0===  0===x=======0===
-- P_D     0===x=====0===
-- P_D_O                   0===x=d=====0===
-- P_RDY   ________--____  ______--....____
--
-- ======================================================================= --
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.util_pack.all;
use work.sample_package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity SREGS is
generic (
	SC_VERSION	: integer
);
port (
	LCLK				: out	std_logic;
	BASECLOCK		: in  std_logic;	--! 125 MHz
	CLK66				: in  std_logic; 	--! 66 MHz
	CLK200			: in  std_logic;	--! 200 MHz
	GRESET   		: out	std_logic;	-- general reset
	--P1MS				: in	std_logic;	-- 1 ms pulse
	LED				: out std_logic_vector(7 downto 0);
	USER_SWITCH		: in	std_logic_vector(4 downto 0);
	
-- ----------------------- DAC ----------------------------------------- --  	
	DAC_SDI   		: out std_logic;
	DAC_CLR   		: out std_logic;
	DAC_SCK   		: out std_logic;
	DAC_CS_LD 		: out std_logic;
--	-------------------------- local bus zum GIGALink Teil ---------------- --
	P_REG				: in	std_logic;								--! Signal fuer Registerzugriffe
	P_WR				: in	std_logic;								--! write
	P_A				: in	std_logic_vector(12 downto 2);	--! address
	P_D				: in	T_SLV32;									--! data - byte count is swapped
	P_D_O				: out	T_SLV32;									--! data out
	P_D_O_DMA		: out T_SLV40;									--! data out dma
	P_RDY				: out	std_logic;								--! data ready
	P_BLK				: in  std_logic;								--! always read
	P_WAIT			: in 	std_logic;								--! pause block read
	P_END				: out std_logic;								--! block end
-- -------------------------- ToPix Signals ---------------------------- --
	TOPIX_DATA_WAIT	: out		std_logic;
	TOPIX_DATA_VALID	: in		std_logic;
	TOPIX_SDR_OUT		: in		std_logic;
	TOPIX_RESET_OUT	: out 	std_logic;
	TPX_SDATA_IN	: out		std_logic;
	TPX_SDATA_EN	: out 	std_logic;
	TPX_SDATA_OUT	: in 		std_logic;
	TPX_CLOCK		: out 	std_logic;

--	-------------------------- control signals ---------------------------- --
--	DMD_DMA			: in	std_logic;
	EV_DATACOUNT	: out std_logic_vector(17 downto 0);
--	DT_REQ			: out	std_logic;
--	DT_ACK			: in	std_logic;
--	DT_DEN			: out	std_logic;		-- data enable on PD
	FIFO_EMPTY  	: out std_logic
--	-------------------------- write to Host register request ------------- --
--	HREG_REQ			: out	std_logic;
--	HREG_A			: out	std_logic_vector(8 downto 2);		-- address
--	HREG_D			: out	T_SLV32;
--	HREG_ACK			: in	std_logic;
-- -------------------------- control/status ----------------------------- --
--	SYS_MODE			: out	T_SLV16;		-- control
-- -------------------------- host doorbell ------------------------------ --
--	P100MS			: in	std_logic;		-- 100 ms signal
--	DMD_WR			: in	std_logic		-- write demand data to host
);
end SREGS;

architecture RTL of SREGS is

-- ======================================================================= --
--										    Signals                                  --
-- ======================================================================= --
	alias regadr						: std_logic_vector(8 downto 0) is P_A(10 downto 2);
-- control/status register
	--signal doorbell_mask				: T_SLV16;
--signal stimer						: T_SLV32;
--	signal stimer_clr					: std_logic;
-- block counter
--	signal dmd_counter				: std_logic_vector(31 downto 2);
--	signal dmd_block_sz				: std_logic_vector(23 downto 2);
--	signal dmd_block					: std_logic_vector(23 downto 2);
--	signal dmd_load					: std_logic;
--	signal dmd_int						: std_logic;
-- host doorbell
--	signal cnt1sec						: T_SLV4;
--	signal s2sec						: std_logic;
--	signal dbell_in					: T_SLV32;
--	signal dbell_in_d					: T_SLV32;
--	signal dbell_act					: T_SLV32;
--	signal dbell_out					: T_SLV32;
--	signal dbell_req					: std_logic;
	signal creg							: T_SLV32;
	signal creg_sync_topixclk		: std_logic_vector(31 downto 0);
	signal tpx_fifodummyreg			: std_logic_vector(31 downto 0);
	signal tpx_fifodummydata		: std_logic_vector(31 downto 0);
	signal tpx_fifo_din				: std_logic_vector(31 downto 0);
	signal tpx_fifo_datacount		: std_logic_vector(9 downto 0);
	signal tpx_fifodummywe			: std_logic;
	signal synthieclock				: std_logic;
	signal dummy_data_busy			: std_logic;
	signal tpx_inputsm_busy			: std_logic;
	signal tpx_fifodummydestwe		: std_logic;
	signal clock_counter				: std_logic_vector(11 downto 0):= "000000000000";
	signal led_config					: std_logic_vector(4 downto 0);
	signal one_hertz_counter_i		: std_logic_vector(7 downto 0);
	signal knight_rider_i			: std_logic_vector(7 downto 0);
	signal ilclk,ilreset				: std_logic;

-- ========================== MMCM_DRP ====================================== --
	signal rc_do						: T_SLV16;
	signal rc_we,rc_start			: std_logic;
	signal drp_busy					: std_logic;
	signal s_rdy						: std_logic;		-- single ready (no block)
	signal rdy_fi,rdy_fi_d1			: std_logic;
	signal fi_count,fi_cnt_max		: T_SLV10;
	signal fi_wen						: std_logic;
	signal fi_ren						: std_logic;
	signal fi_empty,fi_full			: std_logic;
	signal fi_pfull					: std_logic;		-- 3/4
	signal fi_datacount				: std_logic_vector(17 downto 0);
	signal fi_din_dummy				: std_logic_vector(31 downto 0);
	signal fi_din,fi_dout         : std_logic_vector(39 downto 0);
	signal fi_valid					: std_logic;
	signal fill_dma_counter       : std_logic_vector(39 downto 0);
	signal blk							: std_logic;
	signal blk_rdy						: std_logic;
	signal blk_cnt						: std_logic_vector(17 downto 0);	-- lword count, 1MB
	signal blk_zero					: std_logic;	-- zero
	signal ldt_den						: std_logic;
   signal ev_datacount_int		   : std_logic_vector(17 downto 0);
-- ========================== Clocks ====================================== --	
	signal clk10mhz					: std_logic;

-- ==========================  Misc  ====================================== --
	signal ltcconfbusy							: std_logic;
	signal reset_sc_ltc							: std_logic;
	signal creg_sc_ltc							: std_logic;
	signal ltc_fifowe								: std_logic;
	signal ltcreg									: std_logic_vector(31 downto 0);
	signal ltc_fifo_datacount					: std_logic_vector(9 downto 0);

	signal register_module_data_int			: std_logic_vector(31 downto 0);
	signal module_register_data_int			: std_logic_vector(31 downto 0);
	signal register_module_data_wr_en_int	: std_logic;
	signal module_register_data_rd_en_int	: std_logic;
	signal rdy_sdata_out							: std_logic;
	signal rdy_sdata_out_d1						: std_logic;
	signal module_register_data_empty_int	: std_logic;
	signal module_register_data_count_int 	: std_logic_vector(31 downto 0);
	signal register_module_data_count_int	: std_logic_vector(31 downto 0);

	signal tpx_inputsm_serial_data_length	: std_logic_vector(9 downto 0);
	signal tpx_sc_inputsm_serial_data_length : std_logic_vector(9 downto 0);
	signal topixclock								: std_logic;

	signal fake_data_generator_wr_en : std_logic;
	signal fake_data_generator_data  : std_logic_vector(39 downto 0);

	signal topix_fifo_data				: std_logic_vector(39 downto 0);
	signal topix_fifo_data_wr_en		: std_logic;
	signal fake_data_generator_interval : std_logic_vector(31 downto 0);
	signal choose_datapath   			: std_logic_vector(31 downto 0);

-- ======================================================================= --
--										       Begin                                 --
-- ======================================================================= --

begin

-- ======================================================================= --
--						            Components Port Map                          --
-- ======================================================================= --
LCLK		<= ilclk;
GRESET	<= ilreset;
TPX_CLOCK<= topixclock;
TOPIX_RESET_OUT <= creg(1);

U_FAKE_DATA_GENERATOR: entity work.fake_data_generator PORT MAP(
	CLOCK 			=> topixclock,
	ENABLE 			=> creg_sync_topixclk(10),
	INTERVAL 		=> fake_data_generator_interval,
	FAKE_DATA 		=> fake_data_generator_data,
	REC_WRITE_EN 	=> fake_data_generator_wr_en
);

fi_din <= 	topix_fifo_data 					when choose_datapath(1 downto 0) ="00" else
				fill_dma_counter					when choose_datapath(1 downto 0) ="01" else
				"00000000"&tpx_fifodummydata 	when choose_datapath(1 downto 0) ="10" else
				fake_data_generator_data		when choose_datapath(1 downto 0) ="11" else
				topix_fifo_data;
fi_wen <= 	topix_fifo_data_wr_en 			when choose_datapath(1 downto 0) ="00" else
				not fi_full							when choose_datapath(1 downto 0) ="01" else
				tpx_fifodummydestwe			 	when choose_datapath(1 downto 0) ="10" else
				fake_data_generator_wr_en		when choose_datapath(1 downto 0) ="11" else
				topix_fifo_data_wr_en;

--ToPix_sdata : entity work.u_topix_sdata  
--	PORT MAP (
--	CLOCK									=> topixclock,
--	REGISTER_CLOCK						=> ilclk,
--	SDATA_IN								=> TPX_SDATA_IN,
--	SDATA_EN								=> TPX_SDATA_EN,
--	SDATA_OUT							=> TPX_SDATA_OUT,
--	REGISTER_MODULE_DATA				=> register_module_data_int,
--	MODULE_REGISTER_DATA				=> module_register_data_int,
--	REGISTER_MODULE_DATA_WR_EN		=> register_module_data_wr_en_int,
--	MODULE_REGISTER_DATA_RD_EN		=> module_register_data_rd_en_int,
--	MODULE_REGISTER_DATA_EMPTY		=> module_register_data_empty_int,
--	MODULE_REGISTER_DATA_COUNT		=> module_register_data_count_int,
--	REGISTER_MODULE_DATA_COUNT		=> register_module_data_count_int,
--	START									=> creg_sync_topixclk(9),
--	BUSY									=> tpx_inputsm_busy,
--	DATALENGTH							=> tpx_sc_inputsm_serial_data_length,
--	RESET									=> ilreset
--	);

ToPix_sdata: entity work.u_topix_sdata 
PORT MAP(
	CLOCK_TOPIX 							=> topixclock,
	CLOCK_REGISTER 						=> ilclk,
	SDATA_OUT 								=> TPX_SDATA_IN,
	SDATA_EN_OUT	 						=> TPX_SDATA_EN,
	SDATA_IN 								=> TPX_SDATA_OUT,
	REGISTER_MODULE_DATA_IN 			=> register_module_data_int,
	MODULE_REGISTER_DATA_OUT 			=> module_register_data_int,
	REGISTER_MODULE_DATA_WR_EN_IN 	=> register_module_data_wr_en_int,
	MODULE_REGISTER_DATA_RD_EN_IN 	=> module_register_data_rd_en_int,
	MODULE_REGISTER_DATA_EMPTY_OUT 	=> module_register_data_empty_int,
	MODULE_REGISTER_DATA_COUNT_OUT 	=> module_register_data_count_int,
	REGISTER_MODULE_DATA_COUNT_OUT 	=> register_module_data_count_int,
	START_IN 								=> creg_sync_topixclk(9),
	BUSY_OUT 								=> tpx_inputsm_busy,
	DATALENGTH_IN 							=> tpx_sc_inputsm_serial_data_length,
	RESET_IN 								=> ilreset
);



U_MMCM: entity work.U_MMCM
port map (
	CLKIN			=> CLK66, --
	CLK200		=> CLK200,
	LCLK			=> ilclk,  -- ilclk ebenfalls mit frequenz 66 mhz
	LRESET		=> ilreset,  -- output
	BCLK			=> clk10mhz,
	BRESET		=> open,   -- not locked
	FASTCLOCK	=> open, -- clock500mhz_i,
	FASTCLOCKB	=> open, --clock500mhzb_i,
	FASTCLOCK90	=> open, --clock500mhz90_i,
	FASTCLOCK90B=> open, --clock500mhz90b_i,
	RC_A			=> regadr(4 downto 0),
	RC_DO			=> rc_do,
	RC_DI			=> P_D(15 downto 0),
	RC_WE			=> rc_we,
	RC_START		=> rc_start,  --creg(5),
	RC_CLK		=> topixclock,
	RC_CLK180	=> open, --topixclock180_i,
	RC_RESET		=> drp_busy
);


--U_MMCM: entity work.U_MMCM
--port map (
--	CLKIN			=> CLK66, --BASECLOCK, -- ilclk ist eigentlich baseclock
--	LCLK			=> ilclk,  -- ilclk kommt aus mmcm raus
--	LRESET		=> ilreset,
--	BCLK			=> clk10mhz,
--	BRESET		=> open,   -- not locked
--	RC_A			=> regadr(4 downto 0),
--	RC_DO			=> rc_do,
--	RC_DI			=> P_D(15 downto 0),
--	RC_WE			=> rc_we,
--	RC_START		=> rc_start,  --creg(5),
--	RC_CLK		=> topixclock,
--	RC_CLK180	=> open,
--	RC_RESET		=> drp_busy
--);



rc_we		<= P_REG and P_WR and B2SL(regadr(regadr'high downto 5) = (SM_DRP/32));
rc_start	<= P_REG and P_WR and B2SL(regadr = (SM_DRP+31));

tpx_fifo_din <= tpx_fifodummyreg;

U_DUMMY_DATA: entity work.sm_dummy_data PORT MAP(
		START_IN 			=> creg_sync_topixclk(4),
		CLK_WR_IN 			=> ilclk,
		CLK_RD_IN 			=> topixclock,
		RESET_IN 			=> ilreset,
		EMPTY_OUT 			=> open,
		FULL_OUT 			=> open,
		DATA_COUNT_OUT 	=> tpx_fifo_datacount,
		DATA_IN 				=> tpx_fifo_din,
		DATA_WE_IN 			=> tpx_fifodummywe,
		DATA_OUT 			=> tpx_fifodummydata,
		DATA_DEST_WE_OUT 	=> tpx_fifodummydestwe,
		BUSY_OUT 			=> dummy_data_busy
	);

dma_buffer : entity work.daq_fifo
  PORT MAP (
    rst 				=> ilreset or creg(0),
    wr_clk 			=> topixclock,
    rd_clk 			=> ilclk,
    din 				=> fi_din,
    wr_en 			=> fi_wen,
    rd_en 			=> fi_ren,
    dout 			=> fi_dout,
    full 			=> fi_full,
    empty 			=> fi_empty,
    rd_data_count => fi_datacount,
    prog_full 		=> fi_pfull
  );	

ToPix_data: entity work.u_topix_data PORT MAP(
		CLOCK 						=> topixclock,
		RESET 						=> ilreset,
		BUSY 							=> open,
		TPX_SDR_OUT 				=> TOPIX_SDR_OUT,
		MODULE_FIFO_DATA 			=> topix_fifo_data,
		TPX_DATA_VALID 			=> TOPIX_DATA_VALID,
		TPX_DATA_WAIT 				=> TOPIX_DATA_WAIT,
		MODULE_FIFO_DATA_WR_EN 	=> topix_fifo_data_wr_en
	);

U_ONE_HERTZ_COUNTER : entity work.one_hertz_counter PORT MAP(
		CLK 		=> ilclk,
		COUNTER_OUT => one_hertz_counter_i
	);
U_KNIGHT_RIDER : entity work.knight_rider PORT MAP (
		CLK66		=> ilclk,
		USER_SWITCH	=> USER_SWITCH,
		LED			=> knight_rider_i
	);
	
U_LTC2604: entity work.SM_LTC2604 PORT MAP(
	BUSY 					=> ltcconfbusy,
	LTC_SCK 				=> DAC_SCK,
	LTC_SDI 				=> DAC_SDI,
	LTC_CSLD 			=> DAC_CS_LD,
	CLOCK 				=> clk10mhz,
	RESET 				=> reset_sc_ltc,
	START 				=> creg_sc_ltc,
	FIFO_WR_CLK 		=> ilclk,
	FIFO_WR_EN 			=> ltc_fifowe,
	FIFO_DATA_IN 		=> ltcreg,
	FIFO_DATA_COUNT 	=> ltc_fifo_datacount
);

with led_config select LED <=
	one_hertz_counter_i 								when "00000",		-- 0
	knight_rider_i (7 downto 0)		 			when "00001",		-- 1
	tpx_fifo_datacount(7 downto 0) 				when "00010",		-- 2
	ev_datacount_int(7 downto 0) 					when "00011",		-- 3
	ev_datacount_int(15 downto 8)					when "00100",		-- 4
	ev_datacount_int(17 downto 16)&"011100"	when "00101",		-- 5
	module_register_data_count_int(7 downto 0)when "00110",		-- 6
	register_module_data_count_int(7 downto 0)when "00111",		-- 7
	"11111111" 											when others;

-- ======================================================================= --
--										Control Register and gen timer               --
-- ======================================================================= --

process(clk10mhz)
begin
if rising_edge(clk10mhz) then
	creg_sc_ltc	<= creg(14);
	reset_sc_ltc <= ilreset;
end if;
end process;

process(topixclock) -- belongs to input 
begin
if rising_edge(topixclock) then
	creg_sync_topixclk <= creg;
--	reset_sync_topixclk <= ilreset;
	tpx_sc_inputsm_serial_data_length <= tpx_inputsm_serial_data_length(9 downto 0);
end if;
end process;

--SYS_MODE	<= doorbell_mask;

-- ============================ Write to Register ======================== --
 --process(ilreset, stimer_clr, ilclk)
  process(ilreset, ilclk)
begin

	if ilclk'event and (ilclk = '1') then
	clock_counter <= clock_counter +1;
		if SL2B(P_REG and P_WR) and (regadr = GLS_CONTROL_REGISTER) then
			creg	<=P_D(CREG'range);
		end if;
		if SL2B(P_REG and P_WR) and (regadr = LED_REG) then
			led_config <= P_D(led_config'range);
		end if;
		
		if SL2B(P_REG and P_WR) and (regadr = CHOOSE_DATA_PATH) then
			choose_datapath <= P_D(choose_datapath'range);
		end if;
		
		if SL2B(P_REG and P_WR) and (regadr = FAKE_DATA_INTERVAL) then
			fake_data_generator_interval <= P_D(fake_data_generator_interval'range);
		end if;	
		
		
		if SL2B(P_REG and P_WR) and (regadr = TPX_SDATA_INPUT_REG) then
			register_module_data_int			<= P_D(register_module_data_int'range);
			register_module_data_wr_en_int	<= '1';
		end if;
		if dummy_data_busy ='1' then   -- start dummy data transfer from sm to data fifo
			creg(4) <='0';
		end if;
		if drp_busy ='1'  then
			creg(5)	<= '0';        --start Clockgen Reconfigure
		end if;

		if tpx_inputsm_busy = '1' then
			creg(9) <= '0';
		end if;

		if SL2B(P_REG and P_WR) and (regadr = TPX_FIFODUMMY_REG) then
			tpx_fifodummywe <= '1';
			tpx_fifodummyreg <= P_D(tpx_fifodummyreg'range);
		else
			tpx_fifodummywe <= '0';
		end if;
		
		if SL2B(P_REG and P_WR) and (regadr = LTCREG_SEL) then
			ltc_fifowe <= '1';
			ltcreg <= P_D(ltcreg'range);
		else
			ltc_fifowe <= '0';
		end if;

		if SL2B(P_REG and P_WR) and (regadr = TPX_INPUTCOUNT_REG) then
			tpx_inputsm_serial_data_length <= P_D(9 downto 0);
		end if;

	if SL2B(ilreset) then
		creg						<= (others => '0');
		tpx_fifodummyreg 		<= (others => '0');
		led_config				<= (others => '0');
    end if;
	end if;
end process;

-- ------------------------------------------------------------------------- --
--                                fifodatamux                                --
-- ------------------------------------------------------------------------- --
--process(ilclk)
--begin
--if rising_edge(ilclk) then
--	if SL2B(P_REG and P_WR) and (regadr = GLS_DOORBELL_MASK) then
--		doorbell_mask		<= P_D(doorbell_mask'range);
--		doorbell_mask(1)	<= P_D(1) and not P_D(0); -- warum dieses konstruckt?? Auf (1) liegt fi_valid auf (0) dmd_init
--		-- wenn P_D(0) = 0 (kein dma transfer) liegt an (1) an was auch auf 1 ankommt.
--		-- wenn P_D(0) = 1  liegt an fi_valid immer eine 0 an. Es wird kein doorbell ueber neue Daten im Fifo gesendet.
--		-- (weil die eh sofort ueber dma geholt werden)
--	end if;
--
----	stimer_clr	<= P_REG and P_WR and B2SL(regadr = GLS_TIMER);  -- stimer_clr setzt den Timer zurueck
--
----	if SL2B(P_REG and P_WR) and (regadr = GLS_CONTROL_REGISTER) then
----		creg				<= P_D(CREG'range);
----
----	end if;
--		if SL2B(ilreset) then
--		doorbell_mask		<= (others => '0');
--    end if;
--
--	--if SL2B(ilreset or stimer_clr) then
----		stimer	<= (others => '0');
--	--end if;
--
----	if SL2B(P1MS) then
----		stimer	<= stimer+1;
----	end if;
--
--end if;
--end process;
--
-- ======================================================================= --
--										direct data counter                          --
-- ======================================================================= --
--
--process(ilclk)
--begin
--if rising_edge(ilclk) then
--	dmd_load			<= '0';
--	if SL2B(P_REG and P_WR) and (regadr = GLS_BLKSZ) then
--		dmd_block_sz	<= P_D(dmd_block_sz'range);
--		dmd_load			<= '1';	-- pulse
--	end if;
--
--	if SL2B(ilreset) then
--		dmd_block_sz	<= (others => '0');
--	end if;
--
--	if SL2B(DMD_WR) then
--		dmd_counter	<= dmd_counter	+1;
--	end if;
--
--	if   SL2B(ilreset)
--     or (SL2B(P_REG and P_WR) and (regadr = GLS_DCOUNT)) then
--		dmd_counter	<= (others => '0');
--	end if;
--
--	if SL2B(DMD_WR) then
--		dmd_block	<= dmd_block -1;
--	end if;
--
--	if   SL2B(dmd_load)
--	  or (SL2B(DMD_WR) and (dmd_block = 0)) then
--		dmd_block	<= dmd_block_sz;
--	end if;
--
--	dmd_int	<=    doorbell_mask(0) and DMD_WR
--				  and B2SL((dmd_block_sz /= 0) and (dmd_block = 0));
--end if;
--end process;

-- ======================================================================= --
--										send to host doorbell                        --
-- ======================================================================= --
--
-- dbell_in   0===a===b===
-- dbell_in_d 0=====a===b===
-- dbell_act  ======a===c=====d=======0===
-- HREG_REQ   ________--------__------____
-- HREG_ACK   ______________--______--____
-- dbell_out  ========a=========d=======0=

--dbell_in		<= x"00"							-- 24 free for status bits without interrupt
--				  &x"0000"						--  8
--				  &"0000"						--  4
--				  &(doorbell_mask(3) and s2sec)		--  3
--				  &(doorbell_mask(2) and fi_pfull)	--  2
--				  &(doorbell_mask(1) and fi_valid)	--  1
--				  &dmd_int;						--  0

--process(ilclk)
--begin
--if rising_edge(ilclk) then
--	if SL2B(P100MS) then
--		cnt1sec	<= cnt1sec +1;
--		if (cnt1sec = 10-1) then
--			cnt1sec	<= (others => '0');
--			s2sec		<= not s2sec;
--		end if;
--	end if;
--
--	dbell_act		<=   (dbell_in and not dbell_in_d)
--						  or (dbell_act and not (SL2SLV(HREG_ACK) and dbell_out));
--	dbell_act(31 downto 24)	<= (others => '0');	-- don't send to doorbell, status bits only
--
--	dbell_req	<=   (not dbell_req and B2SL(dbell_act /= 0))
--					  or (dbell_req and not HREG_ACK);
--
--	dbell_in_d	<= dbell_in;
--	if SL2B(not dbell_req) then
--		dbell_out	<= dbell_act;
--	end if;
--
--	if SL2B(ilreset) then
--		dbell_act	<= (others => '0');
--		dbell_req	<= '0';
--	end if;
--end if;
--
---- synopsys translate_off
--if (cnt1sec(0) = 'U') then
--	cnt1sec	<= (others => '0');
--	s2sec		<= '0';
--end if;
---- synopsys translate_on
--end process;

--HREG_REQ	<= dbell_req;
--HREG_A	<= SL2SLV(dbell_req, HREG_A'length) and "0000100";	-- 16#0010# = doorbell
--HREG_D	<= SL2SLV(dbell_req, HREG_D'length) and dbell_out;
--
-- ========================== concurrent assignments ===================== --
--

-- -------------------------- remote access ------------------------------ --
process(ilclk)
begin
if rising_edge(ilclk) then
	s_rdy   <=    P_REG
		and (     B2SL(P_A = SM_DMA_CONTROL )
		or   B2SL(P_A = SM_SR)
		or   B2SL(P_A = SM_BLK_SIZE)
		or   (B2SL(P_A = SM_RO_DATA) and not P_WR));

	rdy_fi				<= P_REG and not P_WR and B2SL(P_A = SM_RO_DATA);
	rdy_fi_d1			<= rdy_fi;
	rdy_sdata_out		<= P_REG and not P_WR and B2SL(regadr = TPX_SDATA_OUTPUT_REG);
	rdy_sdata_out_d1	<= rdy_sdata_out;

end if;
end process;

module_register_data_rd_en_int <= not module_register_data_empty_int and (rdy_sdata_out and not rdy_sdata_out_d1);

--fi_ren	<= not fi_empty and (not fi_valid or blk_rdy or ldt_den or (rdy_fi_d1 and not rdy_fi));
fi_ren	<= not fi_empty and (not fi_valid or blk_rdy or (rdy_fi_d1 and not rdy_fi));

blk_rdy	<=    blk and not blk_zero and not P_WAIT and fi_valid;

--ev_datacount_int <= fi_datacount +('0'&fi_valid);
ev_datacount_int <= fi_datacount;
EV_DATACOUNT <= ev_datacount_int;

--ldt_den	<= DT_ACK and fi_valid;

--DT_DEN	<= ldt_den;
P_END		<= blk and (blk_zero or not fi_valid);

--DT_REQ	<= DMD_DMA and fi_valid;

-- ========================== process for Event Block Transfer =========== --
process(ilreset, P_BLK, ilclk)

begin
	if rising_edge(ilclk) then
		fi_valid		<=   fi_ren
						 -- or (fi_valid and not (blk_rdy or ldt_den or (rdy_fi_d1 and not rdy_fi)));
						  or (fi_valid and not (blk_rdy or (rdy_fi_d1 and not rdy_fi)));

		if SL2B(ilreset) then
			fi_valid	<= '0';
		end if;

	end if;

	if SL2B(not P_BLK) then
		blk			<= '0';
	elsif ilclk'event and (ilclk = '1') then
		blk 			<= P_BLK and B2SL(P_A = SM_RO_DATA);
	end if;

	if rising_edge(ilclk) then
		if SL2B(blk_rdy) then
			blk_cnt	<= blk_cnt -1;
			if (blk_cnt(blk_cnt'high downto 1) = 0) then
				blk_zero	<= '1';
			end if;
		end if;

		if SL2B(P_BLK and not blk) then
			blk_zero		<= '0';
			blk_cnt		<= P_D(blk_cnt'high+2 downto 2);
			if (P_D(31 downto blk_cnt'high+3) /= 0) then
				blk_cnt		<= (others => '1');
			end if;
		end if;
	end if;
end process;

-- ========================================================================== --
--										sample data fifo											--
-- ========================================================================== --

-- fill the DMA constantly with data
-- (comment the upper two lines out and the process below in)
fill_dma_with_counter : process( topixclock )
begin
	if rising_edge( topixclock ) then
		if SL2B(ilreset) then
			fill_dma_counter <= (others => '0');
		elsif ( fi_full = '1' ) then
			fill_dma_counter <= fill_dma_counter;
		else
			fill_dma_counter <= fill_dma_counter - 1;
		end if;
	end if;
end process;
--fi_din <= fill_dma_counter;
--fi_wen <= not fi_full;
-- fill DMA end

--process(ilclk)
--begin
--if rising_edge(ilclk) then
--	if SL2B(P_REG and P_WR) and (P_A = SM_BLK_SIZE) then
--		fi_cnt_max	<= P_D(fi_cnt_max'range);
--	end if;
--	if SL2B(ilreset) then
--		fi_cnt_max	<= (others => '0');
--	end if;
--end if;
--end process;




-- ========================== concurrent assignments ===================== --
FIFO_EMPTY <= fi_empty;
-- ============================ Read from Register ======================= --
P_RDY	<= s_rdy or blk_rdy or
				(P_REG and (   (B2SL(regadr = GLS_IDENT) and not P_WR)
						  or B2SL(regadr = GLS_STATUS_REGISTER)
						--  or B2SL(regadr = GLS_DOORBELL_MASK)
						--  or B2SL(regadr = GLS_TIMER)
						  or B2SL(regadr = GLS_DCOUNT)
						  or B2SL(regadr = GLS_BLKSZ)
						  or B2SL(regadr = GLS_CONTROL_REGISTER)
						  or B2SL(regadr = RB_BUSY_REG)
						  or B2SL(regadr = LTCREG_SEL)
						  or B2SL(regadr = RB_DCMDATA_REG)
						  or B2SL(regadr = TPX_FIFODUMMY_REG)
						  or B2SL(regadr = TPX_INPUTCOUNT_REG)
						  or B2SL(regadr = TPX_SLOW_CTRL)
						  or B2SL(regadr = TPX_SDATA_INPUT_REG)
						  or B2SL(regadr = TPX_TRIGCOUNT_REG)
						  or B2SL(regadr = LED_REG)
						  or B2SL(regadr = TPX_LEDINFOREG)
						  or B2SL(regadr = SM_RO_DATA_COUNT)
						  or B2SL(regadr = TPX_SDATA_OUTPUT_REG)
						  or B2SL(regadr = CHOOSE_DATA_PATH)
						  or B2SL(regadr = FAKE_DATA_INTERVAL)
						  or B2SL(regadr(regadr'high downto 5) = (SM_DRP/32)))		-- MMCM_DRP
						  );

P_D_O_DMA <= 	(    SL2SLV(fi_valid and (   blk --or DT_ACK
	or (s_rdy and not P_WR and B2SL(P_A = SM_RO_DATA)) ),40)  -- P_REG -> s_rdy
			 and fi_dout);

P_D_O <=
			(    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_IDENT))
			 and INT2SLV(SC_VERSION))
		--or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_STATUS_REGISTER))
		--	 and dbell_in)
		--or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_DOORBELL_MASK))
		--	 and EXT2SLV(doorbell_mask))
		or (	  SL2SLV(P_REG and not P_WR and B2SL(regadr = SM_RO_DATA_COUNT))
			 and EXT2SLV(ev_datacount_int))
		--or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_TIMER))
		--	 and stimer)
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = CHOOSE_DATA_PATH))
			 and choose_datapath)
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = FAKE_DATA_INTERVAL))
			 and fake_data_generator_interval)
		--or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_DCOUNT))
		--	 and dmd_counter&"00")
		--or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_BLKSZ))
		--	 and EXT2SLV(dmd_block_sz&"00"))
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_CONTROL_REGISTER))
			 and creg)
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = TPX_SDATA_OUTPUT_REG))
			 and module_register_data_int)
		or (	  SL2SLV(P_REG and not P_WR and B2SL(regadr = LED_REG))
			 and EXT2SLV(led_config))
		or	(    SL2SLV(P_REG and not P_WR and B2SL(P_A = SM_SR))
			 and EXT2SLV(fi_pfull&fi_valid))
	--	or (    SL2SLV(P_REG and not P_WR and B2SL(P_A = SM_BLK_SIZE))
	--		 and EXT2SLV(fi_cnt_max))
		-- the data output register must not be accessable via register read, just by dma due to different word width
		--or (    SL2SLV(not fi_valid and s_rdy and not P_WR and B2SL(P_A = SM_RO_DATA))  -- P_REG -> s_rdy
		--	 and x"EEEEEEEE")

-- ========================== MMCM_DRP ====================================== --
		or (    SL2SLV(    P_REG and not P_WR
						   and B2SL(regadr(regadr'high downto 5) = (SM_DRP/32)))
			 and EXT2SLV(rc_do))
		 ;
end RTL;
