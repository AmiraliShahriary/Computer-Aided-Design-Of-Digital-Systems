`timescale 1ps/1ps


module CounterB (
    input clk,           
    input ResetB,        
    input IncB,          
    output reg [2:0] countB 
);

    always @(posedge clk or posedge ResetB) begin
        if (ResetB) 
            countB <= 3'b000;     // Reset counter 
        else if (IncB)
            countB <= countB + 1;  
    end

endmodule
