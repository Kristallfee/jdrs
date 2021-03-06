----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:15:30 01/20/2012 
-- Design Name: 
-- Module Name:    u_topix_dataout - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity u_topix_data is
	Port ( CLOCK					: in	STD_LOGIC;
			RESET					: in	STD_LOGIC;
			BUSY					: out 	STD_LOGIC;
			TPX_SDR_OUT				: in  	STD_LOGIC;
			MODULE_FIFO_DATA		: out  	STD_LOGIC_VECTOR (39 downto 0);
			TPX_DATA_VALID 			: in  	STD_LOGIC;
			TPX_DATA_WAIT 			: out  	STD_LOGIC;
			MODULE_FIFO_DATA_WR_EN 	: out  	STD_LOGIC);
end u_topix_data;

architecture Behavioral of u_topix_data is

type dataoutstate is(s_idle, s_reading);
signal data 			: std_logic_vector(39 downto 0);
signal counter			: integer range 0 to 40;
signal state			: dataoutstate;

attribute IOB			: string;
attribute IOB			of TPX_SDR_OUT	: signal is "FORCE";

attribute S        : string;
attribute S of data : signal is "true";
attribute S of counter : signal is "true";
attribute S of MODULE_FIFO_DATA : signal is "true";
attribute S of MODULE_FIFO_DATA_WR_EN : signal is "true";

begin

TPX_DATA_WAIT <= '0';

DATA_OUT_0 :process(CLOCK)
begin
	if falling_edge(CLOCK) then
		if RESET = '1' then
			state <= s_idle;
			BUSY	<= '0';
			counter <= 0;
			data 	<= (others => '0');
			MODULE_FIFO_DATA <= (others => '0');
			MODULE_FIFO_DATA_WR_EN <= '0';
		else
			case state is 
			when s_idle =>
				if TPX_DATA_VALID = '1' then
					state <= s_reading;
					BUSY	<= '1';
					data <= "000000000000000000000000000000000000000" & TPX_SDR_OUT;
					counter <= 1;
				else	
					state <= s_idle;
					BUSY	<= '0';
				end if;
				MODULE_FIFO_DATA_WR_EN <= '0';
			when s_reading =>
				if counter < 40 then 
					state <= s_reading;
					data <= data(38 downto 0) & TPX_SDR_OUT;
					counter <= counter + 1;
					MODULE_FIFO_DATA_WR_EN <= '0';
					BUSY	<= '1';
				elsif counter = 40 then
					state <= s_idle;
					counter <= 0;
					BUSY	<= '0';
					MODULE_FIFO_DATA_WR_EN <= '1';
					MODULE_FIFO_DATA <= data;
				else
					state <= s_idle;
					counter <= 0;
					BUSY	<= '0';
					MODULE_FIFO_DATA_WR_EN <= '0';
					MODULE_FIFO_DATA <= (others=>'0');
					data <= (others => '0');
				end if;
	--		when s_finish_reading =>
	--			MODULE_FIFO_DATA_WR_EN <= '0';
	--			data <= (others=>'0');
	--			state <= s_idle;
	--			counter <= 0;
	--			BUSY	<= '0';
			end case;
		end if;
	end if;
end process;
				

end Behavioral;

