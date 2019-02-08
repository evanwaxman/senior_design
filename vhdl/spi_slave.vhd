library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is
	port(
		clk 				: in 	std_logic;
		rst 				: in 	std_logic;
		sck 				: in 	std_logic;
		ss 					: in 	std_logic;
		mosi 				: in 	std_logic;
		miso 				: out 	std_logic;
		sram_fifo_packet	: out 	std_logic_vector(35 downto 0);
		packet_flag			: out 	std_logic;

		-- testing
		led0    			: out 	std_logic_vector(6 downto 0);
		led1    			: out 	std_logic_vector(6 downto 0);
		led2    			: out 	std_logic_vector(6 downto 0);
		received_byte 		: out 	std_logic_vector(7 downto 0)
	);
end spi_slave;

architecture BHV of spi_slave is

	type STATE_TYPE is (INIT, WAIT_FOR_DATA, GET_DATA, ACK_DATA);

	signal state, next_state 		: STATE_TYPE;
	signal shift_reg 				: std_logic_vector(7 downto 0);
	signal receive_buff 			: std_logic_vector(7 downto 0);
	signal cntr_reg 				: std_logic_vector(5 downto 0);
	signal cntr_temp 				: std_logic_vector(5 downto 0);
	signal mosi_temp 				: std_logic_vector(7 downto 0);
	signal sck_low_flag_temp		: std_logic;
	signal sck_low_flag_reg			: std_logic;
	signal sck_sync 				: std_logic;
	signal ss_sync 					: std_logic;
	signal mosi_sync 				: std_logic;
	signal ack 						: std_logic;
	signal state_code_reg			: std_logic_vector(3 downto 0);
	signal state_code_temp 			: std_logic_vector(3 downto 0);

	signal sram_fifo_packet_temp 	: std_logic_vector(35 downto 0);
	signal packet_buff		 		: std_logic_vector(35 downto 0);
	signal packet_flag_temp 		: std_logic;
	signal packet_sent 				: std_logic;
	signal packet_sent_temp			: std_logic;
	signal address_hold 			: std_logic_vector(19 downto 0);
	signal address_hold_temp 		: std_logic_vector(19 downto 0);
	signal counter_led2_hold 		: std_logic_vector(3 downto 0);

