--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:06:27 07/16/2014
-- Design Name:   
-- Module Name:   /home/ikp1/esch/udp_projekt_kollegen/Andre_UDP_Projekte/ml605_ethernet_udp/testbench/vhdl/SREGS/tb_sm_ltc_2604.vhd
-- Project Name:  ml605_ethernet_udp
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SM_LTC2604
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_sm_ltc_2604 IS
END tb_sm_ltc_2604;
 
ARCHITECTURE behavior OF tb_sm_ltc_2604 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SM_LTC2604
    PORT(
         BUSY : OUT  std_logic;
         LTC_SCK : OUT  std_logic;
         LTC_SDI : OUT  std_logic;
         LTC_CSLD : OUT  std_logic;
         CLOCK : IN  std_logic;
         RESET : IN  std_logic;
         START : IN  std_logic;
         FIFO_WR_CLK : IN  std_logic;
         FIFO_WR_EN : IN  std_logic;
         FIFO_DATA_IN : IN  std_logic_vector(31 downto 0);
         FIFO_DATA_COUNT : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal START : std_logic := '0';
   signal FIFO_WR_CLK : std_logic := '0';
   signal FIFO_WR_EN : std_logic := '0';
   signal FIFO_DATA_IN : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal BUSY : std_logic;
   signal LTC_SCK : std_logic;
   signal LTC_SDI : std_logic;
   signal LTC_CSLD : std_logic;
   signal FIFO_DATA_COUNT : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
   constant FIFO_WR_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SM_LTC2604 PORT MAP (
          BUSY => BUSY,
          LTC_SCK => LTC_SCK,
          LTC_SDI => LTC_SDI,
          LTC_CSLD => LTC_CSLD,
          CLOCK => CLOCK,
          RESET => RESET,
          START => START,
          FIFO_WR_CLK => FIFO_WR_CLK,
          FIFO_WR_EN => FIFO_WR_EN,
          FIFO_DATA_IN => FIFO_DATA_IN,
          FIFO_DATA_COUNT => FIFO_DATA_COUNT
        );

   -- Clock process definitions
   CLOCK_process :process
   begin
		CLOCK <= '0';
		wait for CLOCK_period/2;
		CLOCK <= '1';
		wait for CLOCK_period/2;
   end process;
 
   FIFO_WR_CLK_process :process
   begin
		FIFO_WR_CLK <= '0';
		wait for FIFO_WR_CLK_period/2;
		FIFO_WR_CLK <= '1';
		wait for FIFO_WR_CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLOCK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
