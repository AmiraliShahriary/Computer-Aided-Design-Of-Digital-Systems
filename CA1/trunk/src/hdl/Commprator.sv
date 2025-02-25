`timescale 1ps/1ps

module comparator_eq(
    input [2:0] Diff,       
    input [2:0] counter_val, 
    output reg eq           
);
    always @(*) begin
        eq = (Diff == counter_val); 
    end
endmodule

