library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity sram_controller is
	generic (
		SRAM_DATA_WIDTH : positive := 16;
        SRAM_ADDR_WIDTH : positive := 20
	);
	port(
		clk 			: in 		std_logic;
		rst 			: in 		std_logic;

		-- spi i/o
		spi_addr 		: in 		std_logic_vector(19 downto 0);
		spi_data 		: in 		std_logic_vector(15 downto 0);
		spi_fifo_re 	: out 		std_logic;
		spi_fifo_empty 	: in 		std_logic;

		-- lcd i/o
		sram_ready 		: out 		std_logic;
		lcd_addr 		: in 		std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
		lcd_status 		: in 		std_logic;

		-- sram i/o
		sram_read_data	: out 		std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
		sram_addr  		: out 		std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
		sram_data_bus 	: inout 	std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
		sram_ce 		: out 		std_logic;
		sram_oe 		: out 		std_logic;
		sram_we 		: out 		std_logic;
		sram_bhe 		: out 		std_logic;
		sram_ble 		: out 		std_logic
	);
end sram_controller;

architecture BHV of sram_controller is

	type STATE_TYPE is (INIT, CLEAR_SRAM, WRITE_SRAM, READ_SRAM);
	signal state, next_state : STATE_TYPE;

	signal sram_ready_n 		: std_logic;

	signal sram_write_data		: std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
	signal sram_write_data_n	: std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
	signal sram_read_en 		: std_logic;
	signal sram_read_en_n 		: std_logic;
	signal spi_fifo_re_n 		: std_logic;
	signal sram_addr_n 			: std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
	signal sram_ce_n 			: std_logic;
	signal sram_oe_n 			: std_logic;
	signal sram_we_n 			: std_logic;
	signal sram_bhe_n 			: std_logic;
	signal sram_ble_n 			: std_logic;
	signal cntr 		: std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
	signal cntr_n		: std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);


begin

	U_TRI_BUFF : entity work.tristate
		generic map (DATA_WIDTH => 16)
		port map (
			clk 		=> clk,
			output_en 	=> not sram_read_en,
			din 		=> sram_write_data,
			dout 		=> sram_read_data,
			data_bus 	=> sram_data_bus
		);
	

	process(clk, rst)
	begin
		if (rst = '1') then
			sram_ready <= '1';
			sram_read_en <= '1';
			spi_fifo_re <= '0';
			sram_addr <= (others => '0');
			sram_write_data <= (others => '0');
			sram_ce <= '1';
			sram_oe <= '1';
			sram_we <= '1';
			sram_bhe <= '0';
			sram_ble <= '0';
			cntr <= (others => '0');
			state <= INIT;
		elsif (clk'event and clk = '1') then
			sram_ready <= sram_ready_n;
			sram_read_en <= sram_read_en_n;
			spi_fifo_re <= spi_fifo_re_n;
			sram_addr <= sram_addr_n;
			sram_write_data <= sram_write_data_n;
			sram_ce <= sram_ce_n;
			sram_oe <= sram_oe_n;
			sram_we <= sram_we_n;
			sram_bhe <= sram_bhe_n;
			sram_ble <= sram_ble_n;
			cntr <= cntr_n;
			state <= next_state;
		end if;
	end process;

	----------------------------------------------------------------------------
	-- for testing without fifo
	--spi_fifo_re <= '0';
	----------------------------------------------------------------------------
	process(state, lcd_status, lcd_addr, spi_fifo_empty, spi_addr, spi_data, cntr)
	begin
		next_state <= state;

		sram_ready_n <= '0';

		sram_read_en_n <= '1';
		spi_fifo_re_n <= '0';
		sram_addr_n <= (others => '0');
		sram_write_data_n <= (others => '0');
		sram_ce_n <= '0';
		sram_oe_n <= '1';
		sram_we_n <= '1';
		sram_bhe_n <= '0';
		sram_ble_n <= '0';

		cntr_n <= cntr;

		case (state) is
			when INIT =>
				sram_ready_n <= '1';
				next_state <= CLEAR_SRAM;

			when CLEAR_SRAM =>
				if (unsigned(cntr) < 767999) then
					sram_ready_n <= '1';
					sram_read_en_n <= '0';
					sram_addr_n <= cntr;
					sram_write_data_n <= (others => '1');
					sram_ce_n <= '0';
					sram_oe_n <= '1';
					sram_we_n <= '0';
					cntr_n <= std_logic_vector(unsigned(cntr) + 1);
				else
					next_state <= READ_SRAM;
				end if;

			when WRITE_SRAM =>
				if (lcd_status = '1') then
					sram_read_en_n <= '1';
					sram_addr_n <= lcd_addr;
					sram_ce_n <= '0';
					sram_oe_n <= '0';
					sram_we_n <= '1';
					next_state <= READ_SRAM;
				else
					sram_read_en_n <= '0';

					if (spi_fifo_empty = '0') then
						spi_fifo_re_n <= '1';

						sram_addr_n <= spi_addr;
						sram_write_data_n <= spi_data;
						sram_ce_n <= '0';
						sram_oe_n <= '1';
						sram_we_n <= '0';
					end if;

					--if (unsigned(cntr) < 128000) then
					--	if (cntr(0) = '0') then
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "1111111111111111";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';
					--	else
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "1111111100000000";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';	
					--	end if;

					--	cntr_n <= std_logic_vector(unsigned(cntr) + 1);
					--elsif (unsigned(cntr) >= 128000 and unsigned(cntr) < 256000) then
					--	if (cntr(0) = '0') then
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "0000000011111111";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';
					--	else
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "1111111100000000";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';	
					--	end if;

					--	cntr_n <= std_logic_vector(unsigned(cntr) + 1);
					--elsif (unsigned(cntr) >= 256000 and unsigned(cntr) < 384000) then
					--	if (cntr(0) = '0') then
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "1111111100000000";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';
					--	else
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "1111111100000000";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';	
					--	end if;

					--	cntr_n <= std_logic_vector(unsigned(cntr) + 1);
					--elsif (unsigned(cntr) >= 384000 and unsigned(cntr) < 512000) then
					--	if (cntr(0) = '0') then
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "1111111111111111";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';
					--	else
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "0000000000000000";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';	
					--	end if;

					--	cntr_n <= std_logic_vector(unsigned(cntr) + 1);
					--elsif (unsigned(cntr) >= 512000 and unsigned(cntr) < 640000) then
					--	if (cntr(0) = '0') then
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "0000000011111111";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';
					--	else
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "0000000000000000";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';	
					--	end if;

					--	cntr_n <= std_logic_vector(unsigned(cntr) + 1);
					--elsif (unsigned(cntr) >= 640000 and unsigned(cntr) < 767999) then
					--	if (cntr(0) = '0') then
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "1111111100000000";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';
					--	else
					--		sram_addr_n <= cntr;
					--		sram_write_data_n <= "0000000000000000";
					--		sram_ce_n <= '0';
					--		sram_oe_n <= '1';
					--		sram_we_n <= '0';	
					--	end if;

					--	cntr_n <= std_logic_vector(unsigned(cntr) + 1);
					--end if;
				end if;

			when READ_SRAM =>
				sram_read_en_n <= '1';
				sram_addr_n <= lcd_addr;
				sram_ce_n <= '0';
				sram_oe_n <= '0';
				sram_we_n <= '1';
				if (lcd_status = '0') then
					next_state <= WRITE_SRAM;
				end if;

			when others => null;
		end case;
	end process;
	
end architecture BHV;