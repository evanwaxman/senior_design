library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_packet_maker is
	port (
		clk 			: in 	std_logic;
		rst 			: in 	std_logic;
		read_done 		: in 	std_logic;
		receive_byte 	: in 	std_logic_vector(7 downto 0);
		byte_type 		: in 	std_logic;
		reset_state 	: in 	std_logic;
		packet 	 		: out 	std_logic_vector(35 downto 0);
		write_fifo_we 	: out 	std_logic;
		data_out_order 	: out 	std_logic
	);
end spi_packet_maker;

architecture BHV of spi_packet_maker is

	type STATE_TYPE is (WAIT_FOR_DATA_TYPE, ADDR_0, ADDR_1, ADDR_2, RED, GREEN, BLUE, WRITE_PACKET_0, WRITE_PACKET_1);

	signal state, next_state 	 		: STATE_TYPE;
	signal address_reg, address_buff 	: std_logic_vector(19 downto 0);
	signal red_reg, red_buff 			: std_logic_vector(7 downto 0);
	signal green_reg, green_buff 		: std_logic_vector(7 downto 0);
	signal blue_reg, blue_buff 			: std_logic_vector(7 downto 0);
	signal write_fifo_we_temp 			: std_logic;
	signal data_out_order_temp 			: std_logic;
	signal packet_buff 					: std_logic_vector(35 downto 0);

begin

	process(clk, rst)
	begin
		if (rst = '1') then
			address_reg <= (others => '0');
			red_reg <= (others => '0');
			green_reg <= (others => '0');
			blue_reg <= (others => '0');
			write_fifo_we <= '0';
			data_out_order <= '0';
			packet <= (others => '0');
			state <= WAIT_FOR_DATA_TYPE;
		elsif (clk'event and clk = '1') then
			address_reg <= address_buff;
			red_reg	<= red_buff;
			green_reg <= green_buff;
			blue_reg <= blue_buff;
			write_fifo_we <= write_fifo_we_temp;
			data_out_order <= data_out_order_temp;
			packet <= packet_buff;
			if (reset_state = '1') then
				state <= WAIT_FOR_DATA_TYPE;
			else
				state <= next_state;
			end if;
		end if;
	end process;

	process(state, read_done, receive_byte, byte_type, address_reg, red_reg, green_reg, blue_reg)
	begin
		next_state <= state;
		address_buff <= address_reg;
		red_buff <= red_reg;
		green_buff <= green_reg;
		blue_buff <= blue_reg;
		data_out_order_temp <= '0';
		write_fifo_we_temp <= '0';
		packet_buff <= (others => '0');

		case state is
			when WAIT_FOR_DATA_TYPE =>
				if (read_done = '1') then
					if (byte_type = '1') then
						case receive_byte is
							when "00000000" =>
								next_state <= ADDR_0;
							when "00000001" =>
								next_state <= ADDR_1;
							when "00000010" =>
								next_state <= ADDR_2;
							when "00000011" =>
								next_state <= RED;
							when "00000100" =>
								next_state <= GREEN;
							when "00000101" =>
								next_state <= BLUE;
							when others =>
								data_out_order_temp <= '1';
						end case;
					else
						data_out_order_temp <= '1';
					end if;
				end if;

			when ADDR_0 =>
				if (read_done = '1') then
					if (byte_type = '0') then
						address_buff(19 downto 12) <= receive_byte;
					else
						data_out_order_temp <= '1';
					end if;
					next_state <= WAIT_FOR_DATA_TYPE;
				end if;
			when ADDR_1 =>
				if (read_done = '1') then
					if (byte_type = '0') then
						address_buff(11 downto 4) <= receive_byte;
					else
						data_out_order_temp <= '1';
					end if;					
					next_state <= WAIT_FOR_DATA_TYPE;
				end if;
			when ADDR_2 =>
				if (read_done = '1') then
					if (byte_type = '0') then
						address_buff(3 downto 0) <= receive_byte(3 downto 0);
					else
						data_out_order_temp <= '1';
					end if;					
					next_state <= WAIT_FOR_DATA_TYPE;
				end if;
			when RED =>
				if (read_done = '1') then
					if (byte_type = '0') then
						red_buff <= receive_byte;
					else
						data_out_order_temp <= '1';
					end if;					
					next_state <= WAIT_FOR_DATA_TYPE;
				end if;
			when GREEN => 
				if (read_done = '1') then
					if (byte_type = '0') then
						green_buff <= receive_byte;
						next_state <= WRITE_PACKET_0;
					else
						data_out_order_temp <= '1';
						next_state <= WAIT_FOR_DATA_TYPE;
					end if;					
				end if;
			when BLUE => 
				if (read_done = '1') then
					if (byte_type = '0') then
						blue_buff <= receive_byte;
						next_state <= WRITE_PACKET_1;
					else
						data_out_order_temp <= '1';
						next_state <= WAIT_FOR_DATA_TYPE;
					end if;					
				end if;
			when WRITE_PACKET_0 =>
				write_fifo_we_temp <= '1';
				packet_buff <= address_reg & red_reg & green_reg;
				next_state <= WAIT_FOR_DATA_TYPE;
			when WRITE_PACKET_1 =>
				write_fifo_we_temp <= '1';
				packet_buff <= address_reg & blue_reg & "00000000";
				next_state <= WAIT_FOR_DATA_TYPE;
			when others => null;
		end case;
	end process;
end architecture BHV;