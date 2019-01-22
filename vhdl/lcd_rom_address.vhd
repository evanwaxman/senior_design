library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_rom_address is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        Horiz_Sync  : out std_logic;
        Vert_Sync   : out std_logic;
        pixel_color : out std_logic_vector(23 downto 0);
        den         : out std_logic;
        pixel_clock : out std_logic
    );
end lcd_rom_address;

architecture BHV of lcd_rom_address is

    --signal Video_On         : std_logic;
    --signal row_address      : std_logic_vector(5 downto 0);
    --signal column_address   : std_logic_vector(5 downto 0);
    --signal rom_address      : std_logic_vector(11 downto 0);
    signal Hcount           : std_logic_vector(9 downto 0);
    signal Vcount           : std_logic_vector(9 downto 0);
    signal pixel_clock_temp : std_logic;



    signal red, green, blue : std_logic_vector(7 downto 0);

begin
    U_CLK_DIV : entity work.clk_div
        generic map(
            clk_in_freq => 50000000,
            clk_out_freq => 25000000
        )
        port map(
            clk_in => clk,
            clk_out => pixel_clock_temp,
            rst => rst
        );

    U_VGA_SYNC_GEN : entity work.lcd_sync_gen
        port map(
            clk         => clk,
            rst         => rst,
            Hcount      => Hcount,
            Vcount      => Vcount,
            Horiz_Sync  => Horiz_Sync,
            Vert_Sync   => Vert_Sync,
            Video_On    => den
        );

    --U_VGA_ROM : entity work.lcd_rom
    --    port map(
    --        address => rom_address,
    --        clock   => clk,
    --        q       => pixel_color
    --    );

    process(Hcount, Vcount)
    begin
        --column_address  <= (others => '0');
        --row_address     <= (others => '0');

        red <= "00000000";
        blue <= "00000000";
        green <= "00000000";


        if (unsigned(Hcount) > 100 and unsigned(Hcount) < 150 and unsigned(Vcount) > 100 and unsigned(Vcount) < 150) then
            red <= "11111111";
            blue <= "11111111";
            green <= "11111111";
        end if;

        --if(Video_On = '1') then
        --    column_address <= std_logic_vector(resize(unsigned(Hcount), 6));
        --    row_address <= std_logic_vector(resize(unsigned(Vcount), 6));
        --end if;
    end process;

    pixel_color <= blue & green & red;




    --rom_address(11 downto 6) <= row_address;
    --rom_address(5 downto 0) <= column_address;
    --den <= Video_On;
    pixel_clock <= pixel_clock_temp;
    --pixel_clock <= clk;

end BHV;
