`timescale 1ps/1ps


module ShiftRegister_16bit_8bit (
    input clk,               
    input shift,            
    input store,           
    input [15:0] data_in,   
    output reg[15:0] shifted 
);

	
	always @(posedge clk) begin
		if(store)
			shifted <= data_in;
		else if (shift)
			shifted <= shifted << 1;
	end
endmodule



module ShiftRegister_32bit_32bit (
    input clk,               
    input shift,            
    input store,           
    input [31:0] data_in,   
    output reg [31:0] shifted 
);

	
	always @(posedge clk) begin
		if(store)
			shifted <= data_in;
		else if (shift)
			shifted <= shifted << 1;
	end
endmodule
