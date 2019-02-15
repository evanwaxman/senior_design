library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_sync_gen is
    port(
        clk             : in    std_logic;
        rst             : in    std_logic;
        Horiz_Sync      : out   std_logic;
        Vert_Sync       : out   std_logic;
        Video_On        : out   std_logic;
        pixel_location  : out   std_logic_vector(18 downto 0);
        clk_25MHz_out   : out   std_logic
    );
end lcd_sync_gen;


architecture BHV of lcd_sync_gen is

    signal clk_25MHz : std_logic;
    signal Hcount_temp : std_logic_vector(9 downto 0);
    signal Vcount_temp : std_logic_vector(9 downto 0);

    signal pixel_cntr  : std_logic_vector(18 downto 0);

begin
    U_CLK_DIV : entity work.clk_div
        generic map(
            clk_in_freq => 50000000,
            clk_out_freq => 25000000
        )
        port map(
            clk_in => clk,
            clk_out => clk_25MHz,
            rst => rst
        );

    process(clk_25MHz, rst)
    begin
        if(rst = '1') then
            Hcount_temp <= (others => '0');
            Vcount_temp <= (others => '0');
            Video_On <= '1';
            Horiz_Sync <= '1';
            Vert_Sync <= '1';
            pixel_cntr <= (others => '0');
            --pixel_location <= (others => '0');
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
        end if;
    end process;

    pixel_location <= pixel_cntr;
    clk_25MHz_out <= clk_25MHz;


end BHV;