begin

	U_STATE_7SEG : entity work.decoder7seg
		port map(
			input 	=> state_code_reg,
			output 	=> led0
		);

	U_SCK_COUNT0_7SEG : entity work.decoder7seg
		port map(
			input 	=> cntr_reg(3 downto 0),
			output 	=> led1
		);

	counter_led2_hold <= "00" & cntr_reg(5 downto 4);

	U_SCK_COUNT1_7SEG : entity work.decoder7seg
		port map(
			input 	=> counter_led2_hold,
			output 	=> led2
		);

	U_SPI_SYNC : entity work.df_sync 
		port map(
			clk_dest 	=> clk,
			din 		=> sck,
			dout 		=> sck_sync
		);

	U_SS_SYNC : entity work.df_sync 
		port map(
			clk_dest 	=> clk,
			din 		=> ss,
			dout 		=> ss_sync
		);

	U_MOSI_SYNC : entity work.df_sync 
		port map(
			clk_dest 	=> clk,
			din 		=> mosi,
			dout 		=> mosi_sync
		);

	process(clk, rst)
	begin
		if (rst = '1') then
			shift_reg <= (others => '0');
			cntr_reg <= (others => '0');
			sck_low_flag_reg <= '0';
			miso <= '0';
			sram_fifo_packet <= (others => '0');
			packet_buff <= (others => '0');
			packet_flag <= '0';
			packet_sent <= '0';
			address_hold <= (others => '0');
			state <= INIT;
			state_code_reg <= "0000";
		elsif (clk'event and clk = '1') then
			shift_reg <= receive_buff;
			cntr_reg <= cntr_temp;
			sck_low_flag_reg <= sck_low_flag_temp;
			miso <= ack;
			sram_fifo_packet <= sram_fifo_packet_temp;
			packet_buff <= sram_fifo_packet_temp;
			packet_flag <= packet_flag_temp;
			packet_sent <= packet_sent_temp;
			address_hold <= address_hold_temp;
			state <= next_state;
			state_code_reg <= state_code_temp;
		end if;
	end process;

	received_byte <= shift_reg;
	mosi_temp(7 downto 1) <= (others => '0');
	mosi_temp(0) <= mosi_sync; 

	process(state, ss_sync, cntr_reg, shift_reg, sck_sync, sck_low_flag_reg, mosi_temp, state_code_reg, packet_buff, address_hold, packet_sent)
	begin
		next_state <= state;
		ack <= '0';
		state_code_temp <= state_code_reg;
		cntr_temp <= cntr_reg;
		receive_buff <= shift_reg;
		sck_low_flag_temp <= sck_low_flag_reg;
		sram_fifo_packet_temp <= packet_buff;
		packet_flag_temp <= '0';
		packet_sent_temp <= packet_sent;
		address_hold_temp <= address_hold;

		case state is
			when INIT =>
				state_code_temp <= "0000";
				if (ss_sync = '1') then
					next_state <= WAIT_FOR_DATA;
				end if;
			when WAIT_FOR_DATA =>
				state_code_temp <= "0001";
				cntr_temp <= (others => '0');
				if (ss_sync = '0') then
					next_state <= GET_DATA;
				end if;
			when GET_DATA =>
				state_code_temp <= "0010";
				if (sck_sync = '0') then
					sck_low_flag_temp <= '1';
				elsif (sck_sync = '1' and sck_low_flag_reg = '1') then
					receive_buff <= std_logic_vector(shift_left(unsigned(shift_reg), 1)) or mosi_temp;
					cntr_temp <= std_logic_vector(unsigned(cntr_reg) + 1);
					sck_low_flag_temp <= '0';
				end if;

				--if (unsigned(cntr_reg) = 8) then
				--	next_state <= ACK_DATA;
				--end if;

				case unsigned(cntr_reg) is
					when to_unsigned(8, 6) =>	-- ADDR_HIGH
						address_hold_temp(19 downto 16) <= shift_reg(3 downto 0);
						sram_fifo_packet_temp(35 downto 32) <= shift_reg(3 downto 0);
					when to_unsigned(16, 6) =>	-- ADDR_MID
						address_hold_temp(15 downto 8) <= shift_reg;
						sram_fifo_packet_temp(31 downto 24) <= shift_reg;
					when to_unsigned(24, 6) => 	-- ADDR_LOW
						address_hold_temp(7 downto 0) <= shift_reg;
						sram_fifo_packet_temp(23 downto 16) <= shift_reg;
					when to_unsigned(32, 6) =>	-- RED
						sram_fifo_packet_temp(15 downto 8) <= shift_reg;
					when to_unsigned(40, 6) =>	-- GREEN
						sram_fifo_packet_temp(7 downto 0) <= shift_reg;
						if (packet_sent = '0') then
							packet_flag_temp <= '1';
							packet_sent_temp <= '1';
						end if;
					when to_unsigned(48, 6) =>	-- BLUE
						sram_fifo_packet_temp(35 downto 16) <= std_logic_vector(unsigned(address_hold) + 1);
						sram_fifo_packet_temp(15 downto 8) <= shift_reg;
						sram_fifo_packet_temp(7 downto 0) <= "00000000";
						packet_flag_temp <= '1';
						next_state <= ACK_DATA;
					when others => null;
				end case;
			when ACK_DATA =>
				state_code_temp <= "0011";
				ack <= '1';
				packet_sent_temp <= '0';
				if (ss_sync = '1') then
					next_state <= WAIT_FOR_DATA;
				end if;
			when others => null;
		end case;
	end process;

end architecture BHV;