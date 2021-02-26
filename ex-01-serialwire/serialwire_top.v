`default_nettype none


module serialwire_top(
	input	RX,
	output	TX	
);

serialwire serialwire_instance(
	.i_rx(RX),
	.o_tx(TX)
);


endmodule
