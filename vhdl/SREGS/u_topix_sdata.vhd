----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:38:38 01/24/2012 
-- Design Name: 
-- Module Name:    u_topix_datain - Behavioral 
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
use work.util_pack.all;

entity u_topix_sdata is
	Port (
		CLOCK_TOPIX 							: IN	STD_LOGIC;								--! ToPix Clock
		CLOCK_REGISTER							: IN	STD_LOGIC;								--! Clock from register module 
		SDATA_OUT								: OUT	STD_LOGIC;								--! Serial data stream to ToPix
		SDATA_EN_OUT							: OUT	STD_LOGIC;								--! Serial enable
		SDATA_IN									: IN	STD_LOGIC;								--! Serial data stream from ToPix (After a read command)							-- Statemachine sends commands unless valid = 0
		REGISTER_MODULE_DATA_IN				: IN	STD_LOGIC_VECTOR(31 downto 0);	--! Data from register
		MODULE_REGISTER_DATA_OUT			: OUT	STD_LOGIC_VECTOR(31 downto 0);	--! Data to register
		REGISTER_MODULE_DATA_WR_EN_IN		: IN	STD_LOGIC;								--! Enable signal 
		MODULE_REGISTER_DATA_RD_EN_IN		: IN	STD_LOGIC;								--! Enable signal 
		MODULE_REGISTER_DATA_EMPTY_OUT	: OUT	STD_LOGIC;								--! Fifo empty signal 
		MODULE_REGISTER_DATA_COUNT_OUT	: OUT	STD_LOGIC_VECTOR(31 downto 0);	--! Data count of fifo for data coming from ToPix
		REGISTER_MODULE_DATA_COUNT_OUT	: OUT	STD_LOGIC_VECTOR(31 downto 0);	--! Data count of fifo for data going to ToPix
		START_IN									: IN	STD_LOGIC;								--! Start of state machine 
		BUSY_OUT									: OUT	STD_LOGIC;								--! State machine is busy
		DATALENGTH_IN							: IN	STD_LOGIC_VECTOR(9 downto 0);		--! How many bits will be read?	
		RESET_IN									: IN	STD_LOGIC								--! Reset signal 
		);
end u_topix_sdata;

architecture Behavioral of u_topix_sdata is

type serialstate is (s_idle, s_load1, s_load2, s_shift, s_finish, s_go_on, s_wait_1, s_wait_2, s_wait_3,s_wait_4,s_wait_5,s_wait_6,s_wait_7,s_wait_8,s_wait_9,s_wait_10);
signal state									: serialstate;
signal shiftdata								: std_logic_vector(31 downto 0);
signal shiftdata_out 						: std_logic_vector(31 downto 0);
signal counter									: integer range 0 to 300;
signal int_datalength						: integer range 0 to 300;
signal topix_fifo_data						: std_logic_vector(31 downto 0);
signal topix_fifo_data_wr_en				: std_logic;
signal fifo_topix_data						: std_logic_vector(31 downto 0);
signal fifo_topix_data_re_en				: std_logic;
signal fifo_topix_empty						: std_logic;

attribute IOB									: string;
attribute IOB		of SDATA_IN				: signal is "FORCE";
attribute IOB		of SDATA_OUT			: signal is "FORCE";

begin

fifo_topix_sdata_buffer : entity work.sdata_buffer_fifo
	PORT MAP (
		rst				=> RESET_IN,
		wr_clk			=> CLOCK_TOPIX,
		rd_clk			=> CLOCK_REGISTER,
		din				=> REGISTER_MODULE_DATA_IN,
		wr_en				=> REGISTER_MODULE_DATA_WR_EN_IN,
		rd_en				=> fifo_topix_data_re_en,
		dout				=> fifo_topix_data,
		full				=> open,
		empty				=> fifo_topix_empty,
		rd_data_count	=> open,
		wr_data_count	=> REGISTER_MODULE_DATA_COUNT_OUT(9 downto 0)
	);

topix_fifo_sdata_buffer : entity work.sdata_buffer_fifo
	PORT MAP (
		rst				=> RESET_IN,
		wr_clk			=> CLOCK_REGISTER,
		rd_clk			=> CLOCK_TOPIX,
		din				=> topix_fifo_data,
		wr_en				=> topix_fifo_data_wr_en,
		rd_en				=> MODULE_REGISTER_DATA_RD_EN_IN,
		dout				=> MODULE_REGISTER_DATA_OUT,
		full				=> open,
		empty				=> MODULE_REGISTER_DATA_EMPTY_OUT,
		rd_data_count	=> MODULE_REGISTER_DATA_COUNT_OUT(9 downto 0),
		wr_data_count	=> open
	);

