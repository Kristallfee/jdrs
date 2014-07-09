----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    11:38:35 05/31/2012
-- Design Name:
-- Module Name:    topl - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

-- needed for SREGS stuff
use work.util_pack.all;
use work.sample_package.all;


entity topl is
  port (
    -- asynchronous reset
    GLBL_RST            : in  std_logic;

    -- 200MHz clock input from board
    CLK_IN_P            : in  std_logic;  		--! Differential on-board 200 MHz clock
    CLK_IN_N            : in  std_logic;			--! Differential on-board 200 MHz clock

    -- 66MHz clock input from board
    CLK66               : in  std_logic;			--! Single-ended on-board 66 MHz clock

    -- 125MHz GTX clock
    -- MGTREFCLK_N         : in  std_logic;
    -- MGTREFCLK_P         : in  std_logic;

    PHY_RESETN          : out std_logic;
    SM_FAN_PWM          : out std_logic;

    -- LCD  interface
    ------------------
    SF_D                : out std_logic_vector(3 downto 0); --! LCD data bus
    LCD_E               : out std_logic;              --! LCD: E   (control bit)
    LCD_RS              : out std_logic;              --! LCD: RS  (setup or data)
    LCD_RW              : out std_logic;              --! LCD: R/W (read or write)

    -- GMII Interface
    -----------------

    GMII_TXD            : out std_logic_vector(7 downto 0);
    GMII_TX_EN          : out std_logic;
    GMII_TX_ER          : out std_logic;
    GMII_TX_CLK         : out std_logic;
    GMII_RXD            : in  std_logic_vector(7 downto 0);
    GMII_RX_DV          : in  std_logic;
    GMII_RX_ER          : in  std_logic;
    GMII_RX_CLK         : in  std_logic;
    GMII_COL            : in  std_logic;
    GMII_CRS            : in  std_logic;
    MII_TX_CLK          : in  std_logic;

-- -------------------------- ToPix Signals ------------------------------ --
	FMC_LPC_CLK1_M2C_P	: in   std_logic;  -- tsensor_clk  !!!ToDo signalrichtung ueberpruefen
--	FMC_LPC_CLK1_M2C_N	: in   std_logic;	 -- 

	FMC_LPC_CLK0_M2C_P   : in   std_logic;  -- tsensor_sio  !!!ToDo signalrichtung ueberpruefen
-- FMC_LPC_CLK0_M2C_N   : in   std_logic;  -- 		

	FMC_LPC_LA00_CC_P		: out  std_logic;  -- clk_ext+
	FMC_LPC_LA00_CC_N		: out  std_logic;	 -- clk_ext-

--	FMC_LPC_LA01_CC_P		: out  std_logic;
--	FMC_LPC_LA01_CC_N		: out  std_logic;
	
	FMC_LPC_LA02_P			: out  std_logic;	 -- tsensor_cs
--	FMC_LPC_LA02_N			: out  std_logic;	 -- 

	FMC_LPC_LA03_P			: out  std_logic;	 -- testp_h
	FMC_LPC_LA03_N			: out  std_logic;	 -- testp_l

	FMC_LPC_LA04_P			: in  std_logic;  -- eoc+
	FMC_LPC_LA04_N			: in  std_logic;  -- eoc-

--	FMC_LPC_LA05_P			: in  std_logic;  -- 
--	FMC_LPC_LA05_N			: in  std_logic;  -- 
	
--	FMC_LPC_LA06_P			: in  std_logic;  -- 
--	FMC_LPC_LA06_N			: in  std_logic;  -- 

	FMC_LPC_LA07_P			: in  std_logic;  -- seu_fsm+
	FMC_LPC_LA07_N			: in  std_logic;  -- seu_fsm-

	FMC_LPC_LA08_P			: in   std_logic;  -- seu_reg+
	FMC_LPC_LA08_N			: in   std_logic;	 -- seu_reg-

	FMC_LPC_LA11_P			: out   std_logic;  -- data_wait+
	FMC_LPC_LA11_N			: out   std_logic;  -- data_wait-

	FMC_LPC_LA12_P			: in   std_logic;	 -- busy+
	FMC_LPC_LA12_N			: in   std_logic;  -- busy-

	FMC_LPC_LA15_P			: in   std_logic;  -- ddr_out+
	FMC_LPC_LA15_N			: in   std_logic;  -- ddr_out-

	FMC_LPC_LA16_P			: in  std_logic;  -- data_valid+
	FMC_LPC_LA16_N			: in  std_logic;  -- data_valid-

	FMC_LPC_LA19_P			: in  std_logic;  -- serial_out+
	FMC_LPC_LA19_N			: in  std_logic;  -- serial_out-

	FMC_LPC_LA20_P			: in  std_logic;  -- sdr_out+
	FMC_LPC_LA20_N			: in  std_logic;  -- sdr_out-

	FMC_LPC_LA21_P			: out  std_logic;  -- serial_in+
	FMC_LPC_LA21_N			: out  std_logic;  -- serial_in-

	FMC_LPC_LA22_P			: out  std_logic;  -- serial_en+
	FMC_LPC_LA22_N			: out  std_logic;  -- serial_en-
	
	FMC_LPC_LA24_P			: out  std_logic;  -- cnt_rst+
	FMC_LPC_LA24_N			: out  std_logic;  -- cnt_rst-

	FMC_LPC_LA25_P			: out  std_logic;  -- clock+
	FMC_LPC_LA25_N			: out  std_logic;  -- clock-

	FMC_LPC_LA28_P			: out  std_logic;  -- dac_sdi
--	FMC_LPC_LA28_N			: out  std_logic;  -- 

	FMC_LPC_LA29_P			: out  std_logic;  -- reset+
	FMC_LPC_LA29_N			: out  std_logic;  -- reset-

	FMC_LPC_LA30_P			: out  std_logic;  -- dac_sck
--	FMC_LPC_LA30_N			: out  std_logic;  -- 

	FMC_LPC_LA31_P			: out  std_logic;  -- dac_clr
--	FMC_LPC_LA31_N			: out  std_logic;  -- 

	FMC_LPC_LA32_P			: out  std_logic;  -- rst_ext+  !!!ToDo signalrichtung ueberpruefen
	FMC_LPC_LA32_N			: out  std_logic;  -- rst_ext-  !!!ToDo signalrichtung ueberpruefen

	FMC_LPC_LA33_P			: out  std_logic;  -- dac_cs_ld
--	FMC_LPC_LA33_N			: out  std_logic;  -- 

--	FMC_LPC_CLK0_M2C_P	: out  std_logic;  -- 
--	FMC_LPC_CLK0_M2C_N	: out  std_logic;  -- 

--	FMC_HPC_LA02_N			: out  std_logic;	 -- Debug Signale on HPC
--	FMC_HPC_LA02_P			: out  std_logic;
--
--	FMC_HPC_LA04_N			: out  std_logic;
--	FMC_HPC_LA04_P			: out  std_logic;
--
--	FMC_HPC_LA07_N			: out  std_logic;
--	FMC_HPC_LA07_P			: out  std_logic;
--
--	FMC_HPC_LA05_N			: out  std_logic;
--	FMC_HPC_LA05_P			: out  std_logic;
--
--	FMC_HPC_LA06_N			: out  std_logic;
--	FMC_HPC_LA06_P			: out  std_logic;
--
--	FMC_HPC_LA11_N			: out  std_logic;
--	FMC_HPC_LA11_P			: out  std_logic;
--
--	FMC_HPC_LA15_N			: out  std_logic;
--	FMC_HPC_LA15_P			: out  std_logic;
--
--	FMC_HPC_LA19_N			: out  std_logic;
--	FMC_HPC_LA19_P			: out  std_logic;
--
--	FMC_HPC_LA03_N			: out std_logic;
--	FMC_HPC_LA03_P			: out std_logic;
--
--	FMC_HPC_LA28_N			: out std_logic;
--	FMC_HPC_LA28_P			: out std_logic;
--
--	FMC_HPC_LA00_CC_N		: out std_logic;
--	FMC_HPC_LA00_CC_P		: out std_logic;


    -- Serialised statistics vectors
    --------------------------------
  --  TX_STATISTICS_S     : out std_logic;
  --  RX_STATISTICS_S     : out std_logic;

    -- Serialised Pause interface controls
    --------------------------------------
    PAUSE_REQ_S         : in  std_logic;

    -- Design controls and output
    -------------------------------
    USER_LED            : out std_logic_vector (7 downto 0);  	--! 8 GPIO LEDs
    USER_SWITCH         : in  std_logic_vector (4 downto 0)		--! 8 GPIO Switches
  );
