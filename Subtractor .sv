`timescale 1ps/1ps

module subtractor(
    input [2:0] Sum,         
    input carry_in,          
    output [2:0] Diff        
);
    assign Diff = Sum - carry_in;
endmodule

