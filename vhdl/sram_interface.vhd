library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_interface is
	port (
		clk 			: in 	std_logic;
		rst 			: in 	std_logic;
		sck 			: in 	std_logic;
		ss 				: in 	std_logic;
		mosi 			: in 	std_logic;
		miso 			: out 	std_logic
		--read_byte 		: out 	std_logic;
		--fifo_dout 		: out 	std_logic_vector(7 downto 0)
	);
end sram_interface;

architecture BHV of sram_interface is

	signal receive_byte 	: std_logic_vector(7 downto 0);
	signal byte_type 		: std_logic;
	signal read_done 		: std_logic;
	signal reset_state 		: std_logic;
	signal write_fifo_din 	: std_logic_vector(35 downto 0);
	signal write_fifo_we 	: std_logic;
	signal write_fifo_re 	: std_logic;
	signal write_fifo_empty : std_logic;
	signal write_fifo_full 	: std_logic;
	signal write_fifo_dout 	: std_logic_vector(35 downto 0);
	signal data_out_order 	: std_logic;

begin
	
	U_SPI_SLAVE : entity work.spi_slave
		port map (
			clk 			=> clk,
			rst 			=> rst,
			sck 			=> sck,
			ss 				=> ss,
			mosi 			=> mosi,
			miso 			=> miso,
			receive_byte 	=> receive_byte,
			byte_type		=> byte_type,
			read_done 		=> read_done,
			reset_state 	=> reset_state
		);

	U_SPI_PACKET_MAKER : entity work.spi_packet_maker
		port map (
			clk 			=> clk,
			rst 			=> rst,
			receive_byte 	=> receive_byte,
			byte_type 		=> byte_type,
			read_done 		=> read_done,
			reset_state 	=> reset_state,
			packet 			=> write_fifo_din,
			write_fifo_we 	=> write_fifo_we,
			data_out_order 	=> data_out_order
		);

	U_SPI_WRITE_FIFO : entity work.sram_write_fifo 
		port map (
			clock	=> clk,
			data	=> write_fifo_din,
			rdreq	=> write_fifo_re,
			wrreq	=> write_fifo_we,
			empty	=> write_fifo_empty,
			full	=> write_fifo_full,
			q	 	=> write_fifo_dout
		);


	--process(clk, rst)
	--begin
	--	if (rst = '1') then
	--		read_byte <= (others => '0');

	--	elsif (clk'event and clk = '1') then
			
	--	end if;
	--end process;

end architecture BHV;