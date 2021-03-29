////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	txdata.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	To transmit a given number, in 0x%08x format, out the serial
//		port.
//
// Be aware: I have left bugs left within this design, and kept the formal
// verification from being complete.  The purpose of this file is not to give
// you the solution, but to give you enough of it that you don't need to spend
// all your time writing.
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
`default_nettype	none
//
module	txdata(i_clk, i_reset, i_stb, i_data, o_busy, o_uart_tx);
	parameter	UART_SETUP = 868;
	input	wire		i_clk, i_reset;
	input	wire		i_stb;
	input	wire	[31:0]	i_data;
	output	wire		o_busy;
	output	wire		o_uart_tx;

	reg	[31:0]	sreg;
	reg	[7:0]	hex, tx_data;
	reg	[3:0]	state;
	reg		tx_stb;
	wire		tx_busy;

	initial	tx_stb = 1'b0;
	initial	state  = 0;
	initial tx_data = "0";
	initial hex = "0";

	always @(posedge i_clk)
	if (i_reset)
	begin
		state      <= 0;
		tx_stb     <= 1'b0;
	end else if (!o_busy)
	begin
		// state <= 0;
		if (i_stb)
		begin
			state <= 1;
			tx_stb <= 1;
		end
	end else if ((tx_stb)&&(!tx_busy)) begin

		if (state >= 4'hc)
		begin
			tx_stb <= 1'b0;
			state <= 0;
		end
		else
			state <= state + 1;
	end

	assign o_busy = !(state == 0) || tx_busy;

	initial	sreg = 0;
	always @(posedge i_clk)
	if (i_reset)
		sreg <= 0;
	else if (!o_busy) // && (i_stb)
		sreg <= i_data;
	else if ((!tx_busy)&&(state > 4'h1))
		sreg <= { sreg[27:0], 4'h0 };

	always @(posedge i_clk)
	if (i_reset)
		hex <= "0";
	else begin
	case(sreg[31:28])
	4'h0: hex <= "0";
	4'h1: hex <= "1";
	4'h2: hex <= "2";
	4'h3: hex <= "3";
	4'h4: hex <= "4";
	4'h5: hex <= "5";
	4'h6: hex <= "6";
	4'h7: hex <= "7";
	4'h8: hex <= "8";
	4'h9: hex <= "9";
	4'ha: hex <= "a";
	4'hb: hex <= "b";
	4'hc: hex <= "c";
	4'hd: hex <= "d";
	4'he: hex <= "e";
	4'hf: hex <= "f";
	default: begin end
	endcase
	end

	always @(posedge i_clk)
	if (i_reset)
		tx_data <= "0";
	else if (!tx_busy)
		case(state)
		4'h0: tx_data <= "0";
		4'h1: tx_data <= "x";
		4'h2: tx_data <= hex;
		4'h3: tx_data <= hex;
		4'h4: tx_data <= hex;
		4'h5: tx_data <= hex;
		4'h6: tx_data <= hex;
		4'h7: tx_data <= hex;
		4'h8: tx_data <= hex;
		4'h9: tx_data <= hex;
		4'ha: tx_data <= "\r";
		4'hb: tx_data <= "\n";
		4'hc: tx_data <= "0";
		default: tx_data <= "Q";
		endcase

`ifndef	FORMAL
	txuart	#(UART_SETUP[23:0])
		txuarti(i_clk, tx_stb, tx_data, o_uart_tx, tx_busy);
`else
	(* anyseq *) wire serial_busy, serial_out;
	assign	o_uart_tx = serial_out;
	assign	tx_busy = serial_busy;
`endif

