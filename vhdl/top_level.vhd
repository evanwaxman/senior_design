library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity top_level is
    generic(
        COLOR_WIDTH     : positive := 8;
        OFFSET_WIDTH    : positive := 3;
        SRAM_DATA_WIDTH : positive := 16;
        SRAM_ADDR_WIDTH : positive := 20
    );
    port(
        clk             : in    std_logic;
        rst             : in    std_logic;

        -- spi inputs
        sck             : in    std_logic;
        ss              : in    std_logic;
        mosi            : in    std_logic;
        miso            : out   std_logic;

        -- sram interface
        sram_addr       : out   std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
        sram_data_bus   : inout std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
        sram_ce         : out   std_logic;
        sram_oe         : out   std_logic;
        sram_we         : out   std_logic;
        sram_bhe        : out   std_logic;
        sram_ble        : out   std_logic;

        -- lcd interface
        h_sync          : out   std_logic;
        v_sync          : out   std_logic;
        pixel_color     : out   std_logic_vector((3*COLOR_WIDTH)-1 downto 0);
        den             : out   std_logic;
        pixel_clock     : out   std_logic;
        on_off          : out   std_logic;
        brush_size      : in    std_logic_vector(2 downto 0);
        erase_screen    : in    std_logic;
        up_button       : in    std_logic;
        down_button     : in    std_logic;
        right_button    : in    std_logic;
        left_button     : in    std_logic;
        a_button        : in    std_logic;
        b_button        : in    std_logic;


        -- pll output
        pll_locked_out      : out std_logic
    );
end top_level;

architecture STR of top_level is

    signal rst_n            : std_logic;
    signal global_rst       : std_logic;
    signal pll_locked       : std_logic;
    signal clk_25MHz        : std_logic;
    signal lcd_addr         : std_logic_vector(SRAM_ADDR_WIDTH-1 downto 0);
    signal lcd_status       : std_logic;
    signal sram_read_data   : std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
    signal sram_ready       : std_logic;
    signal curr_color       : std_logic_vector((3*COLOR_WIDTH)-1 downto 0);

    signal brush_width      : std_logic_vector(OFFSET_WIDTH downto 0);

begin

    on_off <= '1';

    rst_n <= not rst;

    U_PLL : entity work.pll_gen 
        PORT MAP (
            areset   => rst_n,
            inclk0  => clk,
            c0      => clk_25MHz,
            locked  => pll_locked
        );

    global_rst <= rst_n or ((not rst_n) and (not pll_locked));
    pixel_clock <= clk_25MHz;

    pll_locked_out <= not pll_locked;

    brush_width <= '0' & brush_size(2 downto 0);

    U_LCD_INTERFACE : entity work.lcd_interface
        generic map (
            COLOR_WIDTH     => COLOR_WIDTH,
            OFFSET_WIDTH    => OFFSET_WIDTH,
            SRAM_DATA_WIDTH => SRAM_DATA_WIDTH,
            SRAM_ADDR_WIDTH => SRAM_ADDR_WIDTH
        )
        port map(
            clk             => clk,
            clk_25MHz       => clk_25MHz,
            rst             => sram_ready,
            h_sync          => h_sync,
            v_sync          => v_sync,
            pixel_color     => pixel_color,
            den             => den,
            brush_width     => std_logic_vector(shift_left(unsigned(brush_width), 1)),
            up_button       => up_button,
            down_button     => down_button,
            right_button    => right_button,
            left_button     => left_button,
            a_button        => a_button,
            b_button        => b_button,
            lcd_addr        => lcd_addr,
            sram_read_data  => sram_read_data,
            lcd_status      => lcd_status,
            curr_color      => curr_color
        );



    U_SRAM_INTERFACE : entity work.sram_interface
        generic map (
            OFFSET_WIDTH        => OFFSET_WIDTH,
            SRAM_DATA_WIDTH     => SRAM_DATA_WIDTH,
            SRAM_ADDR_WIDTH     => SRAM_ADDR_WIDTH
        )
        port map (
            clk                 => clk,
            rst                 => global_rst,
            sck                 => sck,
            ss                  => ss,
            mosi                => mosi,
            miso                => miso,
            sram_ready          => sram_ready,  
            lcd_addr            => lcd_addr,
            lcd_status          => lcd_status,
            brush_width         => std_logic_vector(shift_left(unsigned(brush_width), 1)),
            erase_screen        => erase_screen,
            curr_color          => curr_color,
            --write_fifo_full     => open,
            sram_read_data      => sram_read_data,
            sram_addr           => sram_addr,
            sram_data_bus       => sram_data_bus,
            sram_ce             => sram_ce,
            sram_oe             => sram_oe,
            sram_we             => sram_we,
            sram_bhe            => sram_bhe,
            sram_ble            => sram_ble
        );

end STR;
