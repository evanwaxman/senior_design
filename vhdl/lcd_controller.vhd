library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

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
        den                 : out       std_logic;

        -- sram signals
        lcd_addr            : out       std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        sram_read_data      : in        std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
        lcd_status          : out       std_logic
    );
end lcd_controller;

architecture BHV of lcd_controller is
    
    type STATE_TYPE is (INIT, IDLE, READ_SRAM_RG, READ_SRAM_B);
    signal state, next_state, saved_state, saved_state_n        : STATE_TYPE;

    signal red                  : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal red_n                : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal green                : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal green_n              : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal blue                 : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal blue_n               : std_logic_vector(COLOR_WIDTH-1 downto 0);
    signal sram_read_en_n       : std_logic;

    signal clear_letters        : std_logic;
    signal char_cntr_x          : std_logic_vector(5 downto 0);
    signal char_cntr_y          : std_logic_vector(9 downto 0);
    signal char_ram_din         : std_logic_vector(7 downto 0);
    signal char_ram_dout        : std_logic_vector(7 downto 0);
    signal char_ram_we          : std_logic;

begin
    
    --clear_letters <= rst;

    --U_CHAR_RAM : entity work.char_ram
    --    port map (
    --        aclr    => clear_letters,
    --        address => char_cntr_y(9 downto 3) & char_cntr_x,
    --        clock   => clk,
    --        data    => char_ram_din,
    --        wren    => char_ram_we,
    --        q       => char_ram_dout
    --    );

    lcd_status <= video_on;

    process(clk, rst)
    begin
        if (rst = '1') then
            red <= (others => '0');
            green <= (others => '0');
            blue <= (others => '0');
            den <= '0';
            state <= INIT;
        elsif (clk'event and clk = '1') then
            red <= red_n;
            green <= green_n;
            blue <= blue_n;
            den <= video_on;
            state <= next_state;
        end if;
    end process;

    pixel_color <= blue & green & red;

    process(state, red, green, blue, video_on, pixel_location, sram_read_data, curr_color, hcount, vcount, brush_width)
    begin
        red_n <= red;
        green_n <= green;
        blue_n <= blue;
        lcd_addr <= (others => '0');
        next_state <= state;

        case state is
            when INIT =>
                next_state <= READ_SRAM_RG;

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
                    if (unsigned(hcount) >= 0 and unsigned(hcount) <= 10) then
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(hcount) >= 790 and unsigned(hcount) <= 800 and unsigned(vcount) >= 24) then
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 0 and unsigned(vcount) <= 10 and unsigned(hcount) <= 775) then
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 470 and unsigned(vcount) <= 480) then
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(hcount) >= 790 and unsigned(hcount) <= 800 and unsigned(vcount) < 24) then
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

                    next_state <= READ_SRAM_B;
                end if;

            when READ_SRAM_B =>
                if (video_on = '0') then
                    next_state <= IDLE;
                else
                    -- draw color borders
                    if (unsigned(hcount) >= 0 and unsigned(hcount) <= 10) then
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(hcount) >= 790 and unsigned(hcount) <= 800 and unsigned(vcount) >= 24) then
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 0 and unsigned(vcount) <= 10 and unsigned(hcount) <= 775) then
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 470 and unsigned(vcount) <= 480) then
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(hcount) >= 790 and unsigned(hcount) <= 800 and unsigned(vcount) < 24) then
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

                    next_state <= READ_SRAM_RG;
                end if;

            when others => null;
        end case;
    end process;

end BHV;
