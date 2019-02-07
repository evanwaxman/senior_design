library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave_tb is
end spi_slave_tb;

architecture TB of spi_slave_tb is

-- UUT I/O signals
signal clk 				: std_logic := '0';
signal rst				: std_logic := '1';
signal sck				: std_logic := '1';
signal ss 				: std_logic := '1';
signal mosi 			: std_logic := '0';
signal miso 			: std_logic;
signal sram_fifo_packet	: std_logic_vector(35 downto 0);
signal led0 			: std_logic_vector(6 downto 0);
signal led1 			: std_logic_vector(6 downto 0);
signal led2 			: std_logic_vector(6 downto 0);

-- tb signals
type packet is array (0 to 5) of std_logic_vector(7 downto 0);
signal mosi_data 		: packet;
signal clkEn 			: std_logic := '1';

-- constants
constant sck_delay 	: time 	:= 1 us;
constant ss_delay 	: time 	:= 12 us;



begin

	UUT : entity work.top_level
		port map(
			clk					=> clk,
			rst					=> rst,
			sck 				=> sck,
			ss 					=> ss,
			mosi 				=> mosi,
			miso 				=> miso,
			led0 				=> led0,
			led1 				=> led1,
			led2 				=> led2
		);
	
	clk <= not clk and clkEn after 10 ns;

	mosi_data(0) <= "00110011";
	mosi_data(1) <= "01100001";
	mosi_data(2) <= "11110000";
	mosi_data(3) <= "10101010";
	mosi_data(4) <= "00001111";
	mosi_data(5) <= "11001100";

	process
		variable clk_count 		: unsigned(3 downto 0) := to_unsigned(0, 4);
	begin
		rst <= '1';
		wait for 200 us;

		rst <= '0';
		wait for 200 us;

		for i in 0 to 5 loop
			ss <= '0';
			wait for ss_delay;

			for j in 0 to 7 loop
				wait until clk'event and clk = '1';
				sck <= '0';
				mosi <= mosi_data(i)(7-j);
				wait for sck_delay;
				sck <= '1';
				wait for sck_delay;
			end loop;
			mosi <= '0';
			wait for ss_delay;
			ss <= '1';
			wait for 100 us;
		end loop;

		wait;
	end process;

end architecture TB;