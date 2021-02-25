`default_nettype none


module thruwire_top(
	input	BTN_N,
	output	LEDG_N
);

thruwire thruwire_instance(
	.i_sw(BTN_N),
	.o_led(LEDG_N)
);


endmodule
