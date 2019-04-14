library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;
use work.CHAR_LIB.all;

entity lcd_controller is
    generic (
        COLOR_WIDTH         : positive := 8;
        OFFSET_WIDTH        : positive := 4;
        SRAM_DATA_WIDTH     : positive := 16;
        SRAM_ADDR_WIDTH     : positive := 20
    );
    port(
        clk                 : in        std_logic;
        rst                 : in        std_logic;
        video_on            : in        std_logic;
        pixel_location      : in        std_logic_vector(SRAM_ADDR_WIDTH-2 downto 0);
        hcount              : in        std_logic_vector(9 downto 0);
        vcount              : in        std_logic_vector(9 downto 0);
        pixel_color         : out       std_logic_vector((3*COLOR_WIDTH)-1 downto 0);
        curr_color          : in        std_logic_vector((3*COLOR_WIDTH)-1 downto 0);
        brush_width         : in        std_logic_vector(OFFSET_WIDTH downto 0);
        display_state       : in        std_logic_vector(7 downto 0);
        den                 : out       std_logic;

        -- sram signals
        lcd_addr            : out       std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        sram_read_data      : in        std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
        lcd_status          : out       std_logic
    );
end lcd_controller;

architecture BHV of lcd_controller is
    
    type STATE_TYPE is (INIT, WRITE_STARTUP_SCREEN, DISPLAY_STARTUP_SCREEN_RG, DISPLAY_STARTUP_SCREEN_B, WRITE_DOODLE_BAR, IDLE, READ_SRAM_RG, READ_SRAM_B, CLEAR_CHAR_RAM);
    type WORD is array(20 downto 0) of std_logic_vector(7 downto 0);

    signal doodle_boy_word                                      : WORD;
    signal doodling_word                                        : WORD;
    signal brush_size_word                                      : WORD;
    signal state, next_state, saved_state, saved_state_n        : STATE_TYPE;

    signal red, red_n                       : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal green, green_n                   : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal blue, blue_n                     : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal sram_read_en_n                   : std_logic;

    signal char_cntr_x, char_x_addr         : std_logic_vector(6 downto 0);
    signal char_cntr_y, char_y_addr         : std_logic_vector(9 downto 0);
    signal char_ram_din, char_ram_din_n     : std_logic_vector(7 downto 0);
    signal char_ram_dout                    : std_logic_vector(7 downto 0);
    signal char_ram_we, char_ram_we_n       : std_logic;
    signal font_row                         : std_logic_vector(7 downto 0);
    signal misc_cntr, misc_cntr_n           : unsigned(7 downto 0);
    signal x_cntr, x_cntr_n                 : unsigned(6 downto 0);
    signal y_cntr, y_cntr_n                 : unsigned(5 downto 0);
    signal font_addr                        : std_logic_vector(10 downto 0);
    signal font_row_hold, font_row_hold_n   : std_logic_vector(7 downto 0);