end topl;

architecture Behavioral of topl is

  signal refclk_bufg    : std_logic;
  signal gtx_clk_bufg   : std_logic;
  signal clk_locked     : std_logic;
  signal clk_50         : std_logic;

  signal pulse_1ms      : std_logic;
  signal pulse_100ms    : std_logic;

  -- the register information bus
  signal register_access        : std_logic;
  signal register_access_ready  : std_logic;
  signal register_write_or_read : std_logic; -- 0: read, 1: write
  signal register_addr          : std_logic_vector(15 downto 0);
  signal register_read_data     : std_logic_vector(31 downto 0);
  signal register_read_data_DMA : std_logic_vector(39 downto 0);
  signal register_write_data    : std_logic_vector(31 downto 0);
  signal register_dma           : std_logic;
  signal register_dma_wait      : std_logic;
  signal register_dma_end       : std_logic;
  signal register_dma_empty     : std_logic;
  signal register_dma_count     : std_logic_vector(17 downto 0);
  -- signal register_dt_ack       : std_logic;

  -- LCD stuff
  constant lcd_mode_default : std_logic_vector(2 downto 0) := "001";
  signal lcd_ctrl           : std_logic_vector(2 downto 0);
  signal lcd_mode           : std_logic_vector(2 downto 0) := lcd_mode_default;
  signal lcd_db             : std_logic_vector(7 downto 4);

  -- ouput for the LCD
  signal temp_int           : std_logic_vector(7 downto 0);
  signal temp_adc_int       : std_logic_vector(9 downto 0);
  signal fan_speed_int      : std_logic_vector(5 downto 0);
  signal udp_pkg_ctr        : std_logic_vector(31 downto 0);

  -- make the register information visible on the LCD for some clock cycles
  constant lcd_enable_register_display    : std_logic := '1';
  constant register_display_counter_max   : integer := 125000000*2;
  signal register_display_counter         : integer range 0 to register_display_counter_max := 0;
  signal register_display_counter_enable  : std_logic := '0';
  signal register_display_counter_running : std_logic := '0';

  -- register buffer signals, since the information
  -- should be visible on the LCD more than a clock cycle
  signal register_addr_buf          : std_logic_vector(11 downto 0);
  signal register_write_or_read_buf : std_logic; -- 0: read, 1: write
  signal register_data_buf          : std_logic_vector(31 downto 0);

  -- buffer the register information a while until SREGS is finished
