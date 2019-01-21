library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_div is
    generic(clk_in_freq  : natural := 4000;
            clk_out_freq : natural := 1000);
    port (
        clk_in  : in  std_logic;
        clk_out : out std_logic;
        rst     : in  std_logic);
end clk_div;


architecture DIV of clk_div is

signal div_count : integer;
constant MAX : integer := ((clk_in_freq/clk_out_freq)/2);

begin

	process(clk_in, rst)
		variable clk_toggle : std_logic;
	begin
		if (rst = '1') then
			clk_out <= '0';
			clk_toggle := '0';
			div_count <= 0;
		elsif (rising_edge(clk_in)) then
			if (div_count = MAX) then
				div_count <= 1;
				clk_toggle := not clk_toggle;
				clk_out <= clk_toggle;
			else
				div_count <= div_count + 1;
			end if;
		end if;
	end process;
    
end DIV;
