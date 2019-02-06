library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_interface_tb is
end sram_interface_tb;

architecture TB of sram_interface_tb is

signal clk 				: std_logic := '0';
signal rst				: std_logic := '1';
signal sck				: std_logic;
signal ss 				: std_logic;
signal mosi 			: std_logic;
signal miso 			: std_logic;
signal data_correct 	: std_logic;

signal clkEn 			: std_logic := '1';

begin

	UUT : entity work.sram_interface
		port map(
			clk				=> clk,
			rst				=> rst,
			sck 			=> sck,
			ss 				=> ss,
			mosi 			=> mosi,
			miso 			=> miso,
			data_correct 	=> data_correct
		);
	
	clk <= not clk and clkEn after 10 ns;

	process
	begin
		clkEn <= '1';
		sck <= '0';
		ss <= '1';
		mosi <= '0';
		wait for 200 ns;

		rst <= '0';
		wait for 200 ns;

-- BYTE 0x00
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;



-- BYTE 0x00
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;


-- BYTE 0x01
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;
		mosi <= '0';
		ss <= '1';
		wait for 100 ns;

-- BYTE 0x00
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;

-- BYTE 0x02
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;


-- BYTE 0x00
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;

-- BYTE 0x03
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;


-- BYTE 0x0A
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '1';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;


-- BYTE 0x04
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;


-- BYTE 0x0F
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;



-- BYTE 0x00
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;



-- BYTE 0x00
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;


-- BYTE 0x01
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;
		mosi <= '0';
		ss <= '1';
		wait for 100 ns;

-- BYTE 0x00
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;

-- BYTE 0x02
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;


-- BYTE 0x01
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;



-- BYTE 0x05
-- DATA_TYPE
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;


-- BYTE 0x01
-- DATA
-- BIT 7
		ss <= '0';
		mosi <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 6
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 5
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 4
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 3
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 2
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 1
		mosi <= '0';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

-- BIT 0
		mosi <= '1';
		sck <= '0';
		wait for 40 ns;

		sck <= '1';
		wait for 40 ns;

		sck <= '0';
		wait for 40 ns;

		ss <= '1';
		wait for 100 ns;

		wait;
	end process;

end architecture TB;