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
	LCLK				: out std_logic;
	BASECLOCK			: in  std_logic;	--! 125 MHz
	CLK66				: in  std_logic; 	--! 66 MHz
	CLK200				: in  std_logic;	--! 200 MHz
	RESET_IN 			: in  std_logic;
	GRESET   			: out std_logic;	-- general reset
	LED					: out std_logic_vector(7 downto 0);
	USER_SWITCH			: in  std_logic_vector(4 downto 0);
	
-- ----------------------- DAC ----------------------------------------- --  	
	DAC_SDI   			: out std_logic;
	DAC_CLR   			: out std_logic;
	DAC_SCK   			: out std_logic;
	DAC_CS_LD 			: out std_logic;
--	-------------------------- local bus zum GIGALink Teil ---------------- --
	P_REG				: in  std_logic;								--! Signal fuer Registerzugriffe
	P_WR				: in  std_logic;								--! write
	P_A					: in  std_logic_vector(12 downto 2);	--! address
	P_D					: in  T_SLV32;									--! data - byte count is swapped
	P_D_O				: out T_SLV32;									--! data out
	P_D_O_DMA			: out T_SLV40;									--! data out dma
	P_RDY				: out std_logic;								--! data ready
	P_BLK				: in  std_logic;								--! always read
	P_WAIT				: in  std_logic;								--! pause block read
	P_END				: out std_logic;								--! block end
-- -------------------------- ToPix Signals ---------------------------- --
	TOPIX_DATA_WAIT		: out std_logic;
	TOPIX_DATA_VALID	: in  std_logic;
	TOPIX_SDR_OUT		: in  std_logic;
	TOPIX_RESET_OUT		: out std_logic;
	TPX_TESTP_OUT			: out std_logic;
	TPX_SDATA_IN		: out std_logic;
	TPX_SDATA_EN		: out std_logic;
	TPX_SDATA_OUT		: in  std_logic;
	TPX_CLOCK			: out std_logic;
	TPX_EOC_IN			: in  std_logic;
	TPX_SEU_FSM_IN		: in  STD_LOGIC;
	TPX_SEU_REG_IN		: in  STD_LOGIC;
	TPX_BUSY_IN			: in  STD_LOGIC;
	TPX_DDR_OUT_IN		: in  STD_LOGIC;

--	-------------------------- control signals ---------------------------- --
	EV_DATACOUNT		: out std_logic_vector(31 downto 0);
	FIFO_EMPTY  		: out std_logic
);
end SREGS;

architecture RTL of SREGS is

-- ======================================================================= --
--										    Signals                                  --
-- ======================================================================= --
	alias regadr									: std_logic_vector(8 downto 0) is P_A(10 downto 2);
	signal creg										: T_SLV32;
	signal creg_sync_topixclk						: std_logic_vector(31 downto 0);
	signal tpx_fifodummyreg							: std_logic_vector(31 downto 0);
	signal tpx_fifodummydata						: std_logic_vector(31 downto 0);
	signal tpx_fifo_din								: std_logic_vector(31 downto 0);
	signal tpx_fifo_datacount						: std_logic_vector(9 downto 0);
	signal tpx_fifodummywe							: std_logic;
	signal dummy_data_busy							: std_logic;
	signal tpx_inputsm_busy							: std_logic;
	signal tpx_fifodummydestwe						: std_logic;
	signal led_config								: std_logic_vector(4 downto 0);
	signal one_hertz_counter_i						: std_logic_vector(7 downto 0);
	signal knight_rider_i							: std_logic_vector(7 downto 0);
	signal ilclk,ilreset							: std_logic;

-- ========================== MMCM_DRP ====================================== --
	signal rc_do									: T_SLV16;
	signal rc_we,rc_start							: std_logic;
	signal drp_busy									: std_logic;
	signal s_rdy									: std_logic;		-- single ready (no block)
	signal rdy_fi,rdy_fi_d1							: std_logic;
	signal fi_count,fi_cnt_max						: T_SLV10;
	signal fi_wen									: std_logic;
	signal fi_ren									: std_logic;
	signal fi_empty,fi_full							: std_logic;
	signal fi_pfull									: std_logic;		-- 3/4
	signal fi_datacount								: std_logic_vector(31 downto 0);
	signal fi_din_dummy								: std_logic_vector(31 downto 0);
	signal fi_din,fi_dout         					: std_logic_vector(39 downto 0);
	signal fi_valid									: std_logic;
	signal fill_dma_counter       					: std_logic_vector(39 downto 0);
	signal blk										: std_logic;
	signal blk_rdy									: std_logic;
	signal blk_cnt									: std_logic_vector(17 downto 0);	-- lword count, 1MB
	signal blk_zero									: std_logic;	-- zero
	signal ev_datacount_int		   					: std_logic_vector(31 downto 0);
