`default_nettype none



module Register #(parameter SIZE = 16) (
    input wire clk, rst, right_shen, ser_in, left_shen, ld_en,
    input wire [SIZE - 1:0] inval,
    output wire msb,
    output wire [SIZE - 1:0] outval
);

    reg [SIZE - 1:0] internal_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) 
            internal_reg <= 0;
        else if (ld_en) 
            internal_reg <= inval;
        else begin
            if (right_shen) 
                internal_reg <= {ser_in, internal_reg[SIZE - 1:1]};
            else if (left_shen) 
                internal_reg <= {internal_reg[SIZE - 2:0], ser_in};
        end
    end

    assign outval = internal_reg;
    assign msb = internal_reg[SIZE - 1];

endmodule

module Counter #(parameter NUM_BIT = 4) (
    input wire clk, rst, ld_cnt, cnt_en,
    input wire [NUM_BIT - 1:0] load_value,
    output wire co,
    output wire [NUM_BIT - 1:0] cnt_out_wire
);

    reg [NUM_BIT - 1:0] count_reg = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) 
            count_reg <= 0;
        else begin
            if (ld_cnt) 
                count_reg <= load_value;
            else if (cnt_en) 
                count_reg <= count_reg + 1;
        end
    end

    assign co = &count_reg;
    assign cnt_out_wire = count_reg;

endmodule

module IF_distance_calculator #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire [ADDR_LEN - 1:0] start_val, end_val,
    output wire [ADDR_LEN - 1:0] distance
);

    wire [ADDR_LEN - 1:0] diff1, diff2;
    wire [ADDR_LEN - 1:0] distance_high, distance_low;
    wire select_high;

    assign diff1 = start_val - end_val;
    assign diff2 = SCRATCH_DEPTH - diff1;


    assign distance_high = diff2;
    assign distance_low = end_val - start_val;

    assign select_high = (start_val > end_val);
    assign distance = select_high ? distance_high : distance_low;

endmodule

module signed_multiplier #(
    parameter INPUT_A_WIDTH = 16, 
    parameter INPUT_B_WIDTH = 16,
    parameter OUTPUT_WIDTH = INPUT_A_WIDTH + INPUT_B_WIDTH 
) (
    input wire signed [INPUT_A_WIDTH-1:0] operand_a,
    input wire signed [INPUT_B_WIDTH-1:0] operand_b,
    output wire signed [OUTPUT_WIDTH-1:0] result 
);

    assign result = operand_a * operand_b;

endmodule


module SRAM #(parameter ADDR_WIDTH = 8, parameter DATA_WIDTH = 16, parameter INIT_FILE = "") (
    input   [ADDR_WIDTH-1:0] read_addr,
    output reg [DATA_WIDTH-1:0] read_data,
    input [ADDR_WIDTH-1:0] write_addr,
    input write_enable,
    input [DATA_WIDTH-1:0] write_data,
    input clk
);

    logic [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];
    
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, memory);
        end
    end
    
    always @(posedge clk) begin
        if (write_enable) begin
            memory[write_addr] <= write_data;
        end
        read_data <= memory[read_addr];
    end
    
endmodule



module AddressCounter #(parameter ADDR_WIDTH = 8, parameter OFFSET = 0) (
    input   clk,
    input   reset,
    input   enable,
    output reg [ADDR_WIDTH-1:0] addr
);
    logic [ADDR_WIDTH-1:0] counter;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else if (enable)
            counter <= counter + 1;
    end
    
    assign addr = counter + OFFSET;
    
endmodule
