----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    17:12:05 05/05/2011
-- Design Name:
-- Module Name:    U_MMCM - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Clock generator to creat clocks with different frequencies.
-- All outputs have the same multiplicator, but a output has a own divider.
-- One can change the divider while running time via DRP (dynamic reconfiguration port)
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- IF the MMCM module does not work, check these issues:
-- * The ROM Core needs a table of presetted values, loaded with a .coe file. This file might get lost if the 
--   core is copied or modyfied.
--   Make sure that in the core the coe file is loaded with the file "drp_rom.coe"
-- * In the sofware part are the register values calculated. For the right calculation it is necessary to have there
--   the same settings as in this file. Make sure the file "mrfdata_mmcmconf.h" has the same settings like below in this module. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

Library UNISIM;
use UNISIM.vcomponents.all;

use work.util_pack.all;

entity U_MMCM is
Port (
	CLKIN			: in	std_logic;	-- clock 66 MHz from ml605
	CLK200		: in  STD_LOGIC;  -- clock 200 MHz from ml605
	LCLK			: out	std_logic;	-- local clock
	LRESET		: out	std_logic;	-- power on reset
	BCLK			: out	std_logic;	-- MMCM_BASE
	BRESET		: out	std_logic;	-- MMCM startup
	FASTCLOCK	: out STD_LOGIC;	-- 550 MHz
	FASTCLOCKB	: out STD_LOGIC;	-- 550 MHz
	FASTCLOCK90	: out STD_LOGIC;	-- 550 MHz
	FASTCLOCK90B: out STD_LOGIC;	-- 550 MHz
	RC_A			: in	T_SLV5;		-- reconfiguration RAM address
	RC_DO			: out	T_SLV16;		-- data out
	RC_DI			: in	T_SLV16;		-- data in
	RC_WE			: in	std_logic;	-- write enabel
	RC_START		: in	std_logic;
	RC_CLK		: out	std_logic;	-- variable clock
	RC_CLK180	: out	std_logic;	-- variable clock
	RC_RESET		: out	std_logic	-- clock not stable
);
end U_MMCM;


	architecture Behavioral of U_MMCM is

	signal ilclk,ilrun,ilreset	: std_logic;	-- internal local clock
	signal ilclk200				: std_logic;
	signal clkfbout				: std_logic;
	signal clkfbout_buf			: std_logic;
	signal obclk,ibclk			: std_logic;
	signal bclk_lk,obclk_lk		: std_logic;

type T_DRP_STATE is (
	WAIT_LOCK,
	WAIT_START,
	ADDRESS,
	WAIT_A_DRDY,
	WAIT_DRDY
);

	signal drp_state			: T_DRP_STATE;
	signal drp_busy			: std_logic;
	signal drp_rst				: std_logic;
	signal drp_daddr 			: std_logic_vector(6 downto 0);
	signal drp_di	 			: T_SLV16;
	signal drp_rom_a			: T_SLV5;
	signal drp_locked			: std_logic;


	signal speedclock2		: std_logic;
	signal speedclock2b		: std_logic;
	signal speedclock90		: STD_LOGIC;
	signal speedclock90b		: STD_LOGIC;

	signal ram_a				: T_SLV5;
	signal ram_we				: std_logic;
	signal ram_do				: T_SLV16;
	signal rom_do0				: std_logic_vector(22 downto 0);
	signal rom_do				: std_logic_vector(38 downto 0);
	signal drp_den 			: std_logic;
	signal drp_dwe 			: std_logic;
	signal drp_drdy 			: std_logic;
	signal drp_do 				: T_SLV16;

	signal ofbclk,fbclk			: std_logic;
	signal orc_clk,orc_clk180	: std_logic;

component drp_rom
	port (
	a: in std_logic_vector(4 downto 0);
	spo: out std_logic_vector(22 downto 0));
end component;

component drp_ram
	port (
	a: in std_logic_vector(4 downto 0);
	d: in std_logic_vector(15 downto 0);
	clk: in std_logic;
	we: in std_logic;
	spo: out std_logic_vector(15 downto 0));
end component;