-- ========================== Clocks ====================================== --	
	signal clk10mhz									: std_logic;

-- ========================== ToPix  ====================================== --	
	signal tpx_busy 								: std_logic;
	signal tpx_eoc 									: std_logic;
	signal topixslowreg							: std_logic_vector(31 downto 0);


-- ==========================  Misc  ====================================== --
	signal ltcconfbusy								: std_logic;
	signal reset_sc_ltc								: std_logic;
	signal creg_sc_ltc								: std_logic;
	signal ltc_fifowe								: std_logic;
	signal ltcreg									: std_logic_vector(31 downto 0);
	signal ltc_fifo_datacount						: std_logic_vector(9 downto 0);

	signal register_module_data_int					: std_logic_vector(31 downto 0);
	signal module_register_data_int					: std_logic_vector(31 downto 0);
	signal register_module_data_wr_en_int			: std_logic;
	signal module_register_data_rd_en_int			: std_logic;
	signal rdy_sdata_out							: std_logic;
	signal rdy_sdata_out_d1							: std_logic;
	signal module_register_data_empty_int			: std_logic;
	signal module_register_data_count_int 			: std_logic_vector(31 downto 0);
	signal register_module_data_count_int			: std_logic_vector(31 downto 0);

	signal tpx_inputsm_serial_data_length			: std_logic_vector(9 downto 0);
	signal tpx_sc_inputsm_serial_data_length 		: std_logic_vector(9 downto 0);
	signal topixclock								: std_logic;

	signal fake_data_generator_wr_en 				: std_logic;
	signal fake_data_generator_data  				: std_logic_vector(39 downto 0);
	signal fake_data_generator_single_shot_number 	: std_logic_vector(31 downto 0);

	signal topix_fifo_data							: std_logic_vector(39 downto 0);
	signal topix_fifo_data_wr_en					: std_logic;
	signal fake_data_generator_interval 			: std_logic_vector(31 downto 0);
	signal choose_datapath   						: std_logic_vector(31 downto 0);
	
	signal fifo_reset 								: std_logic;
	signal topixclock_reset							: std_logic;
	signal topix_data_wait_int						: std_logic;
	
-- ======================================================================= --
--										       Begin                                 --
-- ======================================================================= --

begin

-- ======================================================================= --
--						            Components Port Map                          --
-- ======================================================================= --
LCLK			<= ilclk;
GRESET			<= ilreset;
TPX_CLOCK		<= topixclock;
TOPIX_RESET_OUT <= creg(1);
tpx_busy 		<= TPX_BUSY_IN;
tpx_eoc 		<= TPX_EOC_IN;

--U_FAKE_DATA_GENERATOR: entity work.fake_data_generator PORT MAP(
--	CLOCK 			=> topixclock,
--	ENABLE 			=> creg_sync_topixclk(10),
--	INTERVAL 		=> fake_data_generator_interval,
--	FAKE_DATA 		=> fake_data_generator_data,
--	REC_WRITE_EN 	=> fake_data_generator_wr_en
--);

U_FAKE_DATA_GENERATOR: entity work.fake_data_generator PORT MAP(
	CLOCK_IN 				=> topixclock,
	ENABLE_IN 				=> creg_sync_topixclk(10),
	SINGLE_SHOT_IN 			=> creg_sync_topixclk(11),
	NUMBER_SINGLE_SHOT_IN 	=> fake_data_generator_single_shot_number,
	INTERVAL_IN 			=> fake_data_generator_interval,
	STOP_FIFO_FULL_IN		=> creg_sync_topixclk(12),
    FAKE_DATA_FIFO_FULL_IN 	=> fi_full,
	FAKE_DATA_OUT 			=> fake_data_generator_data,
	FAKE_DATA_WR_EN_OUT 	=> fake_data_generator_wr_en
);




