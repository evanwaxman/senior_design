library ieee;
use ieee.std_logic_1164.all;

entity tristate is
	generic (
		DATA_WIDTH 	: positive 	:= 16 
	);
	port (
		clk 		: in 	std_logic;
		output_en 	: in 	std_logic;
		din 		: in 	std_logic_vector(DATA_WIDTH-1 downto 0);
		dout 		: out 	std_logic_vector(DATA_WIDTH-1 downto 0);
		data_bus 	: inout std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end tristate;

architecture BHV of tristate is

	signal inp, outp 	: std_logic_vector(DATA_WIDTH-1 downto 0);

begin
	inp <= din;
	dout <= outp;

	process (output_en, data_bus, inp) begin
		if (output_en = '1') then
			data_bus <= inp;
			outp <= data_bus;
		else
			data_bus <= (others => 'Z');
			outp <= data_bus;
		end if;
	end process;
end architecture BHV;