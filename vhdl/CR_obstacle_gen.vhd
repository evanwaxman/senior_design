library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity obstacle_gen is
	port (
		clk 				: in 	std_logic;
		rst 				: in 	std_logic;
		lfsr_reg  			: in  	std_logic_vector(15 downto 0);
		obstacle_gen_reg 	: out 	std_logic_vector(14 downto 0)
	);
	
end entity obstacle_gen;

architecture BHV of obstacle_gen is

begin
	process (rst, clk)
	begin
		if (rst = '1') then
			obstacle_gen_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			--if (lfsr_reg(0) = '1') then
				case to_integer(unsigned(lfsr_reg)) is
					when 0 to 4369 =>
						obstacle_gen_reg <= "000000000000001";

					when 4370 to 8738 =>
						obstacle_gen_reg <= "000000000000010";
						
					when 8739 to 13107 =>
						obstacle_gen_reg <= "000000000000100";
						
					when 13108 to 17476 =>
						obstacle_gen_reg <= "000000000001000";
						
					when 17477 to 21845 =>
						obstacle_gen_reg <= "000000000010000";
						
					when 21846 to 26214 =>
						obstacle_gen_reg <= "000000000100000";
						
					when 26215 to 30583 =>
						obstacle_gen_reg <= "000000001000000";
						
					when 30584 to 34952 =>
						obstacle_gen_reg <= "000000010000000";
						
					when 34953 to 39321 =>
						obstacle_gen_reg <= "000000100000000";
						
					when 39322 to 43690 => 
						obstacle_gen_reg <= "000001000000000";
						
					when 43691 to 48059 =>
						obstacle_gen_reg <= "000010000000000";
						
					when 48060 to 52428 =>
						obstacle_gen_reg <= "000100000000000";
						
					when 52429 to 56797 =>
						obstacle_gen_reg <= "001000000000000";
						
					when 56798 to 61166 =>
						obstacle_gen_reg <= "010000000000000";
						
					when 61167 to 65535 =>
						obstacle_gen_reg <= "100000000000000";
						
					when others => null;
				end case;
			--end if;
		end if;
	end process;

end BHV;