fi_din <= 	topix_fifo_data 					when choose_datapath(1 downto 0) ="00" else
				fill_dma_counter				when choose_datapath(1 downto 0) ="01" else
				"00000000"&tpx_fifodummydata 	when choose_datapath(1 downto 0) ="10" else
				fake_data_generator_data		when choose_datapath(1 downto 0) ="11" else
				topix_fifo_data;
fi_wen <= 	topix_fifo_data_wr_en 				when choose_datapath(1 downto 0) ="00" else
				not fi_full						when choose_datapath(1 downto 0) ="01" else
				tpx_fifodummydestwe			 	when choose_datapath(1 downto 0) ="10" else
				fake_data_generator_wr_en		when choose_datapath(1 downto 0) ="11" else
				topix_fifo_data_wr_en;





ToPix_sdata: entity work.u_topix_sdata 
PORT MAP(
	CLOCK_TOPIX 					=> topixclock,
	CLOCK_REGISTER 					=> ilclk,
	SDATA_OUT 						=> TPX_SDATA_IN,
	SDATA_EN_OUT	 				=> TPX_SDATA_EN,
	SDATA_IN 						=> TPX_SDATA_OUT,
	REGISTER_MODULE_DATA_IN 		=> register_module_data_int,
	MODULE_REGISTER_DATA_OUT 		=> module_register_data_int,
	REGISTER_MODULE_DATA_WR_EN_IN 	=> register_module_data_wr_en_int,
	MODULE_REGISTER_DATA_RD_EN_IN 	=> module_register_data_rd_en_int,
	MODULE_REGISTER_DATA_EMPTY_OUT 	=> module_register_data_empty_int,
	MODULE_REGISTER_DATA_COUNT_OUT 	=> module_register_data_count_int,
	REGISTER_MODULE_DATA_COUNT_OUT 	=> register_module_data_count_int,
	START_IN 						=> creg_sync_topixclk(9),
	BUSY_OUT 						=> tpx_inputsm_busy,
	DATALENGTH_IN 					=> tpx_sc_inputsm_serial_data_length,
	RESET_IN 						=> ilreset
);

U_MMCM: entity work.U_MMCM
port map (
	CLK66_IN			=> CLK66,
	CLK200_IN			=> CLK200,
	LCLK_OUT			=> ilclk,  -- ilclk ebenfalls mit frequenz 66 mhz
	LRESET_OUT			=> ilreset,  -- output
	CLKBASE_OUT			=> clk10mhz,
	BRESET_OUT			=> topixclock_reset,   -- topixclock lock signal 
	FASTCLOCK_OUT		=> open, -- clock500mhz_i,
	FASTCLOCKB_OUT		=> open, --clock500mhzb_i,
	FASTCLOCK90_OUT		=> open, --clock500mhz90_i,
	FASTCLOCK90B_OUT	=> open, --clock500mhz90b_i,
	RC_A_IN				=> regadr(4 downto 0),
	RC_DO_OUT			=> rc_do,
	RC_DI_IN	 		=> P_D(15 downto 0),
	RC_WE_IN			=> rc_we,
	RC_START_IN			=> rc_start,  --creg(5),
	CLKVAR_OUT			=> topixclock,
	CLKVAR180_OUT		=> open, --topixclock180_i,
	CLKVAR_NOTSTABLE_OUT=> drp_busy
--	CLKIN			=> CLK66, --
--	CLK200			=> CLK200,
--	LCLK			=> ilclk,  -- ilclk ebenfalls mit frequenz 66 mhz
--	LRESET			=> ilreset,  -- output
--	BCLK			=> clk10mhz,
--	BRESET			=> topixclock_reset,   -- topixclock lock signal 
--	FASTCLOCK		=> open, -- clock500mhz_i,
--	FASTCLOCKB		=> open, --clock500mhzb_i,
--	FASTCLOCK90		=> open, --clock500mhz90_i,
--	FASTCLOCK90B	=> open, --clock500mhz90b_i,
--	RC_A			=> regadr(4 downto 0),
--	RC_DO			=> rc_do,
--	RC_DI			=> P_D(15 downto 0),
--	RC_WE			=> rc_we,
--	RC_START		=> rc_start,  --creg(5),
--	RC_CLK			=> topixclock,
--	RC_CLK180		=> open, --topixclock180_i,
--	RC_RESET		=> drp_busy
);


TPX_TESTP_OUT <= topixslowreg(1);

