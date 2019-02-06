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
		miso 			: out 	std_logic;
		data_correct 	: out 	std_logic
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
	signal spi_ready 		: std_logic;
	signal led0 			: std_logic_vector(6 downto 0);
	signal led1 			: std_logic_vector(6 downto 0);

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
			led0 			=> led0,
			led1 			=> led1
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


	process(clk, rst)
	begin
		if (rst = '1') then
		elsif (clk'event and clk = '1') then
			if (write_fifo_empty = '0') then
				write_fifo_re <= '1';
			end if;
		end if;
	end process;

	process(write_fifo_dout)
	begin
		if (write_fifo_dout = "000000000000000000000001010100001111") then
			data_correct <= '1';
		elsif (write_fifo_dout = "000000000000000000010000000100000000") then
			data_correct <= '1';
		else
			data_correct <= '0';
		end if;
	end process;

end architecture BHV;