begin
LCLK				<= ilclk;
ilreset			<= not ilrun;    -- if the clock starts, ilrun goes from 0 to 1, ilreset goes from 1 to 0
LRESET			<= ilreset;
BCLK				<= ibclk;
BRESET			<= not obclk_lk;
FASTCLOCK 		<= speedclock2;
FASTCLOCKB 		<= speedclock2b;
FASTCLOCK90 	<= speedclock90;
FASTCLOCK90b	<= speedclock90b;

-- ========================================================================== --
--										local 66MHz clock											--
-- ========================================================================== --

U10: IBUFG
port map (
	I => CLKIN,
	O => ilclk
	);

-- U11: IBUFG
-- port map (
-- 	I => CLK200,
-- 	O => ilclk200
-- );

--ilclk200 <= CLK200;


U14: SRL16  -- Shift register
port map (
	D		=> '1',		-- data input
	CLK	=> ilclk,	-- clock
	--CLK	=> ilclk200,
	Q		=> ilrun,  -- Data output
	A3		=> '1',		-- A0 to A3 defines the lenght of the shift register
	A2		=> '1',		-- if A* = 1111, shift register sit 16 bit long
	A1		=> '1',
	A0		=> '1');

-- at startup, the register contains 0x0000. If the clock starts to run, it will be filled with '1'.
-- after 16 clockcycles the data output (Q) changes from 0 to 1.

-- ========================================================================== --
--										alternative clock											--
-- ========================================================================== --

U_MMCM_BASE: MMCM_ADV
generic map (
    BANDWIDTH            => "OPTIMIZED",
    CLKOUT4_CASCADE      => FALSE,
    CLOCK_HOLD           => FALSE,
--    COMPENSATION         => "ZHOLD",
    STARTUP_WAIT         => FALSE,
    DIVCLK_DIVIDE        => 2, --2 (66 MHZ) -- 1 (200 MHz)
    CLKFBOUT_MULT_F      => 27.000, --27 (66 MHZ) -- 5 (200 MHz)
    CLKFBOUT_PHASE       => 0.000,
    CLKFBOUT_USE_FINE_PS => FALSE,
    CLKOUT0_DIVIDE_F     => 89.000, --89 (66 MHZ)-- 100 (200 MHz)
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKOUT0_USE_FINE_PS  => FALSE,
    CLKOUT1_DIVIDE       => 99,		--99
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.500,
    CLKOUT1_USE_FINE_PS  => FALSE,
    CLKOUT2_DIVIDE       => 99,
    CLKOUT2_PHASE        => 0.000,
    CLKOUT2_DUTY_CYCLE   => 0.500,
    CLKOUT2_USE_FINE_PS  => FALSE,
    CLKOUT3_DIVIDE       => 99,
    CLKOUT3_PHASE        => 0.000,
    CLKOUT3_DUTY_CYCLE   => 0.500,
    CLKOUT3_USE_FINE_PS  => FALSE,
    CLKOUT4_DIVIDE       => 99,
    CLKOUT4_PHASE        => 0.000,
    CLKOUT4_DUTY_CYCLE   => 0.500,
    CLKOUT4_USE_FINE_PS  => FALSE,
    CLKOUT5_DIVIDE       => 99,
    CLKOUT5_PHASE        => 0.000,
    CLKOUT5_DUTY_CYCLE   => 0.500,
    CLKOUT5_USE_FINE_PS  => FALSE,
    CLKOUT6_DIVIDE       => 99,
    CLKOUT6_PHASE        => 0.000,
    CLKOUT6_DUTY_CYCLE   => 0.500,
    CLKOUT6_USE_FINE_PS  => FALSE,
    CLKIN1_PERIOD        => 15.1515,
    --CLKIN1_PERIOD			 => 5.000,
	 REF_JITTER1          => 0.010
)
port map (
    -- Output clocks
    CLKFBOUT            => clkfbout,
    CLKFBOUTB           => open,
    CLKOUT0             => obclk,
    CLKOUT0B            => open,
    CLKOUT1             => open,
    CLKOUT1B            => open,
    CLKOUT2             => open,
    CLKOUT2B            => open,
    CLKOUT3             => open,
    CLKOUT3B            => open,
    CLKOUT4             => open,
    CLKOUT5             => open,
    CLKOUT6             => open,
    -- Input clock control
    CLKFBIN             => clkfbout_buf,
    CLKIN1              => ilclk,
    CLKIN2              => ilclk,
    --CLKIN1					=> ilclk200,
	 --CLKIN2					=> ilclk200,

	 -- Tied to always select the primary input clock
    CLKINSEL            => '1',
    -- Ports for dynamic reconfiguration
    DADDR               => "0000000",
    DCLK                => '0',
    DEN                 => '0',
    DI                  => (others => '0'),
    DO                  => open,
    DRDY                => open,
    DWE                 => '0',
    -- Ports for dynamic phase shift
    PSCLK               => '0',
    PSEN                => '0',
    PSINCDEC            => '0',
    PSDONE              => open,
    -- Other control and status signals
    LOCKED              => bclk_lk,
    CLKINSTOPPED        => open,
    CLKFBSTOPPED        => open,
    PWRDWN              => '0',
    RST                 => '0'
);

