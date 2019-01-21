library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity top_level_tb is
end top_level_tb;

architecture TB of top_level_tb is

    signal clk              : std_logic := '0';
    signal clk_out          : std_logic;
    signal rst              : std_logic;
    --signal Horiz_Sync       : std_logic;
    --signal Vert_Sync        : std_logic;
    --signal pixel_color      : std_logic_vector(11 downto 0);
    --signal den              : std_logic;
    --signal pixel_clock      : std_logic;
    signal done             : std_logic := '0';

begin
    --U_TOP_LEVEL : entity work.top_level
    --    port map(
    --        clk         => clk,
    --        rst         => rst,
    --        Horiz_Sync  => Horiz_Sync,
    --        Vert_Sync   => Vert_Sync,
    --        pixel_color => pixel_color,
    --        den         => den,
    --        pixel_clock => pixel_clock
    --    );

    U_CLK_DIV : entity work.clk_div
        generic map (
            clk_in_freq     => 50000000,
            clk_out_freq    => 25000000
        )
        port map (
            clk_in          => clk,
            clk_out         => clk_out,
            rst             => rst
        );


    clk <= not clk and not done after 10 ns;    -- 50 MHz clock

    process

    begin
        rst <= '1';
        wait for 220 ns;    -- Start on rising clock edge
        rst <= '0';
        wait for 1000 ms;
        done <= '1';
        wait;
    end process;
end TB;
