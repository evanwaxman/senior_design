library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_controller is
    port(
        clk             : in        std_logic;
        clk_25MHz       : in        std_logic;
        rst             : in        std_logic;
        video_on        : in        std_logic;
        pixel_location  : in        std_logic_vector(18 downto 0);
        pixel_color     : out       std_logic_vector(7 downto 0);

        -- sram signals
        lcd_addr        : out       std_logic_vector(19 downto 0);
        sram_read_data  : in        std_logic_vector(15 downto 0);
        lcd_status      : out       std_logic
    );
end lcd_controller;

architecture BHV of lcd_controller is
    
    type STATE_TYPE is (INIT, IDLE, READ_SRAM);
    signal state, next_state, saved_state, saved_state_n        : STATE_TYPE;

    signal red                  : std_logic_vector(7 downto 0);
    signal red_n                : std_logic_vector(7 downto 0);
    signal pixel_color_n        : std_logic_vector(23 downto 0);

    signal hcount               : std_logic_vector(9 downto 0);
    signal vcount               : std_logic_vector(9 downto 0);
    --signal lcd_addr_n           : std_logic_vector(19 downto 0);
    signal sram_read_en_n       : std_logic;

begin


    lcd_status <= video_on;


    process(clk_25MHz, rst)
    begin
        if (rst = '1') then
            pixel_color <= (others => '0'); 
            --lcd_addr <= (others => '0');
            state <= INIT;
        elsif (clk_25MHz'event and clk_25MHz = '1') then
            pixel_color <= red_n;
            --lcd_addr <= lcd_addr_n;
            state <= next_state;
        end if;
    end process;

    process(state, video_on, pixel_location, sram_read_data)
    begin
        red_n <= "00000000";
        lcd_addr <= (others => '0');
        next_state <= state;

        case state is
            when INIT =>
                next_state <= READ_SRAM;

            when IDLE =>
                if (video_on = '1') then
                    lcd_addr <= '0' & pixel_location;
                    red_n <= sram_read_data(15 downto 8);
                    next_state <= READ_SRAM;
                end if;

            when READ_SRAM =>
                if (video_on = '0') then
                    next_state <= IDLE;
                else
                    lcd_addr <= '0' & pixel_location;
                    red_n <= sram_read_data(15 downto 8);
                end if;

            --when READ_SRAM_1 =>
            --    lcd_addr_n <= pixel_addr_1;
            --    --blue_n <= sram_read_data(15 downto 8);

            --    if ((unsigned(hcount) >= H_DISPLAY_END and unsigned(hcount) < H_MAX) or (unsigned(vcount) >= V_DISPLAY_END and unsigned(vcount) < V_MAX)) then
            --        next_state <= IDLE;
            --    else
            --        next_state <= READ_SRAM_0;
            --    end if;

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
