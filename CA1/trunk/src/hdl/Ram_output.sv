`timescale 1ps/1ps

module OutputRAM (
    input clk,
    input save,
    input store,      
    input [31:0] val,   
    input [2:0] addr
);
    reg [31:0] mem [0:7]; 


    initial begin
        mem[0] = 32'h0;
        mem[1] = 32'h0;
        mem[2] = 32'h0;
        mem[3] = 32'h0;
        mem[4] = 32'h0;
        mem[5] = 32'h0;
        mem[6] = 32'h0;
        mem[7] = 32'h0;
    end

    always @(posedge clk) begin
        if (save)
            $writememh("file/out.txt", mem);
        if (store)
            mem[addr] <= val;
    end

endmodule

