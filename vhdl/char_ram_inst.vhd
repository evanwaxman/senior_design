char_ram_inst : char_ram PORT MAP (
		aclr	 => aclr_sig,
		address	 => address_sig,
		clock	 => clock_sig,
		data	 => data_sig,
		wren	 => wren_sig,
		q	 => q_sig
	);
