////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	thedesign.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	This is the top-level design file for the txdata lesson, #6
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
module thedesign(

`ifdef	VERILATOR
		i_clk,
		i_event,
		o_setup,
		o_uart_tx);
`else 
	input wire CLK, 
	input wire BTN_N,
	output wire TX);
	
	wire i_clk, i_btn, o_uart_tx;
	assign i_clk = CLK;
	assign i_btn = ~BTN_N;
	assign TX = o_uart_tx;

`endif
	//
	parameter	CLOCK_RATE_HZ = 12_000_000;
	parameter	BAUD_RATE = 9_600;
	//

	parameter	UART_SETUP = (CLOCK_RATE_HZ / BAUD_RATE);
`ifdef	VERILATOR
	input	wire	i_clk, i_event;
	output	wire	o_uart_tx;
	output	wire	[31:0]	o_setup;
	assign	o_setup = UART_SETUP;
`else
	reg i_event;
	reg last_btn;
	initial i_event = 0;
	initial last_btn = 0;
	always @(posedge i_clk)begin
		last_btn <= i_btn;
		if(i_btn && !last_btn)
			i_event <= 1'b1;
		else
			i_event <= 1'b0;
	end
`endif

	wire	[31:0]	counterv, tx_data;
	wire		tx_busy, tx_stb;
	
	counter thecounter(i_clk, 1'b0, i_event, counterv);

	chgdetector findchanges(i_clk, counterv, tx_stb, tx_data, tx_busy);

	txdata #(UART_SETUP)
		serialword(i_clk, 1'b0, tx_stb, tx_data, tx_busy, o_uart_tx);
endmodule
