library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pixel_test_tb is
end pixel_test_tb;

architecture TB of pixel_test_tb is

	constant OFFSET_WIDTH 	: positive 	:= 3;
	constant ADDRESS_WIDTH 	: positive 	:= 20;
	constant PACKET_WIDTH 	: positive 	:= 36;

	signal clk  			: std_logic := '0';
	signal rst  			: std_logic;
	signal address  		: std_logic_vector(ADDRESS_WIDTH-1 downto 0);
	signal offset_max  		: std_logic_vector(OFFSET_WIDTH-1 downto 0);
	signal sram_fifo_packet : std_logic_vector(PACKET_WIDTH-1 downto 0);

	signal clkEn 			: std_logic := '1';

begin

	UUT : entity work.pixel_test
		port map (
			clk 				=> clk,
			rst 				=> rst,
			address 			=> address,
			offset_max 		=> offset_max,
			sram_fifo_packet 	=> sram_fifo_packet
		);

	clk <= not clk and clkEn after 10 ns;

	process
	begin
		rst <= '1';
		address <= (others => '0');
		offset_max <= (others => '0');
		wait for 200 ns;

		rst <= '0';
		address <= std_logic_vector(to_unsigned(80000, ADDRESS_WIDTH));
		offset_max <= std_logic_vector(to_unsigned(5, OFFSET_WIDTH));
		wait for 200 us;

		wait;
	end process;

end architecture ; -- TB