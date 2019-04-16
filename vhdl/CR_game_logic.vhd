library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity CR_game_logic is
	generic (
		COLOR_WIDTH         	: positive := 8
	);
	port (
		clk_25MHz				: in 	std_logic;
		rst 					: in 	std_logic;
		hcount 					: in 	std_logic_vector(9 downto 0);
		vcount 					: in 	std_logic_vector(9 downto 0);
		game_start 				: in 	std_logic;
        up_button_pressed    	: in    std_logic;
        down_button_pressed  	: in    std_logic;
        right_button_pressed 	: in    std_logic;
        left_button_pressed  	: in    std_logic;
        a_button_pressed   		: in    std_logic;
        b_button_pressed     	: in    std_logic;
        --game_over 			: out 	std_logic;
        game_red 				: out 	std_logic_vector(COLOR_WIDTH-1 downto 0);
        game_green 				: out 	std_logic_vector(COLOR_WIDTH-1 downto 0);
        game_blue 				: out 	std_logic_vector(COLOR_WIDTH-1 downto 0);
        button_checked 			: out 	std_logic
	);
	
end entity CR_game_logic;

architecture BHV of CR_game_logic is

	signal player_loc_reg 	: std_logic_vector(14 downto 0);

begin
	process (clk_25MHz, rst)
	begin
		if (rst = '1') then
			player_loc_reg <= "000000010000000";
		elsif (rising_edge(clk_25MHz)) then
			if (game_start = '1') then
				if (left_button_pressed = '1') then
					button_checked <= '1';
					if (player_loc_reg(14) = '0') then
						player_loc_reg <= std_logic_vector(shift_left(unsigned(player_loc_reg), 1));
					end if;
				elsif (right_button_pressed = '1') then
					button_checked <= '1';
					if (player_loc_reg(0) = '0') then
						player_loc_reg <= std_logic_vector(shift_right(unsigned(player_loc_reg), 1));
					end if;
				else
					button_checked <= '0';
				end if;
			end if;
		end if;
	end process;

	process (player_loc_reg, hcount, vcount)
	begin
		game_red <= (others => '0');
		game_green <= (others => '0');
		game_blue <= (others => '0');

		if (unsigned(vcount) >= 432 and unsigned(vcount) <= 480) then
			case player_loc_reg is
				when "000000000000001" =>
					if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000000000000010" =>
					if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;					

				when "000000000000100" =>
					if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000000000001000" =>
					if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000000000010000" =>
					if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000000000100000" =>
					if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000000001000000" =>
					if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000000010000000" =>
					if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000000100000000" =>
					if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000001000000000" =>
					if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000010000000000" =>
					if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "000100000000000" =>
					if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "001000000000000" =>
					if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "010000000000000" =>
					if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when "100000000000000" =>
					if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
						game_red <= (others => '1');
						game_green <= (others => '0');
						game_blue <= (others => '0');
					end if;

				when others => null;
			end case;
		end if;
	end process;

end BHV;