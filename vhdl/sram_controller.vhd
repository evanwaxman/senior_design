library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_controller is
	port(
		clk 			: in 		std_logic;
		rst 			: in 		std_logic;

		-- spi i/o
		spi_addr 		: in 		std_logic_vector(19 downto 0);
		spi_data 		: in 		std_logic_vector(15 downto 0);
		spi_fifo_re 	: out 		std_logic;
		spi_fifo_empty 	: in 		std_logic;

		-- lcd i/o
		lcd_addr 		: in 		std_logic_vector(19 downto 0);
		lcd_data 		: out 		std_logic_vector(15 downto 0);
		lcd_displaying 	: in 		std_logic;

		-- sram i/o
		sram_addr  		: out 		std_logic_vector(19 downto 0);
		sram_data  		: inout 	std_logic_vector(15 downto 0);
		sram_ce 		: out 		std_logic;
		sram_oe 		: out 		std_logic;
		sram_we 		: out 		std_logic;
		sram_bhe 		: out 		std_logic;
		sram_ble 		: out 		std_logic
	);
end sram_controller;

architecture BHV of sram_controller is

	type STATE_TYPE is (IDLE, WRITE_TEST_DATA, WRITE_SRAM, READ_SRAM);
	signal state, next_state : STATE_TYPE;

	signal spi_fifo_re_n 	: std_logic;

	signal sram_addr_n 		: std_logic_vector(19 downto 0);
	signal sram_data_n 		: std_logic_vector(15 downto 0);
	signal sram_ce_n 		: std_logic;
	signal sram_oe_n 		: std_logic;
	signal sram_we_n 		: std_logic;
	signal sram_bhe_n 		: std_logic;
	signal sram_ble_n 		: std_logic;
	signal lcd_data_n 		: std_logic_vector(15 downto 0);

begin

	process(clk, rst)
	begin
		if (rst = '1') then
			spi_fifo_re <= '0';
			sram_addr <= (others => '0');
			sram_data <= (others => 'Z');
			sram_ce <= '1';
			sram_oe <= '0';
			sram_we <= '0';
			sram_bhe <= '0';
			sram_ble <= '0';
			lcd_data <= (others => '0');
			state <= IDLE;
		elsif (clk'event and clk = '1') then
			spi_fifo_re <= spi_fifo_re_n;
			sram_addr <= sram_addr_n;
			sram_data <= sram_data_n;
			sram_ce <= sram_ce_n;
			sram_oe <= sram_oe_n;
			sram_we <= sram_we_n;
			sram_bhe <= sram_bhe_n;
			sram_ble <= sram_ble_n;
			lcd_data <= lcd_data_n;
			state <= next_state;
		end if;
	end process;

	process(state, lcd_displaying, spi_fifo_empty, spi_addr, spi_data, lcd_addr, sram_data)
	begin
		next_state <= state;

		spi_fifo_re_n <= '0';

		sram_addr_n <= (others => '0');
		sram_data_n <= (others => 'Z');
		sram_ce_n <= '1';
		sram_oe_n <= '0';
		sram_we_n <= '1';
		sram_bhe_n <= '0';
		sram_ble_n <= '0';
		lcd_data_n <= (others => '0');

		case (state) is
			when IDLE =>
				if (lcd_displaying = '0') then
					sram_addr_n <= std_logic_vector(to_unsigned(10, 20));
					sram_data_n <= "1111111100000000";
					sram_ce_n <= '0';
					sram_oe_n <= '1';
					sram_we_n <= '0';
					sram_ble_n <= '0';
					sram_bhe_n <= '0';
					if (spi_fifo_empty = '0') then
						spi_fifo_re_n <= '1';
						next_state <= WRITE_SRAM;
					end if;
				else
					next_state <= READ_SRAM;
				end if;

			when WRITE_SRAM =>
				if (lcd_displaying = '1') then
					next_state <= READ_SRAM;
				else
					sram_addr_n <= spi_addr;
					sram_data_n <= spi_data;
					sram_ce_n <= '0';
					sram_oe_n <= '1';
					sram_we_n <= '0';
					sram_ble_n <= '0';
					sram_bhe_n <= '0';
					if (spi_fifo_empty = '0') then
						spi_fifo_re_n <= '1';
					else 
						next_state <= IDLE;
					end if;
				end if;

			when READ_SRAM =>
				if (lcd_displaying = '0') then
					next_state <= IDLE;
				else
					sram_addr_n <= lcd_addr;
					sram_data_n <= (others => 'Z');
					sram_ce_n <= '0';
					sram_oe_n <= '0';
					sram_we_n <= '1';
					sram_ble_n <= '0';
					sram_bhe_n <= '0';
					lcd_data_n <= sram_data;
				end if;

			when others => null;
		end case;
	end process;
	
end architecture BHV;