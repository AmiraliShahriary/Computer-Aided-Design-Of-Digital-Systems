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