module IF_scratch #(
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
    output wire [SCRATCH_WIDTH - 1:0] dout
);

    // Internal memory array
    reg [SCRATCH_WIDTH - 1:0] memory [0:SCRATCH_DEPTH - 1];

    // Asynchronous read
    assign dout = memory[raddr];

    // Integer declaration for the loop
    integer i;

    // Synchronous write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize memory to zero
            for (i = 0; i < SCRATCH_DEPTH; i = i + 1) begin
                memory[i] <= {SCRATCH_WIDTH{1'b0}};
            end
        end
        else if (wen) begin
            // Write data to memory at the specified address
            memory[waddr] <= din;
        end
    end

endmodule


module filter_scratch #(
    parameter ADDR_LEN = 8,
    parameter SCRATCH_DEPTH = 8,
    parameter SCRATCH_WIDTH = 8
) (
    input wire clk,
    input wire rst,
    input wire wen,
    input wire ren,
    input wire clr_out,
    input wire [ADDR_LEN - 1:0] waddr,
    input wire [ADDR_LEN - 1:0] raddr,
    input wire [SCRATCH_WIDTH - 1:0] din,
    output reg [SCRATCH_WIDTH - 1:0] dout
);

    // Internal memory array
    reg [SCRATCH_WIDTH - 1:0] memory [0:SCRATCH_DEPTH - 1];

    // Integer declaration for the loop
    integer i;

    // Synchronous read and write logic
    always @(posedge clk or posedge rst or posedge clr_out) begin
        if (rst) begin
            // Initialize memory to zero
            for (i = 0; i < SCRATCH_DEPTH; i = i + 1) begin
                memory[i] <= {SCRATCH_WIDTH{1'b0}};
            end
            dout <= {SCRATCH_WIDTH{1'b0}};
        end
        else if (clr_out) begin
            // Clear output and optionally write data
            dout <= {SCRATCH_WIDTH{1'b0}};
            if (wen) begin
                memory[waddr] <= din;
            end
        end
        else begin
            // Normal operation
            if (wen) begin
                memory[waddr] <= din;
            end
            if (ren) begin
                dout <= memory[raddr];
            end
        end
    end

endmodule