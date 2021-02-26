`default_nettype none


module ppsi_top(
	input	CLK,
	output	LEDG_N
);

ppsi ppsi_instance(
	.i_clk(CLK),
	.o_led(LEDG_N)
);


endmodule
