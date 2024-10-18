`timescale 1ps/1ps


module Multiplier8x8 (
    input [7:0] shifted_A,      
    input [7:0] shifted_B,      
    output [15:0] Res   
);


    assign Res = shifted_A * shifted_B;

endmodule

