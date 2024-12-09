module MUX #(parameter WIDTH = 4, parameter SELECT = 3) (
		input [WIDTH * (1 << SELECT) - 1 :0] in,
		output [WIDTH - 1 :0] out,
		input [SELECT - 1 :0] sel
	);

assign out = in[(sel * WIDTH) +:  WIDTH];


endmodule
