library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_sync_gen is
    port(
        clk_25MHz       : in    std_logic;
        rst             : in    std_logic;
        h_sync          : out   std_logic;
        v_sync          : out   std_logic;
        Video_On        : out   std_logic;
        pixel_location  : out   std_logic_vector(18 downto 0);
        Hcount          : out   std_logic_vector(9 downto 0);
        Vcount          : out   std_logic_vector(9 downto 0)
    );
end lcd_sync_gen;


architecture BHV of lcd_sync_gen is

    signal Hcount_temp : std_logic_vector(9 downto 0);
    signal Vcount_temp : std_logic_vector(9 downto 0);
    signal Horiz_Sync  : std_logic;
    signal Vert_Sync   : std_logic;

    signal pixel_cntr  : std_logic_vector(18 downto 0);

begin

    process(clk_25MHz, rst)
    begin
        if(rst = '1') then
            Hcount_temp <= (others => '0');
            Vcount_temp <= (others => '0');
            Video_On <= '0';
            Horiz_Sync <= '1';
            Vert_Sync <= '1';
            pixel_cntr <= (others => '0');
        elsif(clk_25MHz'event and clk_25MHz = '1') then
            if((unsigned(Hcount_temp) < H_DISPLAY_END) and unsigned(Vcount_temp) < V_DISPLAY_END) then
                pixel_cntr <= std_logic_vector(unsigned(pixel_cntr) + 1);
                Video_On <= '1';
            elsif (unsigned(Vcount_temp) >= V_DISPLAY_END) then
                pixel_cntr <= (others => '0');
                Video_On <= '0';
            else
                Video_On <= '0';
            end if;

            if(unsigned(Hcount_temp) > HSYNC_BEGIN and unsigned(Hcount_temp) < HSYNC_END) then
                Horiz_Sync <= '0';
                Hcount_temp <= std_logic_vector(unsigned(Hcount_temp) + 1);
            else
                Horiz_Sync <= '1';
                if(unsigned(Hcount_temp) = H_MAX) then
                    Hcount_temp <= (others => '0');
                else
                    Hcount_temp <= std_logic_vector(unsigned(Hcount_temp) + 1);
                end if;
            end if;

            if(unsigned(Hcount_temp) = H_VERT_INC) then
                Vcount_temp <= std_logic_vector(unsigned(Vcount_temp) + 1);
                if(unsigned(Vcount_temp) = V_MAX) then
                    Vcount_temp <= (others => '0');
                end if;
            end if;

            if(unsigned(Vcount_temp) > VSYNC_BEGIN and unsigned(Vcount_temp) < VSYNC_END) then
                Vert_Sync <= '0';
            else
                Vert_Sync <= '1';
            end if;

            h_sync <= Horiz_Sync;
            v_sync <= Vert_Sync;
        end if;
    end process;

    pixel_location <= pixel_cntr;
    Hcount <= Hcount_temp;
    Vcount <= Vcount_temp;

end BHV;
