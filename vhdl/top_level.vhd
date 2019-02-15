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

        -- sram_interfaces
        led0                : out   std_logic_vector(6 downto 0);
        led1                : out   std_logic_vector(6 downto 0);
        led2                : out   std_logic_vector(6 downto 0);
        received_byte       : out   std_logic_vector(7 downto 0);
        
        fifo_empty          : out   std_logic;
        fifo_read           : out   std_logic;
        fifo_we             : out   std_logic;

        -- lcd controller
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

    signal write_fifo_re    : std_logic;
    signal write_fifo_dout  : std_logic_vector(35 downto 0);
    signal write_fifo_empty : std_logic;
    signal write_fifo_full  : std_logic;

begin

    U_PLL : entity work.pll_gen 
        PORT MAP (
            areset   => rst,
            inclk0  => clk,
            c0      => pixel_clock,
            locked  => pll_locked
        );

    global_rst <= rst or ((not rst) and (not pll_locked));

    U_LCD_CONTROLLER : entity work.lcd_controller
        port map(
            clk                 => clk,
            rst                 => global_rst,
            Horiz_Sync          => Horiz_Sync,
            Vert_Sync           => Vert_Sync,
            pixel_color         => pixel_color,
            den                 => den,
            read_fifo_data      => write_fifo_dout,
            read_fifo_empty     => write_fifo_empty,
            read_fifo_full      => write_fifo_full,
            read_fifo_re        => write_fifo_re
        );

    U_SRAM_INTERFACE : entity work.sram_interface
        port map (
            clk                 => clk,
            rst                 => global_rst,
            sck                 => sck,
            ss                  => ss,
            mosi                => mosi,
            miso                => miso,
            write_fifo_re       => write_fifo_re,
            write_fifo_dout     => write_fifo_dout,
            write_fifo_empty    => write_fifo_empty,
            write_fifo_full     => write_fifo_full,

            fifo_we             => fifo_we,

            led0                => led0,
            led1                => led1,
            led2                => led2,
            received_byte       => received_byte
        );

    --U_SPI_SLAVE : entity work.spi_slave
    --port map(
    --    clk                 => clk,
    --    rst                 => global_rst,
    --    sck                 => sck,
    --    ss                  => ss,
    --    mosi                => mosi,
    --    miso                => miso,
    --    sram_fifo_packet    => open,
    --    packet_flag         => packet_flag,
    --    led0                => led0,
    --    led1                => led1,
    --    led2                => led2,
    --    received_byte        => received_byte
    --);


    fifo_empty <= write_fifo_empty;
    fifo_read  <= write_fifo_re;

end STR;
