`default_nettype none


module dimmer_top(
	input	CLK,
	output	LEDG_N
);

dimmer dimmer_instance(
	.i_clk(CLK),
	.o_led(LEDG_N)
);


endmodule
