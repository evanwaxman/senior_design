library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LCD_LIB.all;

entity CR_game_logic is
	generic (
		COLOR_WIDTH         	: positive := 8
	);
	port (
		clk 					: in 	std_logic;
		clk_25MHz				: in 	std_logic;
		rst 					: in 	std_logic;
		hcount 					: in 	std_logic_vector(9 downto 0);
		vcount 					: in 	std_logic_vector(9 downto 0);
		random_seed 			: in 	std_logic_vector(15 downto 0);
		game_start 				: in 	std_logic;
		game_on 				: in 	std_logic;
        up_button_pressed    	: in    std_logic;
        down_button_pressed  	: in    std_logic;
        right_button_pressed 	: in    std_logic;
        left_button_pressed  	: in    std_logic;
        a_button_pressed   		: in    std_logic;
        b_button_pressed     	: in    std_logic;
        game_over 				: out 	std_logic;
        game_red 				: out 	std_logic_vector(COLOR_WIDTH-1 downto 0);
        game_green 				: out 	std_logic_vector(COLOR_WIDTH-1 downto 0);
        game_blue 				: out 	std_logic_vector(COLOR_WIDTH-1 downto 0);
        button_checked 			: out 	std_logic
	);
	
end entity CR_game_logic;

architecture BHV of CR_game_logic is

	signal clk_1Hz 			: std_logic;
	signal player_loc_reg 	: std_logic_vector(14 downto 0);
	signal obstacle_gen_reg	: std_logic_vector(14 downto 0);
	signal lfsr_reg 		: std_logic_vector(15 downto 0);
	signal obstacle_color 	: std_logic_vector(23 downto 0);
	signal player_color 	: std_logic_vector(23 downto 0);

	signal obstacle_lane_0 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_1 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_2 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_3 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_4 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_5 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_6 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_7 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_8 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_9 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_10 : std_logic_vector(9 downto 0);
	signal obstacle_lane_11 : std_logic_vector(9 downto 0);
	signal obstacle_lane_12 : std_logic_vector(9 downto 0);
	signal obstacle_lane_13	: std_logic_vector(9 downto 0);
	signal obstacle_lane_14	: std_logic_vector(9 downto 0);

	signal obstacle_lane_0_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_1_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_2_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_3_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_4_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_5_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_6_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_7_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_8_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_9_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_10_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_11_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_12_n 	: std_logic_vector(9 downto 0);
	signal obstacle_lane_13_n	: std_logic_vector(9 downto 0);
	signal obstacle_lane_14_n	: std_logic_vector(9 downto 0);

