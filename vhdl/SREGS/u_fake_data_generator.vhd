----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:45:23 12/17/2012 
-- Design Name: 
-- Module Name:    fake_data_generator - Behavioral 
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
use IEEE.std_logic_unsigned.all;

use work.util_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity fake_data_generator is
    Port ( CLOCK 				: in  STD_LOGIC;
           ENABLE 			: in  STD_LOGIC;
           INTERVAL	 		: in  STD_LOGIC_VECTOR(31 downto 0);
           FAKE_DATA 		: out STD_LOGIC_VECTOR(39 downto 0);
           REC_WRITE_EN 	: out STD_LOGIC);
end fake_data_generator;

architecture Behavioral of fake_data_generator is

signal counter 			: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal packagecounter 	: std_logic_vector(39 downto 0) := "0000000000000000000000000000000000000000";
signal interval_int		: std_logic_vector(31 downto 0);

begin

fake_generator :  process(CLOCK)
begin
	if rising_edge(CLOCK) then
		counter <= counter + 1;
		if counter >= interval_int then
			interval_int <= INTERVAL;
			counter <= (others => '0');
			REC_WRITE_EN 	<= '1';
			FAKE_DATA		<= packagecounter;
			packagecounter <= packagecounter + 1;
		else
			REC_WRITE_EN 	<= '0';
			
		end if;
	end if;
end process;

end Behavioral;