TOPIX_DATA_WAIT <= topix_data_wait_int or not topixslowreg(0);

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
		DATA_COUNT_OUT 		=> tpx_fifo_datacount,
		DATA_IN 			=> tpx_fifo_din,
		DATA_WE_IN 			=> tpx_fifodummywe,
		DATA_OUT 			=> tpx_fifodummydata,
		DATA_DEST_WE_OUT 	=> tpx_fifodummydestwe,
		BUSY_OUT 			=> dummy_data_busy
	);



fifo_reset  <= ilreset or creg(0);


dma_buffer : entity work.daq_fifo
	PORT MAP (
    	rst 			=> fifo_reset,
    	wr_clk 			=> topixclock,
    	rd_clk 			=> ilclk,
    	din 			=> fi_din,
    	wr_en 			=> fi_wen,
    	rd_en 			=> fi_ren,
    	dout 			=> fi_dout,
    	full 			=> fi_full,
    	empty 			=> fi_empty,
    	rd_data_count 	=> fi_datacount(17 downto 0),
   		prog_full 		=> fi_pfull
    );	

ToPix_data: entity work.u_topix_data 
	PORT MAP(
		CLOCK 					=> topixclock,
		RESET 					=> topixclock_reset,
		BUSY 					=> open,
		TPX_SDR_OUT 			=> TOPIX_SDR_OUT,
		MODULE_FIFO_DATA 		=> topix_fifo_data,
		TPX_DATA_VALID 			=> TOPIX_DATA_VALID,
		TPX_DATA_WAIT 			=> topix_data_wait_int,
		MODULE_FIFO_DATA_WR_EN 	=> topix_fifo_data_wr_en
	);

U_ONE_HERTZ_COUNTER : entity work.one_hertz_counter PORT MAP(
	CLK 			=> ilclk,
	COUNTER_OUT 	=> one_hertz_counter_i
);

U_KNIGHT_RIDER : entity work.knight_rider PORT MAP (
	CLK66			=> ilclk,
	USER_SWITCH		=> USER_SWITCH,
	LED				=> knight_rider_i
);
	
U_LTC2604: entity work.SM_LTC2604 PORT MAP(
	BUSY 			=> ltcconfbusy,
	LTC_SCK 		=> DAC_SCK,
	LTC_SDI 		=> DAC_SDI,
	LTC_CSLD 		=> DAC_CS_LD,
	CLOCK 			=> clk10mhz,
	RESET 			=> reset_sc_ltc,
	START 			=> creg_sc_ltc,
	FIFO_WR_CLK 	=> ilclk,
	FIFO_WR_EN 		=> ltc_fifowe,
	FIFO_DATA_IN 	=> ltcreg,
	FIFO_DATA_COUNT	=> ltc_fifo_datacount
);

with led_config select LED <=
	one_hertz_counter_i 						when "00000",		-- 0
	knight_rider_i (7 downto 0)		 			when "00001",		-- 1
	tpx_fifo_datacount(7 downto 0) 				when "00010",		-- 2
	ev_datacount_int(7 downto 0) 				when "00011",		-- 3
	ev_datacount_int(15 downto 8)				when "00100",		-- 4
	ev_datacount_int(17 downto 16)&"011100"		when "00101",		-- 5
	module_register_data_count_int(7 downto 0)	when "00110",		-- 6
	register_module_data_count_int(7 downto 0)	when "00111",		-- 7
	tpx_busy & tpx_eoc & creg(1) & "00000"				when "01000",		-- 8
	ltc_fifo_datacount(7 downto 0) 			when "01001", 

	"11111111" 									when others;

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

-- ============================ Write to Register ======================== --

  process(ilreset, ilclk)
