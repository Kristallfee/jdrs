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
-- Description: This module generates fake data with a topix-like bit pattern. 
-- 				There are two modi, one is the continous generation of data with a certain frequency, the other is the generation of a certain amount of data at the same time (single shot)
-- 				For the continuous generationn one can choose between stop the counter if the fifo is full or not. 
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
    Port ( CLOCK_IN 				: in  STD_LOGIC;
           ENABLE_IN 				: in  STD_LOGIC;						--! The counter runs as long as enable is high
           SINGLE_SHOT_IN			: in  STD_LOGIC;						--! Activated the single shot mode (sending of a certain amunt of data)
           NUMBER_SINGLE_SHOT_IN 	: in  STD_LOGIC_VECTOR(31 downto 0);	--! Number of data packages to send in single shot mode. 
           INTERVAL_IN	 			: in  STD_LOGIC_VECTOR(31 downto 0);	--! Interval between data packages in continuous mode. 
           STOP_FIFO_FULL_IN		: in  STD_LOGIC;						--! Stops the counter in case the fifo is full 
           FAKE_DATA_FIFO_FULL_IN 	: in  STD_LOGIC;						--! Fifo full signal from the fifo 
           FAKE_DATA_OUT 			: out STD_LOGIC_VECTOR(39 downto 0);	--! Data out to fifo 	
           FAKE_DATA_WR_EN_OUT 		: out STD_LOGIC);						--! Enable out to fifo 
end fake_data_generator;

architecture Behavioral of fake_data_generator is

signal counter 					: STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
signal packagecounter 			: STD_LOGIC_VECTOR(11 downto 0) := "000000000000";
signal pixeladdresscounter		: STD_LOGIC_VECTOR(13 downto 0) := "00000000000000";
signal interval_int				: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal fake_data_int			: STD_LOGIC_VECTOR(39 downto 0);
signal number_single_shot_int	: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal single_shots_counter		: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal fake_data_wr_en 			: STD_LOGIC;

begin

FAKE_DATA_WR_EN_OUT <= fake_data_wr_en;

fake_generator :  process(CLOCK_IN)
begin
	if rising_edge(CLOCK_IN) then
		if ENABLE_IN ='1' then
			if STOP_FIFO_FULL_IN='1' then
				if FAKE_DATA_FIFO_FULL_IN ='1' then
					counter <= counter;
				else 
					counter <= counter + 1;
				end if;
			else 
				counter <= counter +1;
			end if;

			--counter <= counter + 1;	
			interval_int 						<= INTERVAL_IN;
			if counter >= interval_int then
				
				counter 						<= (others => '0');
				fake_data_wr_en 				<= '1';
			--	FAKE_DATA_OUT					<= packagecounter;
				FAKE_DATA_OUT(39 downto 38) 	<= "11";				-- Package Header data package
				FAKE_DATA_OUT(37 downto 24) 	<= pixeladdresscounter; -- Pixel address
				FAKE_DATA_OUT(23 downto 12) 	<= packagecounter;		-- Leading edge
				FAKE_DATA_OUT(11 downto  0) 	<= packagecounter;		-- Trailing edge 		
				packagecounter 					<= packagecounter + 1;
				pixeladdresscounter				<= pixeladdresscounter +1;
			else
				fake_data_wr_en 			<= '0';
			end if;

		elsif SINGLE_SHOT_IN = '1' then
			single_shots_counter <= x"00000000";
			number_single_shot_int <= NUMBER_SINGLE_SHOT_IN;
			fake_data_wr_en <='0';
			FAKE_DATA_OUT(39 downto 38) 		<= "11";									-- Package Header data package
			FAKE_DATA_OUT(37 downto 24) 		<= "00000001010101"; 						-- Pixel address
			FAKE_DATA_OUT(23 downto 12) 		<= single_shots_counter(11 downto 0);		-- Leading edge
			FAKE_DATA_OUT(11 downto  0) 		<= single_shots_counter(11 downto 0);		-- Trailing edge

		elsif number_single_shot_int >= single_shots_counter then 
			single_shots_counter <= single_shots_counter +1;
			fake_data_wr_en <='1';
			FAKE_DATA_OUT(39 downto 38) 		<= "11";									-- Package Header data package
			FAKE_DATA_OUT(37 downto 24) 		<= "00000001010101"; 						-- Pixel address
			FAKE_DATA_OUT(23 downto 12) 		<= single_shots_counter(11 downto 0);		-- Leading edge
			FAKE_DATA_OUT(11 downto  0) 		<= single_shots_counter(11 downto 0);		-- Trailing edge
		else 
			fake_data_wr_en				<= '0';
		end if;
	else 
		counter 			<= (others => '0');
		packagecounter		<= (others => '0');
		pixeladdresscounter <= (others => '0');

	end if;
end process;

end Behavioral;

