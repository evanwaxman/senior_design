library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_interface is
	port(
		clk 			: in 	std_logic;
		rst 			: in 	std_logic;

		-- lcd_controller
		Horiz_Sync 		: out 	std_logic;
		Vert_Sync 		: out 	std_logic;
		pixel_color 	: out 	std_logic_vector(23 downto 0);
		den 			: out 	std_logic;
		read_fifo_re 	: out 	std_logic
	);
end lcd_interface;

architecture BHV of lcd_interface is

	signal write_fifo_re    : std_logic;
    signal write_fifo_dout  : std_logic_vector(35 downto 0);
    signal write_fifo_empty : std_logic;
    signal write_fifo_full  : std_logic;

begin

    U_LCD_CONTROLLER : entity work.lcd_controller
	    port map(
	        clk                 => clk,
	        rst                 => global_rst,
	        Horiz_Sync          => Horiz_Sync,
	        Vert_Sync           => Vert_Sync,
	        pixel_color         => pixel_color,
	        den                 => den,
	        read_fifo_data      => write_fifo_dout,
	        read_fifo_empty     => write_fifo_empty,
	        read_fifo_full      => write_fifo_full,
	        read_fifo_re        => write_fifo_re
	    );
    
	
end architecture BHV;