begin

	if ilclk'event and (ilclk = '1') then
		if SL2B(P_REG and P_WR) and (regadr = GLS_CONTROL_REGISTER) then
			creg	<=P_D(CREG'range);
		end if;
		if SL2B(P_REG and P_WR) and (regadr = LED_REG) then
			led_config <= P_D(led_config'range);
		end if;
		
		if SL2B(P_REG and P_WR) and (regadr = TPX_SLOW_CTRL) then
			topixslowreg <= P_D(topixslowreg'range);
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
		else 
			register_module_data_wr_en_int	<= '0';
		end if;
		if dummy_data_busy ='1' then   -- start dummy data transfer from sm to data fifo
			creg(4) <='0';
		end if;
		if ltcconfbusy ='1' then   -- if ltc sm is started reset start signal 
			creg(14) <='0';
		end if;

		if drp_busy ='1'  then
			creg(5)	<= '0';        --start Clockgen Reconfigure
		end if;

		if SL2B(P_REG and P_WR) and (regadr = FAKE_DATA_GENERATOR_SINGLE_SHOT_NUMBER) then
			fake_data_generator_single_shot_number <= P_D(fake_data_generator_single_shot_number'range);
		end if ;

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
		creg				    <= (others => '0');
		tpx_fifodummyreg 		<= (others => '0');
		led_config				<= (others => '0');
		choose_datapath 		<= (others => '0');
		fake_data_generator_interval<= (others => '0');
		register_module_data_int<= (others => '0');
		tpx_fifodummyreg        <= (others => '0');
    end if;
	end if;
end process;
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

fi_ren	<= not fi_empty and (not fi_valid or blk_rdy or (rdy_fi_d1 and not rdy_fi));

blk_rdy	<=    blk and not blk_zero and not P_WAIT and fi_valid;

ev_datacount_int <= fi_datacount +('0'&fi_valid);
--ev_datacount_int <= fi_datacount;
EV_DATACOUNT <= ev_datacount_int;

P_END		<= blk and (blk_zero or not fi_valid);

-- ========================== process for Event Block Transfer =========== --
process(ilreset, P_BLK, ilclk)

begin
	if rising_edge(ilclk) then
		fi_valid		<=   fi_ren
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
fill_dma_with_counter : process( topixclock )
begin
	if rising_edge( topixclock ) then
		if SL2B(topixclock_reset) then
			fill_dma_counter <= (others => '0');
		elsif ( fi_full = '1' ) then
			fill_dma_counter <= fill_dma_counter;
		else
			fill_dma_counter <= fill_dma_counter - 1;
		end if;
	end if;
end process;
-- fill DMA end


-- ========================== concurrent assignments ===================== --
FIFO_EMPTY <= fi_empty;
-- ============================ Read from Register ======================= --
P_RDY	<= s_rdy or blk_rdy or
				(P_REG and (   (B2SL(regadr = GLS_IDENT) and not P_WR)
						  or B2SL(regadr = GLS_STATUS_REGISTER)
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
						  or B2SL(regadr = FAKE_DATA_GENERATOR_SINGLE_SHOT_NUMBER)
						  or B2SL(regadr(regadr'high downto 5) = (SM_DRP/32)))		-- MMCM_DRP
						  );

P_D_O_DMA <= 	(    SL2SLV(fi_valid and (   blk --or DT_ACK
	or (s_rdy and not P_WR and B2SL(P_A = SM_RO_DATA)) ),40)  -- P_REG -> s_rdy
			 and fi_dout);

P_D_O <=
			(    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_IDENT))
			 and INT2SLV(SC_VERSION))
		or (	  SL2SLV(P_REG and not P_WR and B2SL(regadr = SM_RO_DATA_COUNT))
			 and EXT2SLV(ev_datacount_int))
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = CHOOSE_DATA_PATH))
			 and choose_datapath)
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = TPX_SLOW_CTRL))
			 and topixslowreg)			 
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = FAKE_DATA_INTERVAL))
			 and fake_data_generator_interval)
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = TPX_INPUTCOUNT_REG))
			 and EXT2SLV(tpx_inputsm_serial_data_length))	 
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = GLS_CONTROL_REGISTER))
			 and creg)
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = FAKE_DATA_GENERATOR_SINGLE_SHOT_NUMBER))
			and fake_data_generator_single_shot_number)
		or (    SL2SLV(P_REG and not P_WR and B2SL(regadr = TPX_SDATA_OUTPUT_REG))
			 and module_register_data_int)
		or (	  SL2SLV(P_REG and not P_WR and B2SL(regadr = LED_REG))
			 and EXT2SLV(led_config))
		or	(    SL2SLV(P_REG and not P_WR and B2SL(P_A = SM_SR))
			 and EXT2SLV(fi_pfull&fi_valid))

-- ========================== MMCM_DRP ====================================== --
		or (    SL2SLV(    P_REG and not P_WR
						   and B2SL(regadr(regadr'high downto 5) = (SM_DRP/32)))
			 and EXT2SLV(rc_do))
		 ;
end RTL;