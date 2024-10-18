`timescale 1ps/1ps


module ShiftRegisterA (
    input clk,               
    input shiftA,            
    input storeA,           
    input [15:0] data_in,   
    output reg [7:0] shifted_A 
);
    reg [15:0] regA; 

    always @(posedge clk) begin
        if (shiftA) begin

            regA <= {regA[14:0], 1'b0}; 
        end
        if (storeA) begin
      
            shifted_A <= regA[15:8];
        end
    end

    always @(posedge clk) begin
        regA <= data_in;
    end
endmodule