--  constant sregs_buffer_counter_max     : integer := 125000; -- 1ms
--  signal sregs_buffer_counter         : integer range 0 to sregs_buffer_counter_max := 0;
--  signal sregs_buffer_active          : std_logic;
--  signal sregs_buffer_enable          : std_logic;
--  signal sregs_buffer_register_access     : std_logic;
--  signal sregs_buffer_write_or_read     : std_logic;
--  signal sregs_buffer_address         : std_logic_vector(7 downto 0);
--  signal sregs_buffer_write_data        : std_logic_vector(31 downto 0);

   -- SREGS signals
   signal sregs_clk            : std_logic;
 --  signal sys_mode             : std_logic_vector(15 downto 0);
   signal sregs_regaddr        : std_logic_vector(12 downto 2);
   alias regadr                : std_logic_vector(8 downto 0) is sregs_regaddr(10 downto 2);

   signal test_display_int     : std_logic;
   signal test_display_output  : std_logic;

	signal DAC_SDI					: std_logic;
	signal DAC_SCK					: std_logic;
	signal DAC_CLR					: std_logic;
	signal DAC_CS_LD				: std_logic;
	
	signal clk200					: std_logic;
	signal topix_testp			: std_logic;
	signal topix_eoc				: std_logic;
	signal topix_data_wait		: std_logic;
	signal topix_busy				: std_logic;
	signal topix_seu_reg			: std_logic;
	signal topix_seu_fsm			: std_logic;
	signal topix_serial_in		: std_logic;
	signal topix_serial_out 	: std_logic;
	signal topix_serial_en   	: std_logic;	
	signal topix_cnt_rst			: std_logic;
	signal topix_data_valid		: std_logic;
	signal topix_reset			: std_logic;
	signal topix_sdr_out	 		: std_logic;
	signal topix_clock	 		: std_logic;	
	signal topix_ddr_out			: std_logic;
	signal lreset					: std_logic;	
	signal topix_reset		: std_logic;

