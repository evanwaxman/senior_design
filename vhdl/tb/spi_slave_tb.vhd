library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave_tb is
end spi_slave_tb;

architecture TB of spi_slave_tb is

signal clk 				: std_logic := '0';
signal rst				: std_logic := '1';
signal sck				: std_logic;
signal ss 				: std_logic;
signal mosi 			: std_logic;
signal miso 			: std_logic;
signal receive_byte 	: std_logic_vector(7 downto 0);
signal led1 			: std_logic_vector(6 downto 0);
signal led2 			: std_logic_vector(6 downto 0);

signal clkEn 			: std_logic := '1';

constant sck_delay 	: time 	:= 1 us;
constant ss_delay 	: time 	:= 12 us;

begin

	UUT : entity work.top_level
		port map(
			clk				=> clk,
			rst				=> rst,
			sck 			=> sck,
			ss 				=> ss,
			mosi 			=> mosi,
			miso 			=> miso,
			receive_byte 	=> receive_byte,
			led1 			=> led1,
			led2 			=> led2
		);
	
	clk <= not clk and clkEn after 10 ns;

	process
	begin
		clkEn <= '1';
		sck <= '1';
		ss <= '1';
		mosi <= '0';
		wait for 200 us;

		rst <= '0';
		wait for 200 us;

-- BYTE 0x00
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		wait for ss_delay;

		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;
		mosi <= '0';

		wait for ss_delay;
		ss <= '1';
		wait for 100 us;



-- BYTE 0xFF
-- DATA
-- BIT 7
		ss <= '0';
		wait for ss_delay;
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 6
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 5
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 4
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 3
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 2
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 1
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;
		mosi <= '0';

		wait for ss_delay;

		ss <= '1';
		wait for 100 us;


-- BYTE 0x01
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		wait for ss_delay;
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;
		mosi <= '0';

		wait for ss_delay;
		ss <= '1';
		wait for 100 us;

-- BYTE 0xAA
-- DATA
-- BIT 7
		ss <= '0';
		wait for ss_delay;

		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 5
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 3
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 1
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;
		mosi <= '0';

		wait for ss_delay;
		ss <= '1';
		wait for 100 us;

-- BYTE 0xF0
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		wait for ss_delay;

		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 6
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 5
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 4
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;
		mosi <= '0';

		wait for ss_delay;
		ss <= '1';
		wait for 100 us;


-- BYTE 0x04
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		wait for ss_delay;

		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 2
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;
		mosi <= '0';

		wait for ss_delay;
		ss <= '1';
		wait for 100 us;

-- BYTE 0xAA
-- DATA
-- BIT 7
		ss <= '0';
		wait for ss_delay;

		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 5
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 3
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 1
		mosi <= '1';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for sck_delay;

		sck <= '1';
		wait for sck_delay;
		mosi <= '0';

		wait for ss_delay;
		ss <= '1';
		wait for 100 us;


		wait;
	end process;

end architecture TB;