`default_nettype none


module reqwalker_top(
	input	CLK,
	input	BTN_N,
	output	LEDG_N,
	output 	LEDR_N, 
	output 	LED5, 
	output 	LED4, 
	output 	LED3, 
	output 	LED2, 
	output 	LED1
	
);

wire [6:0] leds;

assign {LEDG_N, LEDR_N, LED5, LED4, LED3, LED2, LED1} = {~leds[6], ~leds[5], leds[4:0]};

reqwalker reqwalker_instance(
	.i_clk(CLK),

	// Our wishbone bus interface
	.i_cyc(),
	.i_stb(stb),
	.i_we(stb),

	.i_addr(),
	.i_data(),
	//
	.o_stall(busy),
	.o_ack(),
	.o_data(),
	//
	// The output LED
	.o_led(leds[5:0])

);

reg stb; 
initial stb= 0;
wire busy;



always @(posedge CLK) 
	if (~BTN_N)
		stb<= 1'b1; 
	else if (!busy)
		stb<= 1'b0;

endmodule
