library ieee;
use ieee.std_logic_1164.all;
use work.util_pack.all;
use work.sample_package.all;

entity Testbench is
end Testbench;

architecture fake_data_generator of Testbench is

signal clock_topix_150mhz			: STD_LOGIC;
signal enable 						: STD_LOGIC;
signal fake_data 					: STD_LOGIC_VECTOR(39 downto 0);
signal fake_data_wr_en 				: STD_LOGIC;
signal single_shot 					: STD_LOGIC;
signal interval 					: STD_LOGIC_VECTOR(31 downto 0);
signal number_single_shot 			: STD_LOGIC_VECTOR(31 downto 0);

begin

clock_150mhz : process
begin
clock_topix_150mhz <= '0';
wait for 3.33333 ns;
clock_topix_150mhz <= '1';
wait for 3.33333 ns;  
end process clock_150mhz;

Main : process 

begin  

number_single_shot 	<= x"00000005";
interval 			<= x"00000002";	
enable 				<= '0';
single_shot 		<= '0';


	wait for 20 ns;

	enable <= '1';

	wait for 200 ns;

	enable <= '0';

	wait for 20 ns;

	single_shot <= '1';

	wait for 6.6667 ns ;

	single_shot <= '0';

	wait for 200 ns;

end process Main; 

U_fake_data_generator: entity work.fake_data_generator PORT MAP(
	CLOCK_IN 				=> clock_topix_150mhz,
	ENABLE_IN 				=> enable,
	SINGLE_SHOT_IN 			=> single_shot,
	NUMBER_SINGLE_SHOT_IN 	=> number_single_shot,
	INTERVAL_IN 			=> interval,
	FAKE_DATA_OUT 			=> fake_data,
	FAKE_DATA_WR_EN_OUT 	=> fake_data_wr_en
);



 end fake_data_generator;