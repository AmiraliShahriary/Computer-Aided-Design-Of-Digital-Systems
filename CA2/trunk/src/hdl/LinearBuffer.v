module LinearBuffer #(parameter WIDTH = 4, parameter DEPTH = 3, parameter PW = 2, parameter PR = 2) (
		input clk,
		input writeEn,
		input rst,
		input [WIDTH * (1 << PW) - 1 :0] in,
		input [DEPTH  - 1 :0] writeAddress,
		input [DEPTH  - 1 :0] readAddress,
		output [WIDTH * (1 << PR) - 1 :0] out

	);


	wire regEn[(1 << DEPTH) - 1 :0];
	wire [WIDTH - 1 :0] regIn[(1 << DEPTH) - 1 :0];
	wire [DEPTH - 1 :0] diff[(1 << DEPTH) - 1 :0];
	wire [DEPTH - 1 :0] outSel[(1 << PR) - 1 :0];
	wire [WIDTH * (1 << DEPTH) - 1 :0] regOut;

	genvar i;
	generate
		for(i = 0; i < (1 << DEPTH); i=i+1) begin
			Register #(.WIDTH(WIDTH)) reg_i (
				.clk(clk), 
				.en(regEn[i]), 
				.rst(rst), 
				.in(regIn[i]), 
				.out(regOut[i * WIDTH +: WIDTH])
			);
			
			MUX #(.WIDTH(WIDTH), .SELECT(PW)) mux_i (
				.in(in),
				.out(regIn[i]),
				.sel(diff[i][PW - 1 :0])
			);
			
			assign diff[i] = i - writeAddress;
			assign regEn[i] = writeEn && (diff[i] < (1 << PW));
		end
		

		
		for(i = 0; i < (1 << PR); i=i+1) begin

			MUX #(.WIDTH(WIDTH), .SELECT(DEPTH)) out_i (
				.in(regOut),
				.out(out[i * WIDTH +: WIDTH]), 
				.sel(outSel[i])
			);
			
			assign outSel[i] = readAddress + i;

		end

	endgenerate

endmodule
