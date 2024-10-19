`timescale 1ps/1ps


module InputRAM (
    input clk,
    input read,          
    input [3:0] addr,    
    output reg [15:0] data_out
);
    reg [15:0] mem [0:15]; 

    initial begin

        $readmemh("input_data.txt", mem);
    end

    always @(posedge clk) begin
        if (read) begin
            data_out <= mem[addr]; 
        end
    end
endmodule
