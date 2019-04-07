library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pixel_test is
	generic (
		OFFSET_WIDTH 	 	: positive 	:= 3;
		ADDRESS_WIDTH 		: positive 	:= 20;
		PACKET_WIDTH 		: positive 	:= 36
	);
	port (
		clk 				: in 	std_logic;
		rst 				: in 	std_logic;
		address 			: in 	std_logic_vector(ADDRESS_WIDTH-1 downto 0);
		offset_max			: in 	std_logic_vector(OFFSET_WIDTH-1 downto 0);
		sram_fifo_packet 	: out 	std_logic_vector(PACKET_WIDTH-1 downto 0)
	);
end pixel_test;

architecture BHV of pixel_test is

	type STATE_TYPE is (INIT, LEFT_OFFSET, RIGHT_OFFSET, LEFT_UP_OFFSET, LEFT_DOWN_OFFSET, RIGHT_UP_OFFSET, RIGHT_DOWN_OFFSET, DONE);
	
	signal state, next_state 						 	: STATE_TYPE;
	signal mult_temp, mult_temp_n						: unsigned(2*ADDRESS_WIDTH-1 downto 0);
	signal h_off, h_off_n 								: unsigned(ADDRESS_WIDTH-1 downto 0);
	signal v_off, v_off_n								: unsigned(ADDRESS_WIDTH-1 downto 0);
	signal sram_fifo_packet_n, packet_buff 		 		: std_logic_vector(PACKET_WIDTH-1 downto 0);
	signal packet_flag, packet_flag_temp 			 	: std_logic;

