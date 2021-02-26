`default_nettype none


module ppsii_top(
	input	CLK,
	output	LEDG_N
);

ppsii ppsii_instance(
	.i_clk(CLK),
	.o_led(LEDG_N)
);


endmodule
