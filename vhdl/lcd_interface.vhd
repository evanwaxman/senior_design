library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_interface is
	generic (
        COLOR_WIDTH     	: positive := 8;
        OFFSET_WIDTH        : positive := 4;
        SRAM_DATA_WIDTH 	: positive := 16;
        SRAM_ADDR_WIDTH 	: positive := 20
	);
	port(
        clk             	: in        std_logic;
        clk_25MHz       	: in        std_logic;
        rst             	: in        std_logic;
        h_sync      		: out       std_logic;
        v_sync       		: out       std_logic;
        pixel_color     	: out       std_logic_vector((3*COLOR_WIDTH)-1 downto 0);
        den             	: out       std_logic;
        brush_width 		: in 		std_logic_vector(OFFSET_WIDTH downto 0);

        -- sram signals
        lcd_addr        	: out       std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        sram_read_data  	: in        std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
        lcd_status      	: out       std_logic;
        curr_color 			: in 		std_logic_vector((3*COLOR_WIDTH)-1 downto 0)
	);
end lcd_interface;

architecture BHV of lcd_interface is

    signal hcount 			: std_logic_vector(9 downto 0);
    signal vcount 			: std_logic_vector(9 downto 0);
    signal video_on 		: std_logic;
    signal pixel_location 	: std_logic_vector(SRAM_ADDR_WIDTH-2 downto 0);

begin

    U_LCD_SYNC_GEN : entity work.lcd_sync_gen
	    port map(
	        clk_25MHz       => clk_25MHz,
	        rst             => rst,
	        h_sync      	=> h_sync,
	        v_sync       	=> v_sync,
	        Video_On        => video_on,
	        pixel_location  => pixel_location,
	        Hcount          => hcount,
	        Vcount          => vcount
	    );

    U_LCD_CONTROLLER : entity work.lcd_controller
    	generic map(
    		COLOR_WIDTH 	=> COLOR_WIDTH,
    		OFFSET_WIDTH    => OFFSET_WIDTH
    	)
	    port map(
			clk 					=> clk,
			rst	 					=> rst,
			video_on 				=> video_on,
			pixel_location 			=> pixel_location,
			hcount 					=> hcount,
			vcount 					=> vcount,
			pixel_color 			=> pixel_color,
			brush_width 			=> brush_width,
			den	 					=> den,
			curr_color				=> curr_color,
			lcd_addr 				=> lcd_addr,
			sram_read_data 			=> sram_read_data,
			lcd_status 				=> lcd_status
	    );
	
end architecture BHV;