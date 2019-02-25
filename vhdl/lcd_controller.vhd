library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_controller is
    port(
        clk             : in        std_logic;
        clk_25MHz       : in        std_logic;
        rst             : in        std_logic;
        Horiz_Sync      : out       std_logic;
        Vert_Sync       : out       std_logic;
        pixel_color     : out       std_logic_vector(23 downto 0);
        den             : out       std_logic;

        is_touched      : in        std_logic;
        lcd_addr        : out       std_logic_vector(19 downto 0);
        lcd_data        : in        std_logic_vector(15 downto 0);
        lcd_displaying  : out       std_logic
    );
end lcd_controller;

architecture BHV of lcd_controller is
    
    type STATE_TYPE is (CALIBRATE_0, CALIBRATE_1, CALIBRATE_2, WAIT_FOR_TOUCH_CLEAR, IDLE, READ_SRAM_0, READ_SRAM_1);
    signal state, next_state, saved_state, saved_state_n        : STATE_TYPE;

    signal red                  : std_logic_vector(7 downto 0);
    signal green                : std_logic_vector(7 downto 0);
    signal blue                 : std_logic_vector(7 downto 0);
    signal red_n                : std_logic_vector(7 downto 0);
    signal green_n              : std_logic_vector(7 downto 0);
    signal blue_n               : std_logic_vector(7 downto 0);

    signal pixel_location       : std_logic_vector(18 downto 0);
    signal pixel_sram_addr      : std_logic_vector(19 downto 0);
    signal pixel_sram_addr_n    : std_logic_vector(19 downto 0);
    signal hcount               : std_logic_vector(9 downto 0);
    signal vcount               : std_logic_vector(9 downto 0);
    signal video_on             : std_logic;
    signal lcd_addr_n           : std_logic_vector(19 downto 0);
    signal lcd_displaying_n     : std_logic;

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

    den <= video_on;

    process(clk, rst)
    begin
        if (rst = '1') then
            red <= (others => '0');
            green <= (others => '0');
            blue <= (others => '0');
            lcd_addr <= (others => '0');
            lcd_displaying <= '1';
            saved_state <= CALIBRATE_0;
            state <= CALIBRATE_0;
        elsif (clk'event and clk = '1') then
            red <= red_n;
            green <= (others => '0');
            blue <= (others => '0');
            lcd_addr <= lcd_addr_n;
            lcd_displaying <= lcd_displaying_n;
            saved_state <= saved_state_n;
            state <= next_state;
        end if;
    end process;

    process(clk_25MHz, rst)
    begin
        if (rst = '1') then
            pixel_color <= (others => '0'); 
        elsif (clk_25MHz'event and clk_25MHz = '1') then
            pixel_color <= (blue & green & red);
        end if;
    end process;

    process(state, saved_state, is_touched, pixel_location, hcount, vcount, red, green, blue, video_on, lcd_data)
    begin
        red_n <= (others => '0');
        green_n <= (others => '0');
        blue_n <= (others => '0');

        lcd_addr_n <= (others => '0');
        lcd_displaying_n <= '1';

        saved_state_n <= saved_state;
        next_state <= state;

        case state is
            when CALIBRATE_0 =>
                -- output calibration point
                if (unsigned(hcount) >= CAL_POINT_0_X_MIN and unsigned(hcount) <= CAL_POINT_0_X_MAX and unsigned(vcount) >= CAL_POINT_0_Y_MIN and unsigned(vcount) <= CAL_POINT_0_Y_MAX) then
                    red_n <= (others => '1');
                end if;

                -- check if screen touched
                if (is_touched = '1') then
                    saved_state_n <= CALIBRATE_1;
                    next_state <= WAIT_FOR_TOUCH_CLEAR;
                end if;

            when CALIBRATE_1 =>
                -- output calibration point
                if (unsigned(hcount) > CAL_POINT_1_X_MIN and unsigned(hcount) < CAL_POINT_1_X_MAX and unsigned(vcount) > CAL_POINT_1_Y_MIN and unsigned(vcount) < CAL_POINT_1_Y_MAX) then
                    red_n <= (others => '1');
                end if;

                -- check if screen touched
                if (is_touched = '1') then
                    saved_state_n <= CALIBRATE_2;
                    next_state <= WAIT_FOR_TOUCH_CLEAR;
                end if;

            when CALIBRATE_2 =>
                -- output calibration point
                if (unsigned(hcount) > CAL_POINT_2_X_MIN and unsigned(hcount) < CAL_POINT_2_X_MAX and unsigned(vcount) > CAL_POINT_2_Y_MIN and unsigned(vcount) < CAL_POINT_2_Y_MAX) then
                    red_n <= (others => '1');
                end if;

                -- check if screen touched
                if (is_touched = '1') then
                    next_state <= IDLE;
                end if;

            when WAIT_FOR_TOUCH_CLEAR => 
                if (is_touched = '0') then
                    next_state <= saved_state;
                end if;

            when IDLE =>
                lcd_displaying_n <= '0';
                if (video_on = '1') then
                    lcd_displaying_n <= '1';
                    next_state <= READ_SRAM_0;
                end if;

            when READ_SRAM_0 =>
                lcd_displaying_n <= '1';
                lcd_addr_n <= pixel_location & '0';
                red_n <= lcd_data(15 downto 8);
                green_n <= lcd_data(7 downto 0);
                next_state <= READ_SRAM_1;

            when READ_SRAM_1 =>
                lcd_displaying_n <= '1';
                lcd_addr_n <= pixel_location & '1';
                blue_n <= lcd_data(15 downto 8);
                if (video_on = '0') then
                    lcd_displaying_n <= '0';
                    next_state <= IDLE;
                else
                    next_state <= READ_SRAM_0;
                end if;

            when others => null;
        end case;
    end process;



-------------------------------------------------------------------------------- working lcd vhdl
    --process (clk, rst)
    --begin
    --    if (rst = '1') then
    --        pixel_color <= (others => '0');
    --    elsif (clk'event and clk = '1') then
    --        pixel_color <= pixel_color_n;
    --    end if;
    --end process;

    --process (Hcount, Vcount)
    --begin
    --    red <= (others => '0');
    --    green <= (others => '0');
    --    blue <= (others => '0');

    --    if (unsigned(Hcount) >= 50 and unsigned(Hcount) < 150 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
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

    --    pixel_color_n <= blue & green & red;
    --end process;

end BHV;
