`default_nettype none

module serialwire(i_rx, o_tx);
	input	wire	i_rx;
	output	wire	o_tx;

	assign	o_tx = i_rx;
endmodule
