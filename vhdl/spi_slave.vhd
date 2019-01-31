library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is
	port(
		clk 			: in 	std_logic;
		rst 			: in 	std_logic;
		sck 			: in 	std_logic;
		ss 				: in 	std_logic;
		mosi 			: in 	std_logic;
		miso 			: out 	std_logic;
		receive_byte	: out 	std_logic_vector(7 downto 0);
		byte_type 		: out 	std_logic;		-- '0' for data, '1' for data_type
		read_done 		: out 	std_logic;
		reset_state 	: out 	std_logic
	);
end spi_slave;

architecture BHV of spi_slave is

	type STATE_TYPE is (WAIT_FOR_DATA_TYPE, WAIT_FOR_DATA, GET_DATA_TYPE, GET_DATA, CHECK_DATA_TYPE, READ_DONE_DATA_TYPE, READ_DONE_DATA, ACK_DATA_TYPE, ACK_DATA, NACK);

	signal state, next_state 	: STATE_TYPE;
	signal ack 					: std_logic;
	signal shift_reg 			: std_logic_vector(7 downto 0);
	signal receive_buff 		: std_logic_vector(7 downto 0);
	signal cntr_en	 			: std_logic;
	signal cntr_reg 			: unsigned(3 downto 0);
	signal cntr_temp 			: unsigned(3 downto 0);
	signal mosi_temp 			: std_logic_vector(7 downto 0);
	signal sck_low_flag_temp	: std_logic := '1';
	signal sck_low_flag_reg		: std_logic := '1';

	signal data_type_reg 		: std_logic_vector(2 downto 0);
	signal data_type_buff 		: std_logic_vector(2 downto 0);

begin

	process(clk, rst)
	begin
		if (rst = '1') then
			miso <= '0';
			receive_byte <= (others => '0');
			shift_reg <= (others => '0');
			cntr_reg <= to_unsigned(0, 4);
			sck_low_flag_reg <= '0';
			state <= WAIT_FOR_DATA_TYPE;
		elsif (clk'event and clk = '1') then
			miso <= ack;
			receive_byte <= receive_buff;
			shift_reg <= receive_buff;
			cntr_reg <= cntr_temp;
			sck_low_flag_reg <= sck_low_flag_temp;
			--data_type_reg <= data_type_buff;
			state <= next_state;
		end if;
	end process;

	process(state, ss, cntr_reg, data_type_reg, shift_reg)
	begin
		next_state <= state;
		ack <= '0';
		cntr_en <= '0';
		read_done <= '0';
		--data_type_buff <= data_type_reg;
		byte_type <= '0';
		reset_state <= '0';

		case state is
			when WAIT_FOR_DATA_TYPE =>
				if (ss = '0') then
					ack <= '0';
					next_state <= GET_DATA_TYPE;
				end if;
			when WAIT_FOR_DATA =>
				if (ss = '0') then
					ack <= '0';
					next_state <= GET_DATA;
				end if;
			when GET_DATA_TYPE =>
				if (cntr_reg = 8) then
					cntr_en <= '0';
					next_state <= CHECK_DATA_TYPE;
				else
					cntr_en <= '1';
				end if;
			when GET_DATA =>
				if (cntr_reg = 8) then
					cntr_en <= '0';
					next_state <= READ_DONE_DATA;
				else
					cntr_en <= '1';
				end if;
			when CHECK_DATA_TYPE =>
				--case shift_reg is
				--	when "00000000" =>			-- address_0
				--		data_type_buff <= "000";
				--	when "00000001" =>			-- address_1
				--		data_type_buff <= "001";
				--	when "00000010" =>			-- address_2
				--		data_type_buff <= "010";
				--	when "00000100" =>			-- red
				--		data_type_buff <= "011";
				--	when "00001000" =>			-- green
				--		data_type_buff <= "100";
				--	when "00010000" =>			-- blue
				--		data_type_buff <= "101";
				--	when others =>
				--		next_state <= NACK;
				--end case;

				if (unsigned(shift_reg) > 5) then
					next_state <= NACK;
				else
					next_state <= READ_DONE_DATA_TYPE;
				end if;
			when READ_DONE_DATA_TYPE =>
				read_done <= '1';
				byte_type <= '1';
				next_state <= ACK_DATA_TYPE;
			when READ_DONE_DATA =>
				read_done <= '1';
				next_state <= ACK_DATA;
			when ACK_DATA_TYPE =>
				ack <= '1';
				if (ss = '1') then
					next_state <= WAIT_FOR_DATA;
				end if;
			when ACK_DATA =>
				ack <= '1';
				if (ss = '1') then
					next_state <= WAIT_FOR_DATA_TYPE;
				end if;
			when NACK =>
				reset_state <= '1';
				if (ss = '1') then
					next_state <= WAIT_FOR_DATA_TYPE;
				end if;
			when others => null;
		end case;
	end process;

	mosi_temp(7 downto 1) <= (others => '0');
	mosi_temp(0) <= mosi; 

	process(sck, cntr_en, sck_low_flag_reg, shift_reg, cntr_reg, mosi_temp)
	begin
		cntr_temp <= cntr_reg;
		receive_buff <= shift_reg;
		sck_low_flag_temp <= sck_low_flag_reg;

		if (cntr_en = '1') then
			if (sck = '1' and sck_low_flag_reg = '1') then
				receive_buff <= std_logic_vector(shift_left(unsigned(shift_reg), 1)) or mosi_temp;
				cntr_temp <= cntr_reg + 1;
				sck_low_flag_temp <= '0';
			elsif (sck = '0') then
				sck_low_flag_temp <= '1';
			end if;
		else 
			sck_low_flag_temp <= '1';
			cntr_temp <= to_unsigned(0, 4);
		end if;

	end process;
end architecture BHV;