`ifdef	FORMAL
	initial	assume(i_reset);

	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid = 1'b1;

	//
	// Make some assumptions about tx_busy
	//
	// it needs to become busy upon a request given to it
	// but not before.  Upon a request, it needs to stay
	// busy for a minimum period of time
	initial	assume(!tx_busy);
	always @(posedge i_clk)
	if ($past(i_reset))
		assume(!tx_busy);
	else if (($past(tx_stb))&&(!$past(tx_busy)))
		assume(tx_busy);
	else if (!$past(tx_busy))
		assume(!tx_busy);

	reg	[1:0]	f_minbusy;
	initial	f_minbusy = 0;
	always @(posedge i_clk)
	if ((tx_stb)&&(!tx_busy))
		f_minbusy <= 2'b01;
	else if (f_minbusy != 2'b00)
		f_minbusy <= f_minbusy + 1'b1;

	always @(*)
	if (f_minbusy != 0)
		assume(tx_busy);


	reg [2:0] f_maxbusy;
	initial f_maxbusy = 0;
	always @(posedge i_clk)
	if ((tx_stb)&&(!tx_busy))
		f_maxbusy <= 3'b001;
	else if (f_maxbusy != 3'b000)
		f_maxbusy <= f_maxbusy + 1'b1;


	always @(*)
	if (f_maxbusy == 0)
		assume(!tx_busy);

	always @(posedge i_clk)
	if(tx_busy)
		assert(o_busy);


	//
	// Some cover statements
	//
	// You should be able to "see" your design working from these
	// If not ... modify them until you can.
	//
	//always @(posedge i_clk)
	//if (f_past_valid)
	//	cover($fell(o_busy));

	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_reset)))
		cover($fell(o_busy));




	reg f_seen_data;
	initial f_seen_data = 0;
	always @(posedge i_clk)
	if (i_reset)
		f_seen_data <= 1'b0;
	else if ((i_stb)&&(!o_busy)&&(i_data == 32'h12345678))
		f_seen_data <= 1'b1;

	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_reset)))
		cover(f_seen_data && $fell(o_busy));


	always @(posedge i_clk)
	if ((f_past_valid) && (!$past(i_reset)) && (!$past(o_busy)) && (!$past(i_stb)))
		assert($past(i_data)==sreg);

	always @(posedge i_clk)
	if ((f_past_valid) && (!$past(i_reset)))
		assert(tx_stb != (state == 0));


	always @(*)
		assert(state < 4'hd);
	//
	// Some assertions about our sequence of states
	//
	//
	
	function automatic [7:0]to_ascii;
		input [3:0] c;
	begin
	case(c)
	4'h0: to_ascii = "0";
	4'h1: to_ascii = "1";
	4'h2: to_ascii = "2";
	4'h3: to_ascii = "3";
	4'h4: to_ascii = "4";
	4'h5: to_ascii = "5";
	4'h6: to_ascii = "6";
	4'h7: to_ascii = "7";
	4'h8: to_ascii = "8";
	4'h9: to_ascii = "9";
	4'ha: to_ascii = "a";
	4'hb: to_ascii = "b";
	4'hc: to_ascii = "c";
	4'hd: to_ascii = "d";
	4'he: to_ascii = "e";
	4'hf: to_ascii = "f";
	default: begin end
	endcase
	end
	endfunction

	reg [31:0] fv_data;
	initial fv_data = 0;
	reg	[15:0]	p1reg;
	initial	p1reg = 0;
	always @(posedge i_clk)
	if (i_reset)
	begin
		p1reg <= 0;
		fv_data <= 0;
	end
	else if ((i_stb)&&(!o_busy)&&(!$past(i_reset)))
	begin
		p1reg <= 1;
		fv_data <= i_data;
		assert(p1reg[15:0] == 0);
		assert(tx_data == "0");
		assert(state == 0);
	end else if ((p1reg)&&(!$past(i_reset))) begin
		if (p1reg != 1)
			assert($stable(fv_data));
		if (!tx_busy)
			if (p1reg >= 16'h0800)
				p1reg <= 0;
			else
				p1reg <= { p1reg[14:0], 1'b0 };
		if ((!tx_busy)||(f_maxbusy==0))
		begin
			if (p1reg[0])
			begin
				assert((tx_data == "0")&&(state == 1));
				assert((sreg == $past(i_data)));
				assert(sreg == fv_data);
			end
			if (p1reg[1]) begin
				assert((tx_data == "x")&&(state == 2));
				assert(sreg == fv_data);
			end
			if (p1reg[2])
			begin
				assert((tx_data == to_ascii(fv_data[31:28]))&&state == 3);
				assert(sreg == {fv_data[27:0], 4'h0});
			end
			if (p1reg[3])
			begin
				assert((tx_data == to_ascii(fv_data[27:24]))&&state == 4);
				assert(sreg == {fv_data[23:0], 8'h00});
			end
			if (p1reg[4])
			begin
				assert((tx_data == to_ascii(fv_data[23:20]))&&state == 5);
				assert(sreg == {fv_data[19:0], 12'h000});
			end
			if (p1reg[5])
			begin
				assert((tx_data == to_ascii(fv_data[19:16]))&&state == 6);
				assert(sreg == {fv_data[15:0], 16'h0000});
			end
			if (p1reg[6])
			begin
				assert((tx_data == to_ascii(fv_data[15:12]))&&state == 7);
				assert(sreg == {fv_data[11:0], 20'h00000});
			end
			if (p1reg[7])
			begin
				assert((tx_data == to_ascii(fv_data[11:8]))&&state == 8);
				assert(sreg == {fv_data[7:0], 24'h000000});
			end
			if (p1reg[8])
			begin
				assert((tx_data == to_ascii(fv_data[7:4]))&&state == 9);
				assert(sreg == {fv_data[3:0], 28'h0000000});
			end
			if (p1reg[9])
			begin
				assert((tx_data == to_ascii(fv_data[3:0]))&&state == 10);
				assert(sreg == 32'h00000000);
			end
			if (p1reg[10])
				assert((tx_data == "\r")&&(state == 11));
			if (p1reg[11])
				assert((tx_data == "\n")&&(state == 12));

		end
	end//else
	//	assert(state == 0);

`endif
endmodule
