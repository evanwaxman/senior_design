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
		read_done 		: out 	std_logic
	);
end spi_slave;

architecture BHV of spi_slave is

	type STATE_TYPE is (IDLE, COMM, END_COMM, ACK_MASTER, WAIT_FOR_SS_HIGH);

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

begin

	process(clk, rst)
	begin
		if (rst = '1') then
			miso <= '0';
			receive_byte <= (others => '0');
			shift_reg <= (others => '0');
			cntr_reg <= to_unsigned(0, 4);
			state <= IDLE;
		elsif (clk'event and clk = '1') then
			miso <= ack;
			receive_byte <= receive_buff;
			shift_reg <= receive_buff;
			cntr_reg <= cntr_temp;
			sck_low_flag_reg <= sck_low_flag_temp;
			state <= next_state;
		end if;
	end process;

	process(state, ss, cntr_reg)
	begin
		next_state <= state;
		ack <= '0';
		cntr_en <= '0';
		read_done <= '0';

		case state is
			when IDLE =>
				ack <= '1';

				if (ss = '0') then
					ack <= '0';
					next_state <= COMM;
				end if;
			when COMM =>
				if (cntr_reg = 8) then
					cntr_en <= '0';
					next_state <= ACK_MASTER;
				else
					cntr_en <= '1';
				end if;
			when ACK_MASTER =>
				read_done <= '1';
				ack <= '1';
				next_state <= WAIT_FOR_SS_HIGH;
			when WAIT_FOR_SS_HIGH =>
				ack <= '1';
				if (ss = '1') then
					next_state <= IDLE;
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