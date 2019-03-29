library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
	port (
        clk                 : in        std_logic;
        rst                 : in        std_logic;
        led0    			: out 		std_logic_vector(6 downto 0);
		led1    			: out 		std_logic_vector(6 downto 0);
		led2    			: out 		std_logic_vector(6 downto 0);
		led3    			: out 		std_logic_vector(6 downto 0);
		addr_over 			: out 		std_logic;
        sram_re 			: in 		std_logic;
        sram_addr           : out       std_logic_vector(19 downto 0);
        sram_data           : inout     std_logic_vector(15 downto 0);
        sram_ce             : out       std_logic;
        sram_oe             : out       std_logic;
        sram_we             : out       std_logic;
        sram_bhe            : out       std_logic;
        sram_ble            : out       std_logic
	);
end top_level;

architecture BHV of top_level is

	type STATE_TYPE is (INIT, WRITE_SRAM, READ_SRAM, WAIT_FOR_NEW_READ, DONE);
	signal state, next_state : STATE_TYPE;

	signal sram_addr_n 	: std_logic_vector(19 downto 0);
	signal sram_data_n 	: std_logic_vector(15 downto 0);
	signal sram_ce_n 	: std_logic;
	signal sram_oe_n 	: std_logic;
	signal sram_we_n 	: std_logic;
	signal sram_bhe_n 		: std_logic;
	signal sram_ble_n 		: std_logic;

	signal data_count 		: std_logic_vector(3 downto 0);
	signal data_count_n		: std_logic_vector(3 downto 0);

	signal curr_addr 		: std_logic_vector(19 downto 0);
	signal curr_addr_n 		: std_logic_vector(19 downto 0);
	--signal curr_data		: std_logic_vector(15 downto 0);
	--signal curr_data_n 		: std_logic_vector(15 downto 0);

	signal sram_read_data	: std_logic_vector(7 downto 0);
	signal state_count 		: std_logic_vector(3 downto 0);

begin

	U_SRAM_DATA0_7SEG : entity work.decoder7seg
		port map(
			input 	=> sram_read_data(3 downto 0),
			output 	=> led0
		);

	U_SRAM_DATA1_7SEG : entity work.decoder7seg
	port map(
		input 	=> sram_read_data(7 downto 4),
		output 	=> led1
	);

	U_STATE_7SEG : entity work.decoder7seg
	port map(
		input 	=> state_count,
		output 	=> led2
	);

	U_SRAM_ADDR_7SEG : entity work.decoder7seg
	port map(
		input 	=> curr_addr(3 downto 0),
		output 	=> led3
	);

	process(clk, rst)
	begin
		if (rst = '1') then
			sram_addr <= (others => '0');
			sram_data <= (others => 'Z');
			sram_ce <= '1';
			sram_oe <= '1';
			sram_we <= '1';
			sram_bhe <= '0';
			sram_ble <= '0';

			data_count <= (others => '0');
			curr_addr <= (others => '0');
			--curr_data <= (others => '0');
			state <= INIT;
		elsif (clk'event and clk = '1') then
			sram_addr <= sram_addr_n;
			sram_data <= sram_data_n;
			sram_ce <= sram_ce_n;
			sram_oe <= sram_oe_n;
			sram_we <= sram_we_n;
			sram_bhe <= sram_bhe_n;
			sram_ble <= sram_ble_n;

			data_count <= data_count_n;
			curr_addr <= curr_addr_n;
			--curr_data <= curr_data_n;
			state <= next_state;
		end if;
	end process;

	process(state, sram_data, sram_re, data_count, curr_addr)
	begin
		next_state <= state;

		sram_addr_n <= curr_addr;
		sram_data_n <= (others => 'Z');
		sram_ce_n <= '0';
		sram_oe_n <= '1';
		sram_we_n <= '1';
		sram_bhe_n <= '0';
		sram_ble_n <= '0';

		data_count_n <= data_count;
		curr_addr_n <= curr_addr;
		--curr_data_n <= curr_data;

		sram_read_data <= (others => '0');


		if (unsigned(curr_addr) > 8) then
			addr_over <= '0';
		else
			addr_over <= '1';
		end if;



		case (state) is
			when INIT =>
				-- disable sram
				sram_ce_n <= '1';
				sram_oe_n <= '1';
				sram_we_n <= '1';

				next_state <= WRITE_SRAM;

				state_count <= "0000";

			when WRITE_SRAM =>
				if (unsigned(data_count) < 4) then
					-- write enable
					sram_ce_n <= '0';
					sram_oe_n <= '1';
					sram_we_n <= '0';
					sram_addr_n <= curr_addr;
					sram_data_n <= (others => '1');

					curr_addr_n <= std_logic_vector(unsigned(curr_addr) + 1);
					--curr_data_n <= std_logic_vector(unsigned(curr_data) + 1);
					data_count_n <= std_logic_vector(unsigned(data_count) + 1);
				elsif (unsigned(data_count) >= 4 and unsigned(data_count) < 8) then
					-- write enable
					sram_ce_n <= '0';
					sram_oe_n <= '1';
					sram_we_n <= '0';
					sram_addr_n <= curr_addr;
					sram_data_n <= "0000000001011010";

					curr_addr_n <= std_logic_vector(unsigned(curr_addr) + 1);
					--curr_data_n <= std_logic_vector(unsigned(curr_data) + 1);
					data_count_n <= std_logic_vector(unsigned(data_count) + 1);
				else
					curr_addr_n <= (others => '0');
					--curr_data_n <= (others => '0');
					data_count_n <= (others => '0');
					next_state <= READ_SRAM;
				end if;

				state_count <= "0001";

			when READ_SRAM =>
				sram_read_data <= sram_data(7 downto 0);

				if (unsigned(data_count) < 12) then
					if (sram_re = '1') then
						-- read enable
						sram_ce_n <= '0';
						sram_oe_n <= '0';
						sram_we_n <= '1';
						sram_addr_n <= curr_addr;
						sram_data_n <= (others => 'Z');

						curr_addr_n <= std_logic_vector(unsigned(curr_addr) + 1); 
						data_count_n <= std_logic_vector(unsigned(data_count) + 1);

						next_state <= WAIT_FOR_NEW_READ;
					end if;
				else
					curr_addr_n <= (others => '0');
					data_count_n <= (others => '0');
					--next_state <= DONE;
				end if;

				state_count <= "0010";

			when WAIT_FOR_NEW_READ =>
				sram_read_data <= sram_data(7 downto 0);

				-- read enable
				sram_ce_n <= '0';
				sram_oe_n <= '0';
				sram_we_n <= '1';
				sram_addr_n <= curr_addr;
				sram_data_n <= (others => 'Z');
				if (sram_re = '0') then
					next_state <= READ_SRAM;
				end if;
				state_count <= "0011";

			when DONE =>
				sram_read_data <= sram_data(7 downto 0);

				-- read enable
				sram_ce_n <= '0';
				sram_oe_n <= '0';
				sram_we_n <= '1';

				state_count <= "0100";


			when others => null;
		end case;
	end process;
end architecture BHV;
