library ieee;
use ieee.std_logic_1164.all;

entity df_sync is
	port( 
		clk_dest	: in	std_logic;
		din			: in	std_logic;
		dout		: out	std_logic
	);
end df_sync;

architecture ARCH of df_sync is

	signal between_ffs : std_logic;

begin

	process(clk_dest)
	begin
		if(rising_edge(clk_dest)) then
			between_ffs <= din;
			dout <= between_ffs;
		end if;
	end process;
	
end ARCH;
