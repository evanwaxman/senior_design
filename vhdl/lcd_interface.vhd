library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_interface is
	port(
        clk             : in        std_logic;
        clk_25MHz       : in        std_logic;
        rst             : in        std_logic;
        Horiz_Sync      : out       std_logic;
        Vert_Sync       : out       std_logic;
        pixel_color     : out       std_logic_vector(7 downto 0);
        den             : out       std_logic;

        -- sram signals
        lcd_addr        : out       std_logic_vector(19 downto 0);
        sram_read_data  : in        std_logic_vector(15 downto 0);
        lcd_status      : out       std_logic
	);
end lcd_interface;

architecture BHV of lcd_interface is

	--signal write_fifo_re    : std_logic;
 --   signal write_fifo_dout  : std_logic_vector(35 downto 0);
 --   signal write_fifo_empty : std_logic;
 --   signal write_fifo_full  : std_logic;

    type STATE_TYPE is (INIT, IDLE, READ_SRAM);
    signal state, next_state, saved_state, saved_state_n        : STATE_TYPE;

    signal red                  : std_logic_vector(7 downto 0);
    signal red_n                : std_logic_vector(7 downto 0);
    signal pixel_color_n        : std_logic_vector(23 downto 0);
    signal pixel_location       : std_logic_vector(18 downto 0);

    signal hcount               : std_logic_vector(9 downto 0);
    signal vcount               : std_logic_vector(9 downto 0);
    signal video_on             : std_logic;
    signal lcd_addr_n           : std_logic_vector(19 downto 0);
    signal sram_read_en_n       : std_logic;

begin

    U_LCD_SYNC_GEN : entity work.lcd_sync_gen
	    port map(
	        clk_25MHz       => clk_25MHz,
	        rst             => rst,
	        Horiz_Sync      => Horiz_Sync,
	        Vert_Sync       => Vert_Sync,
	        Video_On        => video_on,
	        pixel_location  => pixel_location,
	        Hcount          => hcount,
	        Vcount          => vcount
	    );

    U_LCD_CONTROLLER : entity work.lcd_controller
	    port map(
			clk 			=> clk,
			clk_25MHz 		=> clk_25MHz,
			rst	 			=> rst,
			Horiz_Sync 		=> Horiz_Sync,
			Vert_Sync 		=> Vert_Sync,
			pixel_color 	=> pixel_color,
			den 			=> den,
			lcd_addr 		=> lcd_addr,
			sram_read_data 	=> sram_read_data,
			lcd_status 		=> lcd_status
	    );
    
	
end architecture BHV;