U0_BUFG: BUFG
port map (
    O => clkfbout_buf,
    I => clkfbout
);

U1_BUFG: BUFG
port map (
    O   => ibclk,
    I   => obclk
);

U0_SRL16: SRL16
port map (
	D		=> bclk_lk,
	CLK	=> ibclk,
	Q		=> obclk_lk,
	A3		=> '1',
	A2		=> '1',
	A1		=> '1',
	A0		=> '1');

-- ========================================================================== --
--										dynamische einstellbare clock							--
-- ========================================================================== --

U_DRP_ROM: drp_rom
port map (
	a => drp_rom_a,
	spo => rom_do0
);

U_DRP_RAM: drp_ram
port map (
	a => ram_a,
	d => RC_DI,
	clk => ilclk,
	--clk => ilclk200,
	we => ram_we,
	spo => ram_do
);

ram_a		<= drp_rom_a when SL2B(drp_busy) else RC_A;
ram_we	<= not drp_busy and RC_WE;
RC_DO		<= ram_do;

RC_RESET	<= drp_busy;

process(ilclk) begin
--process(ilclk200) begin
if rising_edge(ilclk) then
--if rising_edge(ilclk200) then
	rom_do		<= rom_do0&ram_do;
	drp_den		<= '0';
	drp_dwe		<= '0';

	case drp_state is
when WAIT_LOCK =>
		drp_rst		<= '0';
		if SL2B(drp_locked) then
			drp_state 	<= WAIT_START;
		end if;

when WAIT_START =>
		drp_busy		<= '0';
		drp_rom_a	<= (others => '0');
		if SL2B(RC_START) then
			drp_busy		<= '1';
			drp_rst		<= '1';
			drp_state 	<= ADDRESS;
		end if;

when ADDRESS =>
		drp_den		<= '1';
		drp_daddr	<= rom_do(38 downto 32);
		drp_state 	<= WAIT_A_DRDY;

when WAIT_A_DRDY =>
		if SL2B(drp_drdy) then
			drp_di		<= (drp_do and rom_do(31 downto 16)) or rom_do(15 downto 0);
			drp_rom_a	<= drp_rom_a +1;
			drp_den		<= '1';
			drp_dwe		<= '1';
			drp_state 	<= WAIT_DRDY;
		end if;

when WAIT_DRDY =>
		if SL2B(drp_drdy) then
			drp_state	<= ADDRESS;
			if (drp_rom_a = 23) then
				drp_state	<= WAIT_LOCK;
			end if;
		end if;

	end case;

	if (ilreset = '1') then
		drp_busy		<= '1';
		drp_rst		<= '1';
		drp_state	<= WAIT_LOCK;
	end if;
end if;
end process;


  -- MMCM_ADV: Advanced Mixed Mode Clock Manager
   --           Virtex-6
   -- Xilinx HDL Language Template, version 13.1

