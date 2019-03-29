library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder7seg is
	port(
		input : in std_logic_vector(3 downto 0);
		output : out std_logic_vector(6 downto 0)
		);
end decoder7seg;

architecture DECODE1 of decoder7seg is
begin
	
	process(input)
	begin
		case input is
			when std_logic_vector(to_unsigned(0,4)) =>
				output <= std_logic_vector(to_unsigned(1,7));
			when std_logic_vector(to_unsigned(1,4)) =>
				output <= std_logic_vector(to_unsigned(79,7));
			when std_logic_vector(to_unsigned(2,4)) =>
				output <= std_logic_vector(to_unsigned(18,7));
			when std_logic_vector(to_unsigned(3,4)) =>
				output <= std_logic_vector(to_unsigned(6,7));
			when std_logic_vector(to_unsigned(4,4)) =>
				output <= std_logic_vector(to_unsigned(76,7));
			when std_logic_vector(to_unsigned(5,4)) =>
				output <= std_logic_vector(to_unsigned(36,7));
			when std_logic_vector(to_unsigned(6,4)) =>
				output <= std_logic_vector(to_unsigned(32,7));
			when std_logic_vector(to_unsigned(7,4)) =>
				output <= std_logic_vector(to_unsigned(15,7));
			when std_logic_vector(to_unsigned(8,4)) =>
				output <= std_logic_vector(to_unsigned(0,7));
			when std_logic_vector(to_unsigned(9,4)) =>
				output <= std_logic_vector(to_unsigned(12,7));
			when std_logic_vector(to_unsigned(10,4)) =>
				output <= std_logic_vector(to_unsigned(8,7));
			when std_logic_vector(to_unsigned(11,4)) =>
				output <= std_logic_vector(to_unsigned(96,7));
			when std_logic_vector(to_unsigned(12,4)) =>
				output <= std_logic_vector(to_unsigned(49,7));
			when std_logic_vector(to_unsigned(13,4)) =>
				output <= std_logic_vector(to_unsigned(66,7));
			when std_logic_vector(to_unsigned(14,4)) =>
				output <= std_logic_vector(to_unsigned(48,7));
			when std_logic_vector(to_unsigned(15,4)) =>
				output <= std_logic_vector(to_unsigned(56,7));
			when others =>
				null;
		end case;
	end process;
end DECODE1;