////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	thruwire.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	An exceptionally simple Verilog file, just connecting one
//		input port (i_sw) to one output port (o_led)
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Written and distributed by Gisselquist Technology, LLC
//
// This program is hereby granted to the public domain.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype none
//
module thruwire(BTN_N, LEDG_N);
	input	wire	BTN_N;
	output	wire	LEDG_N;

	assign	LEDG_N = BTN_N;
endmodule
