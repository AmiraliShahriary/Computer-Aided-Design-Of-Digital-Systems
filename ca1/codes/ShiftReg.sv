`timescale 1ps/1ps


module ShiftRegisterB (
    input clk,               
    input shiftB,            
    input storeB,           
    input [15:0] data_in,   
    output reg [7:0] shifted_B 
);
    reg [15:0] regB; 

    always @(posedge clk) begin
        if (shiftB) begin

            regB <= {regB[14:0], 1'b0}; 
        end
        if (storeB) begin
      
            shifted_B <= regB[15:8];
        end
    end

    always @(posedge clk) begin
        regB <= data_in;
    end
endmodule

