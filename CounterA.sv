`timescale 1ps/1ps


module CounterA (
    input clk,           
    input ResetA,        
    input IncA,          
    output reg [2:0] countA 
);

    always @(posedge clk or posedge ResetA) begin
        if (ResetA) 
            countA <= 3'b000;     // Reset counter 
        else if (IncA)
            countA <= countA + 1;  
    end

endmodule