begin

	U_LFSR : entity work.lfsr
		port map (
			clk 			=> clk_1Hz,
			rst 			=> rst,
			game_start 		=> game_start,
			random_seed 	=> random_seed,
			lfsr_reg 		=> lfsr_reg
		);

	U_OBSTACLE_GEN : entity work.obstacle_gen 
		port map (
			clk 				=> clk_1Hz,
			rst 				=> rst,
			lfsr_reg 			=> lfsr_reg,
			obstacle_gen_reg 	=> obstacle_gen_reg
		);

	U_CLK_DIV  : entity work.clk_div
        generic map (
            clk_in_freq     => 50000000, 
            clk_out_freq    => 1
        )
        port map (
            clk_in          => clk,
            clk_out         => clk_1Hz,
            rst             => rst
        );

    ---------------------------------------------------------------------------- move player
	process (clk_25MHz, rst)
	begin
		if (rst = '1') then
			player_loc_reg <= "000000010000000";
		elsif (rising_edge(clk_25MHz)) then
			if (game_on = '1') then
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

	---------------------------------------------------------------------------- shift obstacles
	process (clk_1Hz, rst)
	begin
		if (rst = '1') then
			obstacle_lane_0 <= (others => '0');
			obstacle_lane_1 <= (others => '0');
			obstacle_lane_2 <= (others => '0');
			obstacle_lane_3 <= (others => '0');
			obstacle_lane_4 <= (others => '0');
			obstacle_lane_5 <= (others => '0');
			obstacle_lane_6 <= (others => '0');
			obstacle_lane_7 <= (others => '0');
			obstacle_lane_8 <= (others => '0');
			obstacle_lane_9 <= (others => '0');
			obstacle_lane_10 <= (others => '0');
			obstacle_lane_11 <= (others => '0');
			obstacle_lane_12 <= (others => '0');
			obstacle_lane_13 <= (others => '0');
			obstacle_lane_14 <= (others => '0');
		elsif (rising_edge(clk_1Hz)) then
			obstacle_lane_0 <= obstacle_lane_0(8 downto 0) & obstacle_gen_reg(0);
			obstacle_lane_1 <= obstacle_lane_1(8 downto 0) & obstacle_gen_reg(1);
			obstacle_lane_2 <= obstacle_lane_2(8 downto 0) & obstacle_gen_reg(2);
			obstacle_lane_3 <= obstacle_lane_3(8 downto 0) & obstacle_gen_reg(3);
			obstacle_lane_4 <= obstacle_lane_4(8 downto 0) & obstacle_gen_reg(4);
			obstacle_lane_5 <= obstacle_lane_5(8 downto 0) & obstacle_gen_reg(5);
			obstacle_lane_6 <= obstacle_lane_6(8 downto 0) & obstacle_gen_reg(6);
			obstacle_lane_7 <= obstacle_lane_7(8 downto 0) & obstacle_gen_reg(7);
			obstacle_lane_8 <= obstacle_lane_8(8 downto 0) & obstacle_gen_reg(8);
			obstacle_lane_9 <= obstacle_lane_9(8 downto 0) & obstacle_gen_reg(9);
			obstacle_lane_10 <= obstacle_lane_10(8 downto 0) & obstacle_gen_reg(10);
			obstacle_lane_11 <= obstacle_lane_11(8 downto 0) & obstacle_gen_reg(11);
			obstacle_lane_12 <= obstacle_lane_12(8 downto 0) & obstacle_gen_reg(12);
			obstacle_lane_13 <= obstacle_lane_13(8 downto 0) & obstacle_gen_reg(13);
			obstacle_lane_14 <= obstacle_lane_14(8 downto 0) & obstacle_gen_reg(14);
		end if;
	end process;


	obstacle_color <= "00000000" & "11111111" & "11111111";
	player_color <= "11111111" & "11111111" & "00000000";


	game_over <= ((player_loc_reg(0) and obstacle_lane_0(9)) or (player_loc_reg(1) and obstacle_lane_1(9)) or (player_loc_reg(2) and obstacle_lane_2(9)) or (player_loc_reg(3) and obstacle_lane_3(9)) or (player_loc_reg(4) and obstacle_lane_4(9)) or (player_loc_reg(5) and obstacle_lane_5(9)) or (player_loc_reg(6) and obstacle_lane_6(9)) or (player_loc_reg(7) and obstacle_lane_7(9)) or (player_loc_reg(8) and obstacle_lane_8(9)) or (player_loc_reg(9) and obstacle_lane_9(9)) or (player_loc_reg(10) and obstacle_lane_10(9)) or (player_loc_reg(11) and obstacle_lane_11(9)) or (player_loc_reg(12) and obstacle_lane_12(9)) or (player_loc_reg(13) and obstacle_lane_13(9)) or (player_loc_reg(14) and obstacle_lane_14(9)));


	process (player_loc_reg, obstacle_gen_reg, obstacle_color, player_color, hcount, vcount, obstacle_lane_0, obstacle_lane_1, obstacle_lane_2, obstacle_lane_3, obstacle_lane_4, obstacle_lane_5, obstacle_lane_6, obstacle_lane_7, obstacle_lane_8, obstacle_lane_9, obstacle_lane_10, obstacle_lane_11, obstacle_lane_12, obstacle_lane_13, obstacle_lane_14)
	begin
		game_red <= (others => '0');
		game_green <= (others => '0');
		game_blue <= (others => '0');

		------------------------------------------------------------------------ DISPLAY PLAYER
		if (unsigned(vcount) > 432 and unsigned(vcount) <= 480) then
			case player_loc_reg is
				when "000000000000001" =>
					if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000000000000010" =>
					if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;					

				when "000000000000100" =>
					if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000000000001000" =>
					if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000000000010000" =>
					if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000000000100000" =>
					if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000000001000000" =>
					if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000000010000000" =>
					if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000000100000000" =>
					if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000001000000000" =>
					if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000010000000000" =>
					if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "000100000000000" =>
					if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "001000000000000" =>
					if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "010000000000000" =>
					if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when "100000000000000" =>
					if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
						game_red <= player_color(23 downto 16);
						game_green <= player_color(15 downto 8);
						game_blue <= player_color(7 downto 0);
					end if;

				when others => null;
			end case;
		end if;