begin

	FMC_LPC_LA02_P <= '0';

  ------------------------------------------------------------------------------
  -- ToPix Differential buffers
  ------------------------------------------------------------------------------
	
	OBUFDS_ext_clock :  OBUFDS
	port map(
	I => '0',
	O => FMC_LPC_LA00_CC_P,
	OB => FMC_LPC_LA00_CC_N
	);
	
	
	topix_testp <= '0';
	
	OBUFDS_testp :  OBUFDS
	port map(
	I =>  topix_testp,
	O => FMC_LPC_LA03_P,
	OB => FMC_LPC_LA03_N
	);
	
	IBUFDS_eoc : IBUFDS
	port map(
	O => topix_eoc,
	I => FMC_LPC_LA04_P,
	IB => FMC_LPC_LA04_N
	);

	IBUFDS_seu_fsm : IBUFDS
	port map(
	O => topix_seu_fsm,
	I => FMC_LPC_LA07_P,
	IB => FMC_LPC_LA07_N
	);

	IBUFDS_seu_reg : IBUFDS
	port map(
	O => topix_seu_reg,
	I => FMC_LPC_LA08_P,
	IB => FMC_LPC_LA08_N
	);
	
	OBUFDS_data_wait :  OBUFDS
	port map(
	I =>  topix_data_wait,
	O => FMC_LPC_LA11_P,
	OB => FMC_LPC_LA11_N
	);
	
	IBUFDS_busy : IBUFDS
	port map(
	O => topix_busy,
	I => FMC_LPC_LA12_P,
	IB => FMC_LPC_LA12_N
	);
	
	IBUFDS_ddr_out : IBUFDS
	port map(
	O => topix_ddr_out,
	I => FMC_LPC_LA15_P,
	IB => FMC_LPC_LA15_N
	);
	
	topix_data_valid <= '0';
	
	IBUFDS_data_vaild : IBUFDS
	port map(
	O => open,
	I => FMC_LPC_LA16_P,
	IB => FMC_LPC_LA16_N
	);

	IBUFDS_serial_out : IBUFDS
	port map(
	O => topix_serial_out,
	I => FMC_LPC_LA19_P,
	IB => FMC_LPC_LA19_N
	);

	IBUFDS_sdr_out : IBUFDS
	port map(
	O => topix_sdr_out,
	I => FMC_LPC_LA20_P,
	IB => FMC_LPC_LA20_N
	);

	OBUFDS_serial_in :  OBUFDS
	port map(
	I => topix_serial_in,
	O => FMC_LPC_LA21_P,
	OB => FMC_LPC_LA21_N
	);

	OBUFDS_serial_en :  OBUFDS
	port map(
	I => topix_serial_en,
	O => FMC_LPC_LA22_P,
	OB => FMC_LPC_LA22_N
	);
	
	topix_cnt_rst <= '0';
	
	OBUFDS_cnt_rst :  OBUFDS
	port map(
	I => topix_cnt_rst,
	O => FMC_LPC_LA24_P,
	OB => FMC_LPC_LA24_N
	);
	
	OBUFDS_clock :  OBUFDS
	port map(
	I => topix_clock,
	O => FMC_LPC_LA25_P,
	OB => FMC_LPC_LA25_N
	);
	
	topix_reset <= lreset or topix_reset;
	
	OBUFDS_reset :  OBUFDS
	port map(
	I => topix_reset,
	O => FMC_LPC_LA29_P,
	OB => FMC_LPC_LA29_N
	);
	
		OBUFDS_ext_reset :  OBUFDS
	port map(
	I => '0',
	O => FMC_LPC_LA32_P,
	OB => FMC_LPC_LA32_N
	);

  ------------------------------------------------------------------------------
  -- ToPix DAC
  ------------------------------------------------------------------------------
	
	FMC_LPC_LA28_P <= DAC_SDI;
   FMC_LPC_LA31_P <= not (lreset or DAC_CLR);
   FMC_LPC_LA30_P <= DAC_SCK;
	FMC_LPC_LA33_P <= DAC_CS_LD;
	
  ------------------------------------------------------------------------------
  -- Clock generator
  ------------------------------------------------------------------------------

  CLOCK_GENERATOR : entity work.clk_wiz_v3_3
  port map (
    -- Clock in ports
    CLK_IN_P      => CLK_IN_P,
    CLK_IN_N      => CLK_IN_N,

    -- Clock out ports
    CLK_OUT_200   => refclk_bufg,
    CLK_OUT_125   => gtx_clk_bufg, --gtx_clk_bufg,
    CLK_OUT_50    => clk_50,

    -- Status and control signals
    RESET         => GLBL_RST,
    LOCKED        => clk_locked
  );

  -- REFCLK_GTX_IBUFDS : IBUFDS_GTXE1
  -- port map (
  --   O     => gtx_clk_bufg,
  --   ODIV2 => open,
  --   CEB   => '0',
  --   I     => MGTREFCLK_P,
  --   IB    => MGTREFCLK_N
  -- );



  ------------------------------------------------------------------------------
  -- Fan regulator
  ------------------------------------------------------------------------------

  FAN_REGULATOR : entity work.fan_regulator
  port map (
    CLK           => clk_50,
    RESET         => GLBL_RST,
    FAN_PWM       => SM_FAN_PWM,

    TEMP_OUT      => temp_int,
    TEMP_ADC_OUT  => temp_adc_int,
    FAN_SPEED_OUT => fan_speed_int
  );


  ------------------------------------------------------------------------------
  -- LCD control module
  ------------------------------------------------------------------------------

  LCD_CONTROL : entity work.lcd_control
  port map (
    RST           => GLBL_RST,
    CLK           => clk_50,
    MODE          => lcd_mode,
    CONTROL       => lcd_ctrl,  -- LCD_RS, LCD_RW, LCD_E
    SF_D          => lcd_db,    -- LCD data bus

    TEMP_IN       => temp_int,
    TEMP_ADC_IN   => temp_adc_int,
    FAN_SPEED_IN  => fan_speed_int,

    REGISTER_ADDR           => register_addr_buf,
    REGISTER_WRITE_OR_READ  => register_write_or_read_buf,
    REGISTER_DATA           => register_data_buf,

    UDP_PKG_CTR   => udp_pkg_ctr
  );

  -- control signals for the lcd
  SF_D <= LCD_DB;
  LCD_E <= LCD_CTRL(0);
  LCD_RW <= LCD_CTRL(1);
  LCD_RS <= LCD_CTRL(2);


  -- a command for the register came in, display it on the LCD
  display_register_set : process ( gtx_clk_bufg, GLBL_RST, register_access, register_access_ready, register_display_counter_running, register_write_or_read )
  begin
    if ( register_write_or_read = '1' ) then
      register_display_counter_enable <= register_display_counter_running or register_access;
    else
      register_display_counter_enable <= register_display_counter_running or register_access_ready;
    end if;


    if rising_edge( gtx_clk_bufg ) then

      -- a global reset came in
      if ( GLBL_RST = '1' ) then
        lcd_mode <= lcd_mode_default;
        register_display_counter <= 0;
        register_display_counter_running <= '0';

        register_addr_buf <= (others => '0');
        register_write_or_read_buf <= '0';
        register_data_buf <= (others => '0');

      -- the display of the register command is active
      elsif ( lcd_enable_register_display = '1' and register_display_counter_enable = '1' ) then
        lcd_mode <= "011";

        if ( register_display_counter = register_display_counter_max ) then
          register_display_counter <= 0;
          register_display_counter_running <= '0';
        else
          if ( register_display_counter = 0 ) then
            register_addr_buf <= register_addr(11 downto 0); --sregs_regaddr (9 downto 2);--register_addr;
            register_write_or_read_buf <= register_write_or_read;
            if ( register_write_or_read = '1' ) then
              register_data_buf <= register_write_data;
            else
              register_data_buf <= register_read_data;
            end if;
          end if;

          register_display_counter_running <= '1';
          register_display_counter <= register_display_counter + 1;
        end if;

      -- fall back to displaying the default
      else
        lcd_mode <= lcd_mode_default;
      end if;
    end if;

  end process;


  ------------------------------------------------------------------------------
  -- Ethernet wrapper
  ------------------------------------------------------------------------------

  ETH_WRAPPER : entity work.ethernet_core_wrapper
  port map (

    -- asynchronous reset
    GLBL_RST      => GLBL_RST,

    -- input clocks from generator
    REFCLK_BUFG   => refclk_bufg,
    GTX_CLK_BUFG  => gtx_clk_bufg,
    DCM_LOCKED    => clk_locked,

    PHY_RESETN    => PHY_RESETN,

    -- GMII Interface
    -----------------
    GMII_TXD      => GMII_TXD,
    GMII_TX_EN    => GMII_TX_EN,
    GMII_TX_ER    => GMII_TX_ER,
    GMII_TX_CLK   => GMII_TX_CLK,
    GMII_RXD      => GMII_RXD,
    GMII_RX_DV    => GMII_RX_DV,
    GMII_RX_ER    => GMII_RX_ER,
    GMII_RX_CLK   => GMII_RX_CLK,
    GMII_COL      => GMII_COL,
    GMII_CRS      => GMII_CRS,
    MII_TX_CLK    => MII_TX_CLK,

    -- Serialised statistics vectors
    --------------------------------
   -- TX_STATISTICS_S => TX_STATISTICS_S,
   -- RX_STATISTICS_S => RX_STATISTICS_S,

    -- Serialised Pause interface controls
    --------------------------------------
    PAUSE_REQ_S     => PAUSE_REQ_S,

    -- Main example design controls
    -------------------------------
    DISPLAY         => open, --USER_LED,
    RX_PKG_CTR      => udp_pkg_ctr,

    REGISTER_ACCESS         => register_access,
    REGISTER_ADDR           => register_addr,
    REGISTER_READ_READY     => register_access_ready,
    REGISTER_WRITE_OR_READ  => register_write_or_read,
    REGISTER_READ_DATA      => register_read_data,
	 REGISTER_READ_DATA_DMA	 => register_read_data_DMA,
    REGISTER_WRITE_DATA     => register_write_data,
    REGISTER_DMA            => register_dma,
    REGISTER_DMA_WAIT       => register_dma_wait,
    REGISTER_DMA_END        => register_dma_end,
    REGISTER_DMA_EMPTY      => register_dma_empty,
    REGISTER_DMA_COUNT      => register_dma_count,
    REGISTER_CLK            => sregs_clk

  );




  ------------------------------------------------------------------------------
  -- SREGS register control
  ------------------------------------------------------------------------------

