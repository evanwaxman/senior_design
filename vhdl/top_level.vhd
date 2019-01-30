library ieee;
use ieee.std_logic_1164.all;
use work.LCD_LIB.all;

entity top_level is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        Horiz_Sync  : out std_logic;
        Vert_Sync   : out std_logic;
        pixel_color : out std_logic_vector(23 downto 0);
        den         : out std_logic;
        pixel_clock : out std_logic;
        pll_locked  : out std_logic
    );
end top_level;

architecture STR of top_level is

begin

    U_PLL : entity work.pll_gen 
        PORT MAP (
            inclk0   => clk,
            c0   => pixel_clock,
            locked   => pll_locked
        );

    U_LCD_ROM_ADDRESS : entity work.lcd_rom_address
        port map(
            clk             => clk,
            rst             => rst,
            Horiz_Sync      => Horiz_Sync,
            Vert_Sync       => Vert_Sync,
            pixel_color     => pixel_color,
            den             => den
        );

end STR;
