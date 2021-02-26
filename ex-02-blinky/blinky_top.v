`default_nettype none


module blinky_top(
	input	CLK,
	output	LEDG_N
);

blinky blinky_instance(
	.i_clk(CLK),
	.o_led(LEDG_N)
);


endmodule