--  PULSE_EVERY_1MS : entity work.pulse_every
--  generic map (
--    CLOCK_CYCLES_PER_PULSE  => 50000
--  )
--  port map (
--    CLK   => clk_50,
--    RST   => GLBL_RST,
--    PULSE => pulse_1ms
--  );
--
--  PULSE_EVERY_100MS : entity work.pulse_every
--  generic map (
--    CLOCK_CYCLES_PER_PULSE  => 100
--  )
--  port map (
--    CLK   => pulse_1ms,
--    RST   => GLBL_RST,
--    PULSE => pulse_100ms
--  );

  -- dma_register_read : process ( CLK66 )
  -- begin
  --  if rising_edge( CLK66 ) then
  --    if ( register_addr = x"0400" ) then
  --      register_dt_ack <= register_access_ready;
  --    else
  --      register_dt_ack <= '0';
  --    end if;
  --  end if;
  -- end process;


  -- get rid of the first and last bits of the address
  -- (equivalent to dividing by 4)
  sregs_regaddr <= register_addr(12 downto 2);

  U_SREGS : entity work.SREGS
  generic map (
    SC_VERSION  => SC_VERSION
  )
  port map (
    LCLK        => sregs_clk,
    BASECLOCK   => gtx_clk_bufg,--CLK66,
    CLK66       => CLK66, -- a direct clock connection is needed for the MMCM
    GRESET      => open,  -- a reset from the SREGS
   -- P1MS        => pulse_1ms,
    LED         => USER_LED,
    USER_SWITCH => USER_SWITCH,

  -- ----------------------- DAC ----------------------------------------- --  
	DAC_SDI   =>   DAC_SDI,
	DAC_CLR   =>   DAC_CLR,
	DAC_SCK   =>   DAC_SCK,
	DAC_CS_LD =>   DAC_CS_LD,
  -- -------------------------- local bus to communication port ------------- --
    P_REG       	=> register_access,
    P_WR        	=> register_write_or_read,
    P_A        	=> sregs_regaddr,
    P_D         	=> register_write_data,
    P_D_O       	=> register_read_data,
	 P_D_O_DMA   	=> register_read_data_DMA,
    P_RDY       	=> register_access_ready,
    P_BLK       	=> register_dma,
    P_WAIT     	=> register_dma_wait,
    P_END       	=> register_dma_end,

  -- ----------------------- ToPix ----------------------------------------- --
	TOPIX_DATA_WAIT	=>		topix_data_wait,
	TOPIX_DATA_VALID	=>		topix_data_valid,
	TOPIX_SDR_OUT		=>		topix_sdr_out,
	TOPIX_RESET_OUT	=> 	topix_reset,

	 TPX_SDATA_IN	=> topix_serial_in,
	 TPX_SDATA_EN	=> topix_serial_en,
	 TPX_SDATA_OUT	=> topix_serial_out,
	 TPX_CLOCK		=> topix_clock,
	 
    --DMD_DMA     	=> sys_mode(0),
    EV_DATACOUNT  => register_dma_count, --ev_datacount,

  -- -------------------------- direct block transfer ----------------------- --
--    DT_REQ      	=> open, --p_dt_req,
 --   DT_ACK      	=> '0', --register_dt_ack, --p_dt_ack,
--    DT_DEN      	=> open, --p_dt_den,
    FIFO_EMPTY  	=> register_dma_empty --fifo_empty_i,

  -- -------------------------- write to Host register request -------------- --
 --   HREG_REQ    	=> open, --hreg_req,
 --   HREG_A      	=> open, --hreg_a,
 --   HREG_D      	=> open, --hreg_d,
  --  HREG_ACK    	=> '0', --hreg_ack,

  -- -------------------------- control/status ------------------------------ --
   -- SYS_MODE    	=> sys_mode,

  -- -------------------------- host doorbell ------------------------------- --
   -- P100MS      	=> pulse_100ms,
  --  DMD_WR      	=> '0' --p_dt_den
  );

  test_display_int <= (register_access and register_write_or_read) and
                B2SL(regadr = std_logic_vector(to_unsigned(LED_REG, regadr'length)) );

  Test_Display : entity work.led_eine_sec
  port map (
    CLK       => gtx_clk_bufg,
    TRIGGER   => test_display_int,
    LED_TEST  => open,
    LED_OUT   => test_display_output
  );

  --USER_LED(0) <= test_display_output;
  --USER_LED(7 downto 1) <= (others => '0');


end Behavioral;

