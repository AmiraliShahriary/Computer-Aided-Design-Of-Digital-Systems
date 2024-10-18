`timescale 1ps/1ps


module adder(
    input [2:0] A, B,    
    input carry_in,      
    output [2:0] Sum,    
    output carry_out     
);
    assign {carry_out, Sum} = A + B + carry_in; //????
endmodule
