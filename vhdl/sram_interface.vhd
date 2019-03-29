library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_interface is
	port (
		clk 			: in 		std_logic;
		rst 			: in 		std_logic;
		--sck 			: in 		std_logic;
		--ss 				: in 		std_logic;
		--mosi 			: in 		std_logic;
		--miso 			: out 		std_logic;

		-- spi_slave
		--led0            : out   	std_logic_vector(6 downto 0);
  --      led1            : out   	std_logic_vector(6 downto 0);
  --      led2            : out   	std_logic_vector(6 downto 0);
  --      received_byte 	: out 		std_logic_vector(7 downto 0);


        -- lcd i/o
        lcd_addr 		: in 		std_logic_vector(19 downto 0);
        lcd_status 		: in 		std_logic;
        --write_fifo_full : out 		std_logic;

        -- sram i/o
		sram_read_data	: out 		std_logic_vector(15 downto 0);
		sram_addr  		: out 		std_logic_vector(19 downto 0);
		sram_data_bus 	: inout 	std_logic_vector(15 downto 0);
		sram_ce			: out 		std_logic;
		sram_oe			: out 		std_logic;
		sram_we			: out 		std_logic;
		sram_bhe		: out 		std_logic;
		sram_ble		: out 		std_logic
	);
end sram_interface;

architecture BHV of sram_interface is

	--signal sram_fifo_packet : std_logic_vector(35 downto 0);
	--signal packet_flag 		: std_logic;

	--signal write_fifo_dout 	: std_logic_vector(35 downto 0);
	--signal spi_addr 		: std_logic_vector(19 downto 0);
	--signal spi_data	 		: std_logic_vector(15 downto 0);
	--signal spi_fifo_re 		: std_logic;
	--signal spi_fifo_empty 	: std_logic;



begin
	
 --   U_SPI_SLAVE : entity work.spi_slave
 --       port map(
	--        clk                 => clk,
	--        rst                 => rst,
	--        sck                 => sck,
	--        ss                  => ss,
	--        mosi                => mosi,
	--        miso                => miso,
	--        sram_fifo_packet    => sram_fifo_packet,
	--        packet_flag         => packet_flag,
	--        led0                => led0,
	--        led1                => led1,
	--        led2                => led2,
	--        received_byte       => received_byte
 --       );

	--U_SPI_WRITE_FIFO : entity work.sram_write_fifo 
	--	port map (
	--		aclr	=> rst,
	--		clock	=> clk,
	--		data	=> sram_fifo_packet,
	--		rdreq	=> spi_fifo_re,
	--		wrreq	=> packet_flag,
	--		empty	=> spi_fifo_empty,
	--		full	=> write_fifo_full,
	--		q	 	=> write_fifo_dout
	--	);

	--spi_addr <= write_fifo_dout(35 downto 16);
	--spi_data <= write_fifo_dout(15 downto 0);

	U_SRAM_CONTROLLER : entity work.sram_controller
		port map (
			clk 			=> clk,
			rst 			=> rst,
			--spi_addr		=> spi_addr,
			--spi_data		=> spi_data,
			--spi_fifo_re 	=> spi_fifo_re,
			--spi_fifo_empty 	=> spi_fifo_empty,
			lcd_addr 		=> lcd_addr,
			lcd_status 		=> lcd_status,
			sram_read_data	=> sram_read_data,
			sram_addr  		=> sram_addr,
			sram_data_bus 	=> sram_data_bus,
			sram_ce 		=> sram_ce,
			sram_oe 		=> sram_oe,
			sram_we 		=> sram_we,
			sram_bhe 		=> sram_bhe,
			sram_ble 		=> sram_ble
		);



end architecture BHV;