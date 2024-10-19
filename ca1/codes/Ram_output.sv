`timescale 1ps/1ps

module OutputRAM (
    input clk,
    input write,          
    input [2:0] addr,     // 3 bit address for 8 entries
    input [31:0] data_in, 
    output reg [31:0] data_out
);
    reg [31:0] mem [0:7]; 

    always @(posedge clk) begin
        if (write) begin
            mem[addr] <= data_in; 
        end
    end


    initial begin
        $writememh("output_results.txt", mem); 
    end
endmodule

