module CircularBuffer #(parameter WIDTH = 4, parameter DEPTH = 3, parameter PW = 2, parameter PR = 2) (
		input clk,
		input wEn,
		input rEn,
		input rst,
		input [WIDTH * (1 << PW) - 1 :0] in,
		output [WIDTH * (1 << PR) - 1 :0] out,
		output ready, 
		output valid,
		output empty,
		output full
	);

	wire [DEPTH - 1 :0] st, en, stNext, enNext, cap;


	Register #(.WIDTH(DEPTH)) startReg (
		.clk(clk),
		.en(ready), 
		.rst(rst), 
		.in(stNext), 
		.out(st)
	);
	
	Register #(.WIDTH(DEPTH)) endReg (
		.clk(clk), 
		.en(valid), 
		.rst(rst), 
		.in(enNext), 
		.out(en)
	);
	
	LinearBuffer #(.WIDTH(WIDTH), .DEPTH(DEPTH), .PW(PW), .PR(PR)) theLinearBuffer (
		.clk(clk),
		.writeEn(ready),
		.rst(rst), 
		.in(in), 
		.out(out),
		.writeAddress(st), 
		.readAddress(en)
	);
	
	
	assign stNext = st + (1 << PW);
	assign enNext = en + (1 << PR);
	assign cap = en - st - 1;
	assign empty = cap >= (1 << PW);
	assign full = cap < ((1 << DEPTH) - (1 << PR));
	assign ready = empty && wEn;
	assign valid = full && rEn;

endmodule
