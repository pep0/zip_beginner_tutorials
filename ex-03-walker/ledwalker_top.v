`default_nettype none


module ledwalker_top(
	input	CLK,
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

ledwalker ledwalker_instance(
	.i_clk(CLK),
	.o_led(leds)
);


endmodule