begin

    U_CHAR_RAM : entity work.char_ram
        port map (
            address => char_cntr_y(9 downto 4) & char_cntr_x,
            clock   => clk,
            data    => char_ram_din,
            wren    => char_ram_we,
            q       => char_ram_dout
        );

    font_addr <= char_ram_dout(6 downto 0) & char_cntr_y(3 downto 0);

    U_FONT_ROM : entity work.font_rom
        port map (
            clk     => clk,
            addr    => to_integer(unsigned(font_addr)),
            fontRow => font_row    
        );

    --U_CLK_DIV  : entity work.clk_div
    --    generic map (
    --        clk_in_freq     => 50000000, 
    --        clk_out_freq    => 1
    --    );
    --    port map (
    --        clk_in          => clk,
    --        clk_out         => clk_1Hz,
    --        rst             => rst,
    --    );

    lcd_status <= video_on;

    process(clk, rst)
    begin
        if (rst = '1') then
            red <= (others => '0');
            green <= (others => '0');
            blue <= (others => '0');
            den <= '0';
            char_ram_din <= (others => '0');
            char_ram_we <= '0';
            char_cntr_x <= (others => '0');
            char_cntr_y <= (others => '0');
            misc_cntr <= (others => '0');
            font_row_hold <= (others => '0');
            x_cntr <= (others => '0');
            y_cntr <= (others => '0');
            saved_state <= INIT;
            state <= INIT;
        elsif (clk'event and clk = '1') then
            red <= red_n;
            green <= green_n;
            blue <= blue_n;
            den <= video_on;
            char_ram_din <= char_ram_din_n;
            char_ram_we <= char_ram_we_n;
            if (char_ram_we_n = '1') then
                char_cntr_x <= char_x_addr;
                char_cntr_y <= char_y_addr;
            else
                char_cntr_x <= hcount(9 downto 3);
                char_cntr_y <= vcount;    
            end if;
            misc_cntr <= misc_cntr_n;
            font_row_hold <= font_row_hold_n;
            x_cntr <= x_cntr_n;
            y_cntr <= y_cntr_n;
            saved_state <= saved_state_n;
            state <= next_state;
        end if;
    end process;

    pixel_color <= blue & green & red;

    --process(clk_1Hz, rst)
    --begin
    --    if (rst = '1') then
    --        misc_timer <= (others => '0');
    --    elsif (rising_edge(clk_1Hz)) then
    --        if (reset_misc_timer = '1') then
    --            misc_timer <= (others => '0');
    --        else
    --            misc_timer <= misc_timer + 1;
    --        end if;
    --    end if;
    --end process;

    doodle_boy_word(9 downto 0) <= (0 => D, 1 => O, 2 => O, 3 => D, 4 => L, 5 => E, 6 => SPACE, 7 => B, 8 => O, 9 => Y);
    --doodling_word(7 downto 0) <= (0 => D, 1 => O, 2 => O, 3 => D, 4 => L, 5 => I, 6 => N, 7 => G);
    brush_size_word(9 downto 0) <= (0 => B, 1 => R, 2 => U, 3 => S, 4 => H, 5 => SPACE, 6 => S, 7 => I, 8 => Z, 9 => E);

    process(state, saved_state, red, green, blue, video_on, pixel_location, sram_read_data, curr_color, hcount, vcount, brush_width, display_state, misc_cntr, doodle_boy_word, doodling_word, brush_size_word, font_row, font_row_hold, x_cntr, y_cntr)
    begin
        red_n <= red;
        green_n <= green;
        blue_n <= blue;
        lcd_addr <= (others => '0');

        char_x_addr <= (others => '0');
        char_y_addr <= (others => '0');
        char_ram_we_n <= '0';
        char_ram_din_n <= (others => '0');
        misc_cntr_n <= misc_cntr;
        font_row_hold_n <= font_row_hold;
        x_cntr_n <= x_cntr;
        y_cntr_n <= y_cntr;

        saved_state_n <= saved_state;
        next_state <= state;

        case state is
            when INIT =>
                misc_cntr_n <= (others => '0');

                next_state <= WRITE_STARTUP_SCREEN;

            when WRITE_STARTUP_SCREEN =>
                if (misc_cntr < 10) then
                    char_x_addr <= std_logic_vector(resize(misc_cntr + 44, 7));
                    char_y_addr(9 downto 4) <= std_logic_vector(to_unsigned(15, 6));
                    char_ram_we_n <= '1';
                    char_ram_din_n <= doodle_boy_word(to_integer(misc_cntr));
                    misc_cntr_n <= misc_cntr + 1;
                else
                    misc_cntr_n <= (others => '0');
                    next_state <= DISPLAY_STARTUP_SCREEN_RG;
                end if;

            when DISPLAY_STARTUP_SCREEN_RG =>
                if (hcount(2 downto 0) = "111") then
                    font_row_hold_n <= font_row;
                else
                    font_row_hold_n <= std_logic_vector(shift_left(unsigned(font_row_hold), 1));
                end if;

                red_n <= (others => font_row_hold(7));
                green_n <= (others => font_row_hold(7));

                if (display_state(4) = '1') then
                    saved_state_n <= WRITE_DOODLE_BAR;
                    next_state <= CLEAR_CHAR_RAM;
                else
                    next_state <= DISPLAY_STARTUP_SCREEN_B;
                end if;

            when DISPLAY_STARTUP_SCREEN_B =>
                blue_n <= (others => font_row_hold(7));

                if (display_state(4) = '1') then
                    saved_state_n <= WRITE_DOODLE_BAR;
                    next_state <= CLEAR_CHAR_RAM;
                else
                    next_state <= DISPLAY_STARTUP_SCREEN_RG;
                end if;

            when WRITE_DOODLE_BAR =>
                if (misc_cntr < 10) then
                    char_x_addr <= std_logic_vector(resize(misc_cntr + 86, 7));
                    char_y_addr(9 downto 4) <= (others => '0');
                    char_ram_we_n <= '1';
                    char_ram_din_n <= brush_size_word(to_integer(misc_cntr));
                    misc_cntr_n <= misc_cntr + 1;
                else
                    misc_cntr_n <= (others => '0');
                    next_state <= IDLE;
                end if;

            when IDLE =>
                if (video_on = '1') then
                    lcd_addr <= pixel_location & '0';
                    blue_n <= sram_read_data(15 downto 8);
                    next_state <= READ_SRAM_RG;
                end if;

            when READ_SRAM_RG =>
                if (video_on = '0') then
                    next_state <= IDLE;
                else
                    -- draw color borders
                    if (unsigned(hcount) >= 0 and unsigned(hcount) <= 11) then
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(hcount) >= 790 and unsigned(hcount) <= 800 and unsigned(vcount) >= 24) then
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 0 and unsigned(vcount) <= 11 and unsigned(hcount) <= 685) then
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 470 and unsigned(vcount) <= 480) then
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif ((unsigned(hcount) > 685 and unsigned(vcount) <= 13) or (unsigned(hcount) >= 790 and unsigned(hcount) <= 800 and unsigned(vcount) < 24)) then
                        red_n <= "00000000";
                        green_n <= "00000000";
                    elsif (unsigned(vcount) >= 0 and unsigned(vcount) < 24 and unsigned(hcount) > 775) then
                        red_n <= "00000000";
                        green_n <= "00000000";
                    else    -- current pixel within color borders
                        lcd_addr <= pixel_location & '1';
                        red_n <= sram_read_data(15 downto 8);
                        green_n <= sram_read_data(7 downto 0);                                                                       
                    end if;

                    -- draw brush square
                    if (unsigned(hcount) >= (to_unsigned(790, 10) - resize(shift_right(unsigned(brush_width), 1), 10)) and unsigned(hcount) <= (to_unsigned(790, 10) + resize(shift_right(unsigned(brush_width), 1), 10))) then
                        if (unsigned(vcount) >= (to_unsigned(9, 10) - resize(shift_right(unsigned(brush_width), 1), 10)) and unsigned(vcount) <= (to_unsigned(9, 10) + resize(shift_right(unsigned(brush_width), 1), 10))) then
                            red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                            green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);  
                        end if;
                    end if;

                    -- draw doodle bar
                    if (hcount(2 downto 0) = "111") then
                        font_row_hold_n <= font_row;
                    else
                        font_row_hold_n <= std_logic_vector(shift_left(unsigned(font_row_hold), 1));
                    end if;

                    if (font_row_hold(7) = '1') then
                        red_n <= (others => font_row_hold(7));
                        green_n <= (others => font_row_hold(7));
                    end if;

                    next_state <= READ_SRAM_B;
                end if;

            when READ_SRAM_B =>
                if (video_on = '0') then
                    next_state <= IDLE;
                else
                    -- draw color borders
                    if (unsigned(hcount) >= 0 and unsigned(hcount) <= 11) then
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(hcount) >= 790 and unsigned(hcount) <= 800 and unsigned(vcount) >= 24) then
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 0 and unsigned(vcount) <= 11 and unsigned(hcount) <= 685) then
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 470 and unsigned(vcount) <= 480) then
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif ((unsigned(hcount) > 685 and unsigned(vcount) <= 13) or (unsigned(hcount) >= 790 and unsigned(hcount) <= 800 and unsigned(vcount) < 24)) then
                        blue_n <= "00000000";
                    elsif (unsigned(vcount) >= 0 and unsigned(vcount) < 24 and unsigned(hcount) > 775) then
                        blue_n <= "00000000";
                    else    -- current pixel within color borders
                        lcd_addr <= pixel_location & '0';
                        blue_n <= sram_read_data(15 downto 8);                                                                    
                    end if;

                    -- draw brush square
                    if (unsigned(hcount) >= (to_unsigned(790, 10) - resize(shift_right(unsigned(brush_width), 1), 10)) and unsigned(hcount) <= (to_unsigned(790, 10) + resize(shift_right(unsigned(brush_width), 1), 10))) then
                        if (unsigned(vcount) >= (to_unsigned(9, 10) - resize(shift_right(unsigned(brush_width), 1), 10)) and unsigned(vcount) <= (to_unsigned(9, 10) + resize(shift_right(unsigned(brush_width), 1), 10))) then
                            blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                        end if;
                    end if;

                    if (font_row_hold(7) = '1') then
                        blue_n <= (others => font_row_hold(7));
                    end if;

                    next_state <= READ_SRAM_RG;
                end if;

            when CLEAR_CHAR_RAM =>
                char_x_addr <= std_logic_vector(x_cntr);
                char_y_addr(9 downto 4) <= std_logic_vector(y_cntr);
                char_ram_we_n <= '1';
                char_ram_din_n <= (others => '0');

                if (x_cntr + 1 < 100) then
                    x_cntr_n <= x_cntr + 1;
                else
                    if (y_cntr + 1 < 60) then
                        y_cntr_n <= y_cntr + 1;
                        x_cntr_n <= (others => '0');
                    else
                        x_cntr_n <= (others => '0');
                        y_cntr_n <= (others => '0');
                        next_state <= saved_state;
                    end if;
                end if;

            when others => null;
        end case;
    end process;

end BHV;
