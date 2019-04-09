library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_controller is
    generic (
        COLOR_WIDTH     : positive  := 8;
        SRAM_DATA_WIDTH : positive := 16;
        SRAM_ADDR_WIDTH : positive := 20
    );
    port(
        clk             : in        std_logic;
        rst             : in        std_logic;
        video_on        : in        std_logic;
        pixel_location  : in        std_logic_vector(SRAM_ADDR_WIDTH-2 downto 0);
        hcount          : in        std_logic_vector(9 downto 0);
        vcount          : in        std_logic_vector(9 downto 0);
        pixel_color     : out       std_logic_vector((3*COLOR_WIDTH)-1 downto 0);
        curr_color      : in        std_logic_vector((3*COLOR_WIDTH)-1 downto 0);

        -- sram signals
        lcd_addr        : out       std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        sram_read_data  : in        std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
        lcd_status      : out       std_logic
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

begin

    lcd_status <= video_on;

    process(clk, rst)
    begin
        if (rst = '1') then
            red <= (others => '0');
            green <= (others => '0');
            blue <= (others => '0');
            state <= INIT;
        elsif (clk'event and clk = '1') then
            red <= red_n;
            green <= green_n;
            blue <= blue_n;
            state <= next_state;
        end if;
    end process;

    pixel_color <= blue & green & red;

    process(state, red, green, blue, video_on, pixel_location, sram_read_data, curr_color, hcount, vcount)
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
                    if (unsigned(hcount) >= 0 and unsigned(hcount) <= 10) then
                        lcd_addr <= pixel_location & '1';
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(hcount) >= 790 and unsigned(hcount) <= 800) then
                        lcd_addr <= pixel_location & '1';
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 0 and unsigned(vcount) <= 10) then
                        lcd_addr <= pixel_location & '1';
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 470 and unsigned(vcount) <= 480) then
                        lcd_addr <= pixel_location & '1';
                        red_n <= curr_color(COLOR_WIDTH-1 downto 0);
                        green_n <= curr_color(2*COLOR_WIDTH-1 downto COLOR_WIDTH);
                    else
                        lcd_addr <= pixel_location & '1';
                        red_n <= sram_read_data(15 downto 8);
                        green_n <= sram_read_data(7 downto 0);                                                                       
                    end if;
                    next_state <= READ_SRAM_B;
                end if;

            when READ_SRAM_B =>
                if (video_on = '0') then
                    next_state <= IDLE;
                else
                    if (unsigned(hcount) >= 0 and unsigned(hcount) <= 10) then
                        lcd_addr <= pixel_location & '0';
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(hcount) >= 790 and unsigned(hcount) <= 800) then
                        lcd_addr <= pixel_location & '0';
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 0 and unsigned(vcount) <= 10) then
                        lcd_addr <= pixel_location & '0';
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    elsif (unsigned(vcount) >= 470 and unsigned(vcount) <= 480) then
                        lcd_addr <= pixel_location & '0';
                        blue_n <= curr_color(3*COLOR_WIDTH-1 downto 2*COLOR_WIDTH);
                    else
                        lcd_addr <= pixel_location & '0';
                        blue_n <= sram_read_data(15 downto 8);                                                                    
                    end if;
                    next_state <= READ_SRAM_RG;
                end if;

            when others => null;
        end case;
    end process;



-------------------------------------------------------------------------------- working lcd vhdl
    --process (clk_25MHz, rst)
    --begin
    --    if (rst = '1') then
    --        pixel_color <= (others => '0');
    --    elsif (clk'event and clk = '1') then
    --        pixel_color <= red;
    --    end if;
    --end process;

    --process (Hcount, Vcount)
    --begin
    --    red <= (others => '0');
    --    --green <= (others => '0');
    --    --blue <= (others => '0');

    --    if (unsigned(Hcount) >= 50 and unsigned(Hcount) < 800 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 480) then
    --        red <= "11111111";
    --    --elsif (unsigned(Hcount) >= 150 and unsigned(Hcount) < 250 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
    --    --    red <= "11111111";
    --    --    blue <= "00000000";
    --    --    green <= "00000000";
    --    --elsif (unsigned(Hcount) >= 250 and unsigned(Hcount) < 350 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
    --    --    red <= "00000000";
    --    --    blue <= "11111111";
    --    --    green <= "00000000";
    --    --elsif (unsigned(Hcount) >= 350 and unsigned(Hcount) < 450 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
    --    --    red <= "00000000";
    --    --    blue <= "00000000";
    --    --    green <= "11111111";
    --    end if;
    --end process;

end BHV;
