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

		write_fifo_re 		: in 	std_logic;
		write_fifo_dout 	: out 	std_logic_vector(35 downto 0);
		write_fifo_empty	: out 	std_logic;
		write_fifo_full 	: out 	std_logic;

		fifo_we 		: out 	std_logic;

		-- spi_slave
		led0            : out   std_logic_vector(6 downto 0);
        led1            : out   std_logic_vector(6 downto 0);
        led2            : out   std_logic_vector(6 downto 0);
        received_byte 	: out 	std_logic_vector(7 downto 0)
	);
end sram_interface;

architecture BHV of sram_interface is

	signal sram_fifo_packet : std_logic_vector(35 downto 0);
	signal packet_flag 		: std_logic;


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
	        led0                => led0,
	        led1                => led1,
	        led2                => led2,
	        received_byte       => received_byte
        );

	U_SPI_WRITE_FIFO : entity work.sram_write_fifo 
		port map (
			aclr	=> rst,
			clock	=> clk,
			data	=> sram_fifo_packet,
			rdreq	=> write_fifo_re,
			wrreq	=> packet_flag,
			empty	=> write_fifo_empty,
			full	=> write_fifo_full,
			q	 	=> write_fifo_dout
		);

	fifo_we <= packet_flag;


	--process(clk, rst)
	--begin
	--	if (rst = '1') then
	--		data_correct <= '0';
	--	elsif (clk'event and clk = '1') then
	--		if (packet_flag = '1') then
	--			write_fifo_re <= '1';
	--		end if;
	--	end if;
	--end process;


end architecture BHV;