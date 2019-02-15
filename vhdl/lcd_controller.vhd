library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_controller is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        Horiz_Sync  : out std_logic;
        Vert_Sync   : out std_logic;
        pixel_color : out std_logic_vector(23 downto 0);
        den         : out std_logic;

        read_fifo_data  : in    std_logic_vector(35 downto 0);
        read_fifo_empty : in    std_logic;
        read_fifo_full  : in    std_logic;
        read_fifo_re    : out   std_logic
    );
end lcd_controller;

architecture BHV of lcd_controller is
    
    type STATE_TYPE is (WAIT_FOR_READ, READ_FIFO_0, READ_FIFO_1, HOLD_READ);
    signal state, next_state        : STATE_TYPE;

    signal clk_25MHz            : std_logic;

    signal red                  : std_logic_vector(7 downto 0);
    signal green                : std_logic_vector(7 downto 0);
    signal blue                 : std_logic_vector(7 downto 0);
    signal red_n                : std_logic_vector(7 downto 0);
    signal green_n              : std_logic_vector(7 downto 0);
    signal blue_n               : std_logic_vector(7 downto 0);

    signal pixel_color_n        : std_logic_vector(23 downto 0);
    signal color_pixel          : std_logic_vector(23 downto 0);
    signal color_pixel_n        : std_logic_vector(23 downto 0);
    signal read_fifo_re_n       : std_logic;
    signal pixel_write_addr     : std_logic_vector(18 downto 0);
    signal pixel_write_addr_n   : std_logic_vector(18 downto 0);
    

    signal pixel_location       : std_logic_vector(18 downto 0);

begin

    U_VGA_SYNC_GEN : entity work.lcd_sync_gen
        port map(
            clk             => clk,
            rst             => rst,
            Horiz_Sync      => Horiz_Sync,
            Vert_Sync       => Vert_Sync,
            Video_On        => den,
            pixel_location  => pixel_location,
            clk_25MHz_out   => clk_25MHz
        );

    process(clk, rst)
    begin
        if (rst = '1') then
            read_fifo_re <= '0';
            pixel_write_addr <= (others => '0');
            pixel_color <= (others => '0');
            color_pixel <= (others => '0');
            red <= (others => '0');
            green <= (others => '0');
            blue <= (others => '0');
            state <= WAIT_FOR_READ;
        elsif (clk'event and clk = '1') then
            read_fifo_re <= read_fifo_re_n;
            pixel_write_addr <= pixel_write_addr_n;
            pixel_color <= pixel_color_n;
            color_pixel <= color_pixel_n;
            red <= red_n;
            green <= green_n;
            blue <= blue_n;
            state <= next_state;
        end if;
    end process;

    --process (clk, rst)
    --begin
    --    if (rst = '1') then
    --        pixel_color <= (others => '0');
    --    elsif (clk'event and clk = '1') then
    --        pixel_color <= pixel_color_n;
    --    end if;
    --end process;

    process(state, pixel_location, color_pixel, pixel_write_addr, red, green, blue, read_fifo_empty, read_fifo_data)
    begin
        red_n <= red;
        green_n <= green;
        blue_n <= blue;

        pixel_color_n <= (others => '0');
        color_pixel_n <= color_pixel;
        read_fifo_re_n <= '0';
        pixel_write_addr_n <= pixel_write_addr;

        next_state <= state;

        case state is
            when WAIT_FOR_READ =>
                if (read_fifo_empty = '0') then
                    read_fifo_re_n <= '1';
                    next_state <= READ_FIFO_0;
                    --next_state <= HOLD_READ;
                end if;

            --when HOLD_READ =>
            --    read_fifo_re_n <= '1';

            when READ_FIFO_0 =>
                pixel_write_addr_n <= read_fifo_data(35 downto 17);
                red_n <= read_fifo_data(15 downto 8);
                green_n <= read_fifo_data(7 downto 0);
                if (read_fifo_empty = '0') then
                    read_fifo_re_n <= '1';
                    next_state <= READ_FIFO_1;
                end if;

            when READ_FIFO_1 =>
                blue_n <= read_fifo_data(15 downto 8);

                if (unsigned(pixel_write_addr) = unsigned(pixel_location)) then
                    color_pixel_n <= blue & green & red;
                    next_state <= WAIT_FOR_READ;
                end if;

            when others => null;
        end case;

        if (unsigned(pixel_write_addr) = unsigned(pixel_location)) then
            pixel_color_n <= color_pixel;
        end if;

    end process;



-------------------------------------------------------------------------------- working lcd vhdl
    --process (clk_25MHz, rst)
    --begin
    --    if (rst = '1') then
    --        red <= (others => '0');
    --        green <= (others => '0');
    --        blue <= (others => '0');
    --    elsif (clk_25MHz'event and clk_25MHz = '1') then
    --        red <= (others => '0');
    --        green <= (others => '0');
    --        blue <= (others => '0');

    --        if (unsigned(pixel_location) > 192300 and unsigned(pixel_location) < 192500) then
    --            red <= "11111111";
    --            blue <= "11111111";
    --            green <= "11111111";
    --        end if;
    --    end if;

    --    --if (unsigned(Hcount) >= 50 and unsigned(Hcount) < 150 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
    --    --    red <= "11111111";
    --    --    blue <= "11111111";
    --    --    green <= "11111111";
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
    --    --end if;
    --end process;

    --pixel_color <= blue & green & red;

end BHV;
