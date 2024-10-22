`timescale 1ps/1ps


module InputRAM (
    input clk,
    input load,
    input read,          
    input [3:0] addr,    
    output reg [15:0] data_out
);
    reg [15:0] mem [0:15]; 

    always @(posedge clk) begin
        if (load) begin
            $readmemb("file/data_input.txt", mem);
        end
        if (read) begin
            data_out <= mem[addr]; 
        end
    end
endmodule