MMCM_ADV_inst : MMCM_ADV
generic map (
    BANDWIDTH            => "OPTIMIZED",
    CLKOUT4_CASCADE      => FALSE,
    CLOCK_HOLD           => FALSE,
--    COMPENSATION         => "ZHOLD",
    STARTUP_WAIT         => FALSE,
    DIVCLK_DIVIDE        => 1,			-- Topix 50 MHz: 2 - ToPix 150 MHz 1
    CLKFBOUT_MULT_F      => 6.000,		-- Topix 50 MHz: 8 - ToPix 150 MHz 6
    CLKFBOUT_PHASE       => 0.000,
    CLKFBOUT_USE_FINE_PS => FALSE,
    CLKOUT0_DIVIDE_F     => 8.000,		-- Topix 50 MHz: 16 - ToPix 150 MHz 8
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKOUT0_USE_FINE_PS  => FALSE,
    CLKOUT1_DIVIDE       => 3,     		--- Topix 50 MHz: 2 - ToPix 150 MHz 3
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.500,
    CLKOUT1_USE_FINE_PS  => FALSE,
    CLKOUT2_DIVIDE       => 3,     		-- 450 MHz
    CLKOUT2_PHASE        => 90.000,
    CLKOUT2_DUTY_CYCLE   => 0.500,
    CLKOUT2_USE_FINE_PS  => FALSE,
    CLKOUT3_DIVIDE       => 22,
    CLKOUT3_PHASE        => 0.000,
    CLKOUT3_DUTY_CYCLE   => 0.500,
    CLKOUT3_USE_FINE_PS  => FALSE,
    CLKOUT4_DIVIDE       => 22,
    CLKOUT4_PHASE        => 0.000,
    CLKOUT4_DUTY_CYCLE   => 0.500,
    CLKOUT4_USE_FINE_PS  => FALSE,
    CLKOUT5_DIVIDE       => 22,
    CLKOUT5_PHASE        => 0.000,
    CLKOUT5_DUTY_CYCLE   => 0.500,
    CLKOUT5_USE_FINE_PS  => FALSE,
    CLKOUT6_DIVIDE       => 22,
    CLKOUT6_PHASE        => 0.000,
    CLKOUT6_DUTY_CYCLE   => 0.500,
    CLKOUT6_USE_FINE_PS  => FALSE,
    --CLKIN1_PERIOD        => 15.1515,
    CLKIN1_PERIOD        => 5.000,
    REF_JITTER1          => 0.010
)
port map (
    -- Output clocks
    CLKFBOUT            => ofbclk,
    CLKFBOUTB           => open,
    CLKOUT0             => orc_clk,
    CLKOUT0B            => orc_clk180,
    CLKOUT1             => speedclock2,
    CLKOUT1B            => speedclock2b,
    CLKOUT2             => speedclock90,
    CLKOUT2B            => speedclock90b,
    CLKOUT3             => open,
    CLKOUT3B            => open,
    CLKOUT4             => open,
    CLKOUT5             => open,
    CLKOUT6             => open,
    -- Input clock control
    CLKFBIN             => fbclk,
    --CLKIN1              => ilclk,
    --CLKIN2              => ilclk,
    CLKIN1              => CLK200, --ilclk200,
    CLKIN2              => CLK200, --ilclk200,
    -- Tied to always select the primary input clock
    CLKINSEL            => '1',
    -- Ports for dynamic reconfiguration
    DADDR               => drp_daddr,
    DCLK                => ilclk,
    --DCLK                => ilclk200,
    DEN                 => drp_den,
    DI                  => drp_di,
    DO                  => drp_do,
    DRDY                => drp_drdy,
    DWE                 => drp_dwe,
    -- Ports for dynamic phase shift
    PSCLK               => '0',
    PSEN                => '0',
    PSINCDEC            => '0',
    PSDONE              => open,
    -- Other control and status signals
    LOCKED              => drp_locked,
    CLKINSTOPPED        => open,
    CLKFBSTOPPED        => open,
    PWRDWN              => '0',
    RST                 => drp_rst
);

U2_BUFG: BUFG
port map (
    O => fbclk,
    I => ofbclk
);

U3_BUFG: BUFG
port map (
    O   => RC_CLK,
    I   => orc_clk
);

U4_BUFG: BUFG
port map (
    O   => RC_CLK180,
    I   => orc_clk180
);

end Behavioral;
