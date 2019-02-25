library ieee;
use ieee.std_logic_1164.all;
use work.LCD_LIB.all;

entity top_level is
    port(
        clk                 : in        std_logic;
        rst                 : in        std_logic;
        sck                 : in        std_logic;
        ss                  : in        std_logic;
        mosi                : in        std_logic;
        miso                : out       std_logic;

        -- sram_interface
        led0                : out       std_logic_vector(6 downto 0);
        led1                : out       std_logic_vector(6 downto 0);
        led2                : out       std_logic_vector(6 downto 0);
        received_byte       : out       std_logic_vector(7 downto 0);
        sram_addr           : out       std_logic_vector(19 downto 0);
        sram_data           : inout     std_logic_vector(15 downto 0);
        sram_ce             : out       std_logic;
        sram_oe             : out       std_logic;
        sram_we             : out       std_logic;
        sram_bhe            : out       std_logic;
        sram_ble            : out       std_logic;

        -- lcd controller
        is_touched  : in  std_logic;
        Horiz_Sync  : out std_logic;
        Vert_Sync   : out std_logic;
        pixel_color : out std_logic_vector(23 downto 0);
        den         : out std_logic;
        pixel_clock : out std_logic
        --pll_locked  : out std_logic
    );
end top_level;

architecture STR of top_level is

    signal global_rst       : std_logic;
    signal pll_locked       : std_logic;
    signal clk_25MHz        : std_logic;

    signal lcd_addr         : std_logic_vector(19 downto 0);
    signal lcd_data         : std_logic_vector(15 downto 0);
    signal lcd_displaying   : std_logic;


begin

    U_PLL : entity work.pll_gen 
        PORT MAP (
            areset   => rst,
            inclk0  => clk,
            c0      => clk_25MHz,
            locked  => pll_locked
        );

    global_rst <= rst or ((not rst) and (not pll_locked));
    pixel_clock <= clk_25MHz;

    U_LCD_CONTROLLER : entity work.lcd_controller
        port map(
            clk             => clk,
            clk_25MHz       => clk_25MHz,
            rst             => global_rst,
            Horiz_Sync      => Horiz_Sync,
            Vert_Sync       => Vert_Sync,
            pixel_color     => pixel_color,
            den             => den,
            is_touched      => is_touched,
            lcd_addr        => lcd_addr,
            lcd_data        => lcd_data,
            lcd_displaying  => lcd_displaying
        );

    U_SRAM_INTERFACE : entity work.sram_interface
        port map (
            clk                 => clk,
            rst                 => global_rst,
            sck                 => sck,
            ss                  => ss,
            mosi                => mosi,
            miso                => miso,
            led0                => led0,
            led1                => led1,
            led2                => led2,
            received_byte       => received_byte,
            lcd_addr            => lcd_addr,
            lcd_data            => lcd_data,
            lcd_displaying      => lcd_displaying,
            write_fifo_full     => open,
            sram_addr           => sram_addr,
            sram_data           => sram_data,
            sram_ce             => sram_ce,
            sram_oe             => sram_oe,
            sram_we             => sram_we,
            sram_bhe            => sram_bhe,
            sram_ble            => sram_ble
        );

end STR;