int_datalength <= SLV2INT(DATALENGTH_IN);
SDATA_OUT <= shiftdata(int_datalength);
topix_fifo_data <= "0000000000000000" & shiftdata_out(15 downto 0);

DATASHIFTER : process(CLOCK_TOPIX)
begin
	if falling_edge(CLOCK_TOPIX) then
		if RESET_IN = '1' then
			state							<= s_idle;
			BUSY_OUT							<= '0';
			counter						<= 0;
			shiftdata					<= (others => '0');
			shiftdata_out				<= (others => '0');
			topix_fifo_data_wr_en	<= '0';
		else 
			case state is 
			when s_idle =>
				if START_IN ='1' then
					if int_datalength = 0 then
						state							<= s_idle;
						BUSY_OUT							<= '1';
						fifo_topix_data_re_en	<= '0';
						--FIFO_FLUSH <= '1';
					else
						state <=s_load1;
						BUSY_OUT <= '1';
						fifo_topix_data_re_en <= '1';
						--FIFO_FLUSH <= '0';
				end if;
				else
					state <= s_idle;
					BUSY_OUT <= '0';
					fifo_topix_data_re_en <= '0';
				end if;
				shiftdata <= (others => '0');
				shiftdata_out <= (others => '0');
				counter <= 0;
				SDATA_EN_OUT <= '0';
				topix_fifo_data_wr_en <= '0';
			when s_load1 =>
				state <= s_load2;
				counter <= 0;
				SDATA_EN_OUT <= '0';
				shiftdata_out <= (others => '0');
				BUSY_OUT <= '1';
				fifo_topix_data_re_en <= '0';
				--FIFO_FLUSH <= '0';
				topix_fifo_data_wr_en <= '0';
			when s_load2 =>
				state <= s_shift;
				counter <= 0;
				SDATA_EN_OUT <= '1';
				shiftdata(int_datalength downto 0) <= fifo_topix_data(int_datalength downto 0);
				shiftdata_out <= (others => '0');
				BUSY_OUT <= '1';
				fifo_topix_data_re_en <= '0';
				--FIFO_FLUSH <= '0';
				topix_fifo_data_wr_en <= '0';				
			when s_shift =>
				if (counter < int_datalength) then	
					state <= s_shift;
					SDATA_EN_OUT <= '1';
					fifo_topix_data_re_en <= '0';
					--FIFO_FLUSH <= '0';
					counter <= counter + 1;
--					shiftdata <= shiftdata(15 downto 0) & '0';
					shiftdata <= shiftdata(30 downto 0) & '0';
					shiftdata_out <= shiftdata_out(30 downto 0) & SDATA_IN;
				elsif (counter = int_datalength) then 
					state <= s_shift;
					SDATA_EN_OUT <= '0';
					fifo_topix_data_re_en <= '0';
					--FIFO_FLUSH <= '0';
					counter <= counter + 1;
					shiftdata <= shiftdata(30 downto 0) & '0';
					shiftdata_out <= shiftdata_out(30 downto 0) & SDATA_IN;
				else
					state <= s_finish;
					shiftdata <= (others => '0');
					SDATA_EN_OUT <= '0';
					fifo_topix_data_re_en <= '0';
					--FIFO_FLUSH <= '0';
					topix_fifo_data_wr_en <= '1';
					--shiftdata_out <= shiftdata_out(30 downto 0) & SDATA_IN;
				end if;
			when s_finish =>
				state <= s_wait_1;
				topix_fifo_data_wr_en <= '0';
					
			when s_wait_1 =>
				state <= s_wait_2;
			when s_wait_2 =>
				state <= s_wait_3;
			when s_wait_3 =>
				state <= s_wait_4;
			when s_wait_4 =>
				state <= s_wait_5;
			when s_wait_5=>
				state <= s_wait_6;
			when s_wait_6 =>
				state <= s_wait_7;
			when s_wait_7 =>
				state <= s_wait_8;
			when s_wait_8 =>
				state <= s_wait_9;
			when s_wait_9 =>
				state <= s_wait_10;
			when s_wait_10 =>
				state <= s_go_on;
			when s_go_on =>
				if fifo_topix_empty = '1' then
					state <= s_idle;
					BUSY_OUT <= '0';
					--FIFO_FLUSH <= '0';
					shiftdata <= (others =>'0');
				else 
					state <= s_load1;
					BUSY_OUT <= '1';
					fifo_topix_data_re_en <= '1';
					--FIFO_FLUSH <= '0';
					shiftdata <= (others =>'0');
				end if;
				topix_fifo_data_wr_en <= '0';
				counter <= 0;
			end case;
		end if;
	end if;
end process;
end Behavioral;