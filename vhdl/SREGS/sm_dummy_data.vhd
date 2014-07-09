----------------------------------------------------------------------------------
-- Company:  IKP 1 FZ Juelich 
-- Engineer:  Simone Esch 
-- 
-- Create Date:    15:07:27 06/27/2011 
-- Design Name: 
-- Module Name:    sm_dummy_data - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:	SM to save dummy data in a FIFO and transfer it on demand at once to output fifo.
--						The dummy FIFO can be filled via writing a register. 
--
--						The FIFO is a First-Word-Fall-Through Fifo. No readout latency
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

--! @file
--! @brief SM to create dummy data 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sm_dummy_data is
    Port ( 	START_IN 			: IN  	STD_LOGIC; --! START OF DATA TRANSFER FROM DUMMY_FIFO TO OUTPUT FIFO 
				CLK_WR_IN			: IN 		STD_LOGIC;
				CLK_RD_IN			: IN 		STD_LOGIC;
				RESET_IN				: IN 		STD_LOGIC;
				EMPTY_OUT			: OUT 	STD_LOGIC;
				FULL_OUT				: OUT 	STD_LOGIC;
				DATA_COUNT_OUT 	: OUT    STD_LOGIC_VECTOR(9 DOWNTO 0);
				DATA_IN 				: IN  	STD_LOGIC_VECTOR(31 DOWNTO 0);
				DATA_WE_IN			: IN 		STD_LOGIC;
				DATA_OUT 			: OUT  	STD_LOGIC_VECTOR(31 DOWNTO 0);
				DATA_DEST_WE_OUT	: OUT 	STD_LOGIC;
				BUSY_OUT 			: OUT  	STD_LOGIC);
end sm_dummy_data;

architecture Behavioral of sm_dummy_data is


signal fifo_read_enable 					: std_logic;
signal fifo_empty 							: std_logic;
signal fifo_data_count						: std_logic_vector(9 downto 0);
signal fifo_full								: std_logic;
signal fifo_destination_write_enable 	: std_logic;
type transferstate is (idle, transfer);

signal state		      : transferstate;

begin

-- daten per din werden auf signal von data_write_enable in den fifo geschrieben. 

-- transfer von dummy daten aus dummy fifo in daten fifo 

EMPTY_OUT 			<= fifo_empty;
FULL_OUT				<= fifo_full;
DATA_DEST_WE_OUT 	<= fifo_destination_write_enable; -- and not fifo_empty;
DATA_COUNT_OUT 	<= fifo_data_count;
	
dummy_data : entity work.dumm_fifo
  PORT MAP (
    rst 				=> RESET_IN,
    wr_clk 			=> CLK_WR_IN,
    rd_clk 			=> CLK_RD_IN,
    din 				=> DATA_IN,
    wr_en 			=> DATA_WE_IN,
    rd_en 			=> fifo_read_enable,
    dout 			=> DATA_OUT,
    full 			=> fifo_full,
    empty 			=> fifo_empty,
    rd_data_count => fifo_data_count
  );	
	
DUMMY: process(CLK_RD_IN)
	begin
		if rising_edge(CLK_RD_IN) then
			if RESET_IN = '1' then
				state         <= idle;
				BUSY_OUT          <= '0';
				fifo_read_enable <=  '0';

			else  case state is

				when idle =>
					if START_IN = '1' then
						state <= transfer;
						fifo_read_enable <= '1';
						fifo_destination_write_enable <= '0';
						BUSY_OUT <= '1';
					else 
						BUSY_OUT <='0';
						fifo_read_enable <= '0';
						fifo_destination_write_enable <= '0';
						state <= state;
					end if;
				when transfer =>
					if fifo_empty = '0' then 
						state <= transfer; 
						fifo_read_enable <= '1';
						fifo_destination_write_enable <= '1';
						BUSY_OUT <= '1';
					else 
						state <= idle;
						fifo_read_enable <= '0';
						fifo_destination_write_enable <= '0';
						BUSY_OUT <= '0';
					end if;
				end case;
			end if;
		end if;
	end process;
end Behavioral;

