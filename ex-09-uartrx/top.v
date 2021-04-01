`default_nettype none
//
module	top(
	
	input wire CLK, 
	input wire BTN_N,
	input wire RX,
	output wire TX);
	
	parameter	CLOCK_RATE_HZ = 12_000_000; 
	parameter	BAUD_RATE = 9_600; // 115.2 KBaud
	

	
	parameter	CLOCKS_PER_BAUD = (CLOCK_RATE_HZ/BAUD_RATE); 
	
	reg tx_stb;
	reg [7:0]tx_data;
	wire tx_busy;
	txuart #(CLOCKS_PER_BAUD[23:0])
		transmitter(CLK, tx_stb, tx_data, TX, tx_busy);

	wire o_wr;
	wire [7:0]o_data; 
	rxuart receiver(CLK, RX, o_wr, o_data);
	
	initial tx_stb =1'b0;
	always @(posedge CLK)
	if(o_wr)
	begin
		tx_stb <= 1'b1;
		tx_data <= o_data;
	end else if (!tx_busy)
		tx_stb <= 1'b0;


endmodule
