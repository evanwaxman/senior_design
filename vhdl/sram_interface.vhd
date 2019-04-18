library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_interface is
	generic (
		COLOR_WIDTH     : positive := 8;
		OFFSET_WIDTH    : positive := 4;
		SRAM_DATA_WIDTH : positive := 16;
        SRAM_ADDR_WIDTH : positive := 20
	);
	port (
		clk 			: in 		std_logic;
		rst 			: in 		std_logic;
		sck 			: in 		std_logic;
		ss 				: in 		std_logic;
		mosi 			: in 		std_logic;
		miso 			: out 		std_logic;

        -- lcd i/o
        sram_ready 		: out 		std_logic;
        lcd_addr 		: in 		std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        lcd_status 		: in 		std_logic;
        brush_width     : in 		std_logic_vector(OFFSET_WIDTH downto 0);
        erase_screen 	: in 		std_logic;
        curr_color 		: out 		std_logic_vector((3*COLOR_WIDTH)-1 downto 0);
        --write_fifo_full : out 		std_logic;

        -- sram i/o
		sram_read_data	: out 		std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
		sram_addr  		: out 		std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
		sram_data_bus 	: inout 	std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
		sram_ce			: out 		std_logic;
		sram_oe			: out 		std_logic;
		sram_we			: out 		std_logic;
		sram_bhe		: out 		std_logic;
		sram_ble		: out 		std_logic
	);
end sram_interface;

architecture BHV of sram_interface is

	-- spi_slave
	signal sram_fifo_packet : std_logic_vector(35 downto 0);
	signal packet_flag 		: std_logic;

	-- spi_write_fifo
	signal write_fifo_dout 	: std_logic_vector(35 downto 0);
	signal spi_addr 		: std_logic_vector(19 downto 0);
	signal spi_data	 		: std_logic_vector(15 downto 0);
	signal spi_fifo_re 		: std_logic;
	signal spi_fifo_empty 	: std_logic;

begin
	
    U_SPI_SLAVE : entity work.spi_slave
        port map(
	        clk                 => clk,
	        rst                 => rst,
	        sck                 => sck,
	        ss                  => ss,
	        mosi                => mosi,
	        miso                => miso,
	        sram_fifo_packet    => sram_fifo_packet,
	        packet_flag         => packet_flag,
	        brush_width      	=> brush_width,
	        curr_color 			=> curr_color
        );

	U_SPI_WRITE_FIFO : entity work.sram_write_fifo 
		port map (
			aclr	=> rst,
			clock	=> clk,
			data	=> sram_fifo_packet,
			rdreq	=> spi_fifo_re,
			wrreq	=> packet_flag,
			empty	=> spi_fifo_empty,
			full	=> open,
			q	 	=> write_fifo_dout
		);

	spi_addr <= write_fifo_dout(35 downto 16);
	spi_data <= write_fifo_dout(15 downto 0);

	U_SRAM_CONTROLLER : entity work.sram_controller
	    generic map (
            SRAM_DATA_WIDTH     => SRAM_DATA_WIDTH,
            SRAM_ADDR_WIDTH     => SRAM_ADDR_WIDTH
        )
		port map (
			clk 			=> clk,
			rst 			=> rst,
			erase_screen 	=> erase_screen,
			spi_addr		=> spi_addr,
			spi_data		=> spi_data,
			spi_fifo_re 	=> spi_fifo_re,
			spi_fifo_empty 	=> spi_fifo_empty,
			sram_ready 		=> sram_ready,
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