-------------------------------------------------------------------------------- DISPLAY OBSTACLES
		if (unsigned(vcount) >= 0 and unsigned(vcount) <= 48) then	---------- ROW 0
			if (obstacle_lane_0(0) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(0) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(0) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(0) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(0) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(0) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(0) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(0) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(0) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(0) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(0) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(0) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(0) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(0) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(0) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 48 and unsigned(vcount) <= 96) then	------- ROW 1
			if (obstacle_lane_0(1) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(1) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(1) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(1) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(1) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(1) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(1) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(1) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(1) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(1) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(1) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(1) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(1) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(1) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(1) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 96 and unsigned(vcount) <= 144) then	------- ROW 2
			if (obstacle_lane_0(2) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(2) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(2) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(2) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(2) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(2) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(2) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(2) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(2) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(2) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(2) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(2) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(2) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(2) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(2) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 144 and unsigned(vcount) <= 192) then	------- ROW 3
			if (obstacle_lane_0(3) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(3) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(3) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(3) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(3) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(3) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(3) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(3) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(3) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(3) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(3) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(3) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(3) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(1) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(3) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 192 and unsigned(vcount) <= 240) then	------- ROW 4
			if (obstacle_lane_0(4) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(4) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(4) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(4) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(4) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(4) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(4) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(4) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(4) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(4) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(4) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(4) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(4) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(4) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(4) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 240 and unsigned(vcount) <= 288) then	------- ROW 5
			if (obstacle_lane_0(5) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(5) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(5) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(5) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(5) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(5) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(5) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(5) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(5) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(5) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(5) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(5) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(5) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(5) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(5) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 288 and unsigned(vcount) <= 336) then	------- ROW 6
			if (obstacle_lane_0(6) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(6) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(6) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(6) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(6) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(6) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(6) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(6) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(6) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(6) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(6) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(6) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(6) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(6) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(6) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 336 and unsigned(vcount) <= 384) then	------- ROW 7
			if (obstacle_lane_0(7) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(7) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(7) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(7) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(7) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(7) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(7) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(7) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(7) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(7) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(7) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(7) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(7) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(7) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(7) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 384 and unsigned(vcount) <= 432) then	------- ROW 8
			if (obstacle_lane_0(8) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(8) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(8) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(8) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(8) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(8) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(8) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(8) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(8) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(8) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(8) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(8) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(8) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(8) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(8) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		elsif (unsigned(vcount) > 432 and unsigned(vcount) <= 480) then	------- ROW 9
			if (obstacle_lane_0(9) = '1') then
				if (unsigned(hcount) >= 754 and unsigned(hcount) <= 800) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			elsif (obstacle_lane_1(9) = '1') then
				if (unsigned(hcount) >= 700 and unsigned(hcount) <= 748) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;					
			elsif (obstacle_lane_2(9) = '1') then
				if (unsigned(hcount) >= 646 and unsigned(hcount) <= 694) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_3(9) = '1') then
				if (unsigned(hcount) >= 592 and unsigned(hcount) <= 640) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_4(9) = '1') then
				if (unsigned(hcount) >= 538 and unsigned(hcount) <= 586) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_5(9) = '1') then
				if (unsigned(hcount) >= 484 and unsigned(hcount) <= 532) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_6(9) = '1') then
				if (unsigned(hcount) >= 430 and unsigned(hcount) <= 478) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_7(9) = '1') then
				if (unsigned(hcount) >= 376 and unsigned(hcount) <= 424) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_8(9) = '1') then
				if (unsigned(hcount) >= 322 and unsigned(hcount) <= 370) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_9(9) = '1') then
				if (unsigned(hcount) >= 268 and unsigned(hcount) <= 316) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_10(9) = '1') then
				if (unsigned(hcount) >= 214 and unsigned(hcount) <= 262) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_11(9) = '1') then
				if (unsigned(hcount) >= 160 and unsigned(hcount) <= 208) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_12(9) = '1') then
				if (unsigned(hcount) >= 106 and unsigned(hcount) <= 154) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_13(9) = '1') then
				if (unsigned(hcount) >= 54 and unsigned(hcount) <= 100) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;

			elsif (obstacle_lane_14(9) = '1') then
				if (unsigned(hcount) >= 0 and unsigned(hcount) <= 46) then
					game_red <= obstacle_color(23 downto 16);
					game_green <= obstacle_color(15 downto 8);
					game_blue <= obstacle_color(7 downto 0);
				end if;
			end if;
		end if;
	end process;

end BHV;