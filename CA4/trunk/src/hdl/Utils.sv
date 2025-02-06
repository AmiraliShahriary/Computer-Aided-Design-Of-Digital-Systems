module ALUBiggerEq(a, b, neg, ans);
	parameter WIDTH = 4;
	input [WIDTH-1:0] a, b;
	output neg;
	output [WIDTH-1:0] ans;
	assign ans = a - b;
	assign neg = (a <= b) ? 1 : 0;
endmodule


module ALUBigger(a, b, neg, ans);
	parameter WIDTH = 4;
	input [WIDTH-1:0] a, b;
	output neg;
	output [WIDTH-1:0] ans;
	assign ans = a - b;
	assign neg = (a < b) ? 1 : 0;
endmodule


module Counter #(
    parameter WIDTH = 8
) (
    input clk,
    input rst,
    input en,
    output reg [WIDTH-1:0] counter
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end
        else if (en) begin
            counter <= counter + 1;
        end
    end
endmodule


module Decrementer(data, new_data);
	parameter WIDTH = 4,DecVal = 1;
	input [WIDTH-1:0] data;
	output [WIDTH-1:0] new_data;
	assign new_data = data - DecVal - 1;
endmodule


module Incrementer(data, new_data);
	parameter WIDTH = 4,IncVal = 1;
	input [WIDTH-1:0] data;
	output [WIDTH-1:0] new_data;
	assign new_data = data + IncVal;
endmodule



module Mux2to1(a, b, sel, c);
	parameter WIDTH = 4;	
	input [WIDTH-1:0] a, b;
	input sel;
	output [WIDTH-1:0] c;
	assign c = (sel==1) ? b : a;
endmodule



module Register(clk, rst, ld_data, ParIn, data);
    parameter WIDTH = 4;
    input clk, rst, ld_data;
    input [WIDTH - 1 :0] ParIn;
    output reg [WIDTH - 1:0] data;

  always @(posedge clk, posedge rst) begin
    if (rst) data <= 0;
    else if (ld_data) data <= ParIn;
  end
endmodule

