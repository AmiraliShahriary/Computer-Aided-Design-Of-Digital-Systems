module Register #(parameter WIDTH = 4) (
	input clk,
	input rst,
	input [WIDTH - 1 :0] in,
	output reg [WIDTH - 1 :0] out,
	input en
);

	// reg [WIDTH - 1 :0] out;

	always @(posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else if (en)
			out <= in;

	end

endmodule