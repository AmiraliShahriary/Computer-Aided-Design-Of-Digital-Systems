module P_Sum_Registers #(
    parameter ADDR_LEN = 8,
    parameter SCRATCH_DEPTH = 8,
    parameter SCRATCH_WIDTH = 8
) (
    input wire clk,
    input wire rst,
    input wire wen,
    input wire [ADDR_LEN - 1:0] waddr,
    input wire [ADDR_LEN - 1:0] raddr,
    input wire [SCRATCH_WIDTH - 1:0] din,
    output reg [SCRATCH_WIDTH - 1:0] dout
);


    reg [SCRATCH_WIDTH - 1:0] memory_array [0:SCRATCH_DEPTH - 1];


    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin

            for (i = 0; i < SCRATCH_DEPTH; i = i + 1) begin
                memory_array[i] <= 0;
            end
            dout <= 0;
        end else begin
            if (wen) begin
                memory_array[waddr] <= din;
            end
            dout <= memory_array[raddr];
        end
    end

endmodule
