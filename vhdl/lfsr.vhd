library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is
	port (
		clk 		: in 	std_logic;
		rst 		: in 	std_logic;
		game_start 	: in 	std_logic;
		random_seed	: in 	std_logic_vector(15 downto 0);
		lfsr_reg 	: out 	std_logic_vector(15 downto 0)
	);
	
end entity lfsr;

architecture BHV of lfsr is

	signal lfsr_reg_temp 	: std_logic_vector(15 downto 0);

begin

	process (clk, rst)
	begin
		if (rst = '1') then
			lfsr_reg_temp <= "0000000001000010";
		elsif (rising_edge(clk)) then
			if (game_start = '1') then
				lfsr_reg_temp <= random_seed;
			else
				lfsr_reg_temp(14 downto 0) <= lfsr_reg_temp(15 downto 1);
				lfsr_reg_temp(15) <= lfsr_reg_temp(0);
				lfsr_reg_temp(13) <= lfsr_reg_temp(0) xor lfsr_reg_temp(14);
				lfsr_reg_temp(12) <= lfsr_reg_temp(0) xor lfsr_reg_temp(13);
				lfsr_reg_temp(10) <= lfsr_reg_temp(0) xor lfsr_reg_temp(11);
			end if;
		end if;
	end process;

	lfsr_reg <= lfsr_reg_temp;

end BHV;