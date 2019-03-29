library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_interface is
	generic (
        COLOR_WIDTH     : positive := 8;
        SRAM_DATA_WIDTH : positive := 16;
        SRAM_ADDR_WIDTH : positive := 20
	);
	port(
        clk             : in        std_logic;
        clk_25MHz       : in        std_logic;
        rst             : in        std_logic;
        Horiz_Sync      : out       std_logic;
        Vert_Sync       : out       std_logic;
        pixel_color     : out       std_logic_vector((3*COLOR_WIDTH)-1 downto 0);
        den             : out       std_logic;

        -- sram signals
        lcd_addr        : out       std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        sram_read_data  : in        std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
        lcd_status      : out       std_logic
	);
end lcd_interface;

architecture BHV of lcd_interface is

	--signal write_fifo_re    : std_logic;
 --   signal write_fifo_dout  : std_logic_vector(35 downto 0);
 --   signal write_fifo_empty : std_logic;
 --   signal write_fifo_full  : std_logic;

    signal hcount 			: std_logic_vector(9 downto 0);
    signal vcount 			: std_logic_vector(9 downto 0);
    signal video_on 		: std_logic;
    signal pixel_location 	: std_logic_vector(SRAM_ADDR_WIDTH-2 downto 0);

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
    	generic map(
    		COLOR_WIDTH 	=> COLOR_WIDTH
    	)
	    port map(
			clk 			=> clk,
			rst	 			=> rst,
			video_on 		=> video_on,
			pixel_location 	=> pixel_location,
			pixel_color 	=> pixel_color,
			lcd_addr 		=> lcd_addr,
			sram_read_data 	=> sram_read_data,
			lcd_status 		=> lcd_status
	    );
    
    den <= video_on;
	
end architecture BHV;