begin

	process (clk, rst)
	begin
		if (rst = '1') then
			h_off <= (others => '0');
			v_off <= (others => '0');
			sram_fifo_packet <= (others => '0');
			packet_buff <= (others => '0');
			packet_flag <= '0';
			mult_temp <= (others => '0');
			state <= INIT;
		elsif (rising_edge(clk)) then
			h_off <= h_off_n;
			v_off <= v_off_n;
			sram_fifo_packet <= sram_fifo_packet_n;
			packet_buff <= sram_fifo_packet_n;
			packet_flag <= packet_flag_temp;
			mult_temp <= mult_temp_n;
			state <= next_state;
		end if;
	end process;

	process (state, address, h_off, v_off, packet_buff)
	begin
		h_off_n <= h_off;
		v_off_n <= v_off;

		sram_fifo_packet_n <= packet_buff;
		packet_flag_temp <= '0';

		mult_temp_n <= mult_temp;

		next_state <= state;
		
		case state is
			when INIT =>
				h_off_n <= to_unsigned(0, ADDRESS_WIDTH);
				v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
				next_state <= LEFT_OFFSET;

			when LEFT_OFFSET =>
				--if (h_off /= to_unsigned(0, ADDRESS_WIDTH)) then
					if (h_off /= unsigned(offset_max) + 1) then
						-- write packet
						sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) - unsigned(offset_max) + h_off);
						sram_fifo_packet_n(15 downto 8) <= "11111111";
						sram_fifo_packet_n(7 downto 0) <= "00000000";
						packet_flag_temp <= '1';
						v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
						mult_temp_n <= v_off * 800;
						next_state <= LEFT_UP_OFFSET;
					else
						h_off_n <= to_unsigned(0, ADDRESS_WIDTH);
						v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
						next_state <= RIGHT_OFFSET;
					end if;
				--else
				--	-- write packet
				--	sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) - unsigned(offset_max) + h_off);
				--	sram_fifo_packet_n(15 downto 8) <= "11111111";
				--	sram_fifo_packet_n(7 downto 0) <= "00000000";
				--	packet_flag_temp <= '1';
				--	h_off_n <= h_off + 1;
				--end if;

			when LEFT_UP_OFFSET =>
				-- write packet
				sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) - mult_temp(ADDRESS_WIDTH-1 downto 0) -  unsigned(offset_max) + h_off);
				sram_fifo_packet_n(15 downto 8) <= "11111111";
				sram_fifo_packet_n(7 downto 0) <= "00000000";
				packet_flag_temp <= '1';

				if (v_off /= resize(unsigned(offset_max), 2*ADDRESS_WIDTH)) then
					v_off_n <= v_off + 1;
					mult_temp_n <= (v_off + 1) * 800;
				else
					v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
					mult_temp_n <= to_unsigned(800, 2*ADDRESS_WIDTH);
					next_state <= LEFT_DOWN_OFFSET;
				end if;

			when LEFT_DOWN_OFFSET =>
				-- write packet
				sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) + mult_temp(ADDRESS_WIDTH-1 downto 0) - unsigned(offset_max) + h_off);
				sram_fifo_packet_n(15 downto 8) <= "11111111";
				sram_fifo_packet_n(7 downto 0) <= "00000000";
				packet_flag_temp <= '1';

				if (v_off /= resize(unsigned(offset_max), 2*ADDRESS_WIDTH)) then
					v_off_n <= v_off + 1;
					mult_temp_n <= (v_off + 1) * 800;
				else
					v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
					mult_temp_n <= to_unsigned(800, 2*ADDRESS_WIDTH);
					h_off_n <= h_off + 1;
					next_state <= LEFT_OFFSET;
				end if;

			when RIGHT_OFFSET =>
				-- write packet
				--sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) + unsigned(offset_max) - h_off);
				--sram_fifo_packet_n(15 downto 8) <= "11111111";
				--sram_fifo_packet_n(7 downto 0) <= "00000000";
				--packet_flag_temp <= '1';

				--if (h_off /= to_unsigned(0, ADDRESS_WIDTH)) then
					if (h_off /= unsigned(offset_max)) then
						-- write packet
						sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) + unsigned(offset_max) - h_off);
						sram_fifo_packet_n(15 downto 8) <= "11111111";
						sram_fifo_packet_n(7 downto 0) <= "00000000";
						packet_flag_temp <= '1';
						mult_temp_n <= v_off * 800;
						v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
						next_state <= RIGHT_UP_OFFSET;
					else
						h_off_n <= to_unsigned(0, ADDRESS_WIDTH);
						v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
						next_state <= DONE;
					end if;
				--else
				--	-- write packet
				--	sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) + unsigned(offset_max) - h_off);
				--	sram_fifo_packet_n(15 downto 8) <= "11111111";
				--	sram_fifo_packet_n(7 downto 0) <= "00000000";
				--	packet_flag_temp <= '1';
				--	h_off_n <= h_off + 1;
				--end if;

			when RIGHT_UP_OFFSET =>
				-- write packet
				sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) - mult_temp(ADDRESS_WIDTH-1 downto 0) + unsigned(offset_max) - h_off);
				sram_fifo_packet_n(15 downto 8) <= "11111111";
				sram_fifo_packet_n(7 downto 0) <= "00000000";
				packet_flag_temp <= '1';

				if (v_off /= resize(unsigned(offset_max), 2*ADDRESS_WIDTH)) then
					v_off_n <= v_off + 1;
					mult_temp_n <= (v_off + 1) * 800;
				else
					v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
					mult_temp_n <= to_unsigned(800, 2*ADDRESS_WIDTH);
					next_state <= RIGHT_DOWN_OFFSET;
				end if;

			when RIGHT_DOWN_OFFSET =>
				-- write packet
				sram_fifo_packet_n(35 downto 16) <= std_logic_vector(unsigned(address) + mult_temp(ADDRESS_WIDTH-1 downto 0) + unsigned(offset_max) - h_off);
				sram_fifo_packet_n(15 downto 8) <= "11111111";
				sram_fifo_packet_n(7 downto 0) <= "00000000";
				packet_flag_temp <= '1';

				if (v_off /= resize(unsigned(offset_max), 2*ADDRESS_WIDTH)) then
					v_off_n <= v_off + 1;
					mult_temp_n <= (v_off + 1) * 800;
				else
					v_off_n <= to_unsigned(1, ADDRESS_WIDTH);
					mult_temp_n <= to_unsigned(800, 2*ADDRESS_WIDTH);
					h_off_n <= h_off + 1;
					next_state <= RIGHT_OFFSET;
				end if;

			when DONE =>
				next_state <= DONE;

			when others => null;
		end case;

	end process;

end architecture ; -- BHV