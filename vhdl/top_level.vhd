library ieee;
use ieee.std_logic_1164.all;
use work.LCD_LIB.all;

entity top_level is
    port(
        clk                 : in    std_logic;
        rst                 : in    std_logic;
        sck                 : in    std_logic;
        ss                  : in    std_logic;
        mosi                : in    std_logic;
        miso                : out   std_logic;

        -- sram_interface
        led0                : out   std_logic_vector(6 downto 0);
        led1                : out   std_logic_vector(6 downto 0);
        led2                : out   std_logic_vector(6 downto 0)

        -- lcd controller
        --Horiz_Sync  : out std_logic;
        --Vert_Sync   : out std_logic;
        --pixel_color : out std_logic_vector(23 downto 0);
        --den         : out std_logic;
        --pixel_clock : out std_logic;
        --pll_locked  : out std_logic
    );
end top_level;

architecture STR of top_level is

begin

    --U_PLL : entity work.pll_gen 
    --    PORT MAP (
    --        inclk0  => clk,
    --        c0      => pixel_clock,
    --        locked  => pll_locked
    --    );

    --U_LCD_CONTROLLER : entity work.lcd_controller
    --    port map(
    --        clk         => clk,
    --        rst         => rst,
    --        Horiz_Sync  => Horiz_Sync,
    --        Vert_Sync   => Vert_Sync,
    --        pixel_color => pixel_color,
    --        den         => den
    --    );

    --U_SRAM_INTERFACE : entity work.sram_interface
    --    port map (
    --        clk     => clk,
    --        rst     => rst,
    --        sck     => sck,
    --        ss      => ss,
    --        mosi    => mosi,
    --        miso    => miso,
    --        led0    => led0,
    --        led1    => led1,
    --        led2    => led2
    --    );

    U_SPI_SLAVE : entity work.spi_slave
    port map(
        clk                 => clk,
        rst                 => rst,
        sck                 => sck,
        ss                  => ss,
        mosi                => mosi,
        miso                => miso,
        sram_fifo_packet    => open,
        packet_flag         => open,
        led0                => led0,
        led1                => led1,
        led2                => led2
    );

end STR;
