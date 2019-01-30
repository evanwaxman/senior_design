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
        den         : out std_logic
    );
end lcd_rom_address;

architecture BHV of lcd_rom_address is

    signal Hcount           : std_logic_vector(9 downto 0);
    signal Vcount           : std_logic_vector(9 downto 0);
    signal red, green, blue : std_logic_vector(7 downto 0);

begin

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

    process(Hcount, Vcount)
    begin
        red <= "00000000";
        blue <= "00000000";
        green <= "00000000";


        if (unsigned(Hcount) >= 50 and unsigned(Hcount) < 150 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
            red <= "11111111";
            blue <= "11111111";
            green <= "11111111";
        elsif (unsigned(Hcount) >= 150 and unsigned(Hcount) < 250 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
            red <= "11111111";
            blue <= "00000000";
            green <= "00000000";
        elsif (unsigned(Hcount) >= 250 and unsigned(Hcount) < 350 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
            red <= "00000000";
            blue <= "11111111";
            green <= "00000000";
        elsif (unsigned(Hcount) >= 350 and unsigned(Hcount) < 450 and unsigned(Vcount) >= 100 and unsigned(Vcount) < 200) then
            red <= "00000000";
            blue <= "00000000";
            green <= "11111111";
        end if;
    end process;

    pixel_color <= blue & green & red;

end BHV;
