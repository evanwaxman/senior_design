library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity lcd_sync_gen is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        Hcount      : buffer std_logic_vector(9 downto 0);
        Vcount      : buffer std_logic_vector(9 downto 0);
        Horiz_Sync  : out std_logic;
        Vert_Sync   : out std_logic;
        Video_On    : out std_logic
    );
end lcd_sync_gen;


architecture BHV of lcd_sync_gen is

    signal pixel_clock : std_logic;

begin
    U_CLK_DIV : entity work.clk_div
        generic map(
            clk_in_freq => 50000000,
            clk_out_freq => 25000000
        )
        port map(
            clk_in => clk,
            clk_out => pixel_clock,
            rst => rst
        );

    process(pixel_clock, rst)
    --    variable Hcount, Vcount : unsigned(9 downto 0);
    begin
        if(rst = '1') then
            Hcount <= (others => '0');
            Vcount <= (others => '0');
            Video_On <= '1';
            Horiz_Sync <= '1';
            Vert_Sync <= '1';
        elsif(rising_edge(pixel_clock)) then
            if((unsigned(Hcount) < H_DISPLAY_END or unsigned(Hcount) >= H_MAX) and unsigned(Vcount) < V_DISPLAY_END) then
                Video_On <= '1';
            else
                Video_On <= '0';
            end if;

            if(unsigned(Hcount) >= HSYNC_BEGIN and unsigned(Hcount) <= HSYNC_END) then
                Horiz_Sync <= '0';
                Hcount <= std_logic_vector(unsigned(Hcount) + 1);
            else
                Horiz_Sync <= '1';
                if(unsigned(Hcount) = H_MAX) then
                    Hcount <= (others => '0');
                else
                    Hcount <= std_logic_vector(unsigned(Hcount) + 1);
                end if;
            end if;

            if(unsigned(Hcount) = H_VERT_INC) then
                Vcount <= std_logic_vector(unsigned(Vcount) + 1);
                if(unsigned(Vcount) = V_MAX) then
                    Vcount <= (others => '0');
                end if;
            end if;

            if(unsigned(Vcount) >= VSYNC_BEGIN and unsigned(Vcount) <= VSYNC_END) then
                Vert_Sync <= '0';
            else
                Vert_Sync <= '1';
            end if;
        end if;
    end process;
end BHV;
