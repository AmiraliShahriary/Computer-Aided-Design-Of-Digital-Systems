module filt_read_module #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [ADDR_LEN - 1:0] filt_len,
    input wire filt_buf_empty,

    output wire filt_buf_read,
    output wire filt_scratch_wen,
    output wire [ADDR_LEN - 1:0] filt_waddr,
    output wire filt_ready
);

    // Internal signals
    wire filt_wcnt_en, reset_all;
    wire filt_end_flag;

    // Instantiate the datapath
    filt_read_datapath #(
        .ADDR_LEN(ADDR_LEN),
        .SCRATCH_DEPTH(SCRATCH_DEPTH),
        .SCRATCH_WIDTH(SCRATCH_WIDTH)
    ) datapath (
        .clk(clk),
        .rst(rst | reset_all),
        .filt_wcnt_en(filt_wcnt_en),
        .filt_len(filt_len),
        .filt_waddr(filt_waddr),
        .filt_end_flag(filt_end_flag)
    );

    // Instantiate the controller
    filt_read_controller #(
        .ADDR_LEN(ADDR_LEN),
        .SCRATCH_DEPTH(SCRATCH_DEPTH),
        .SCRATCH_WIDTH(SCRATCH_WIDTH)
    ) controller (
        .clk(clk),
        .rst(rst),
        .start(start),
        .filt_buf_empty(filt_buf_empty),
        .filt_end_flag(filt_end_flag),
        .filt_buf_read(filt_buf_read),
        .filt_scratch_wen(filt_scratch_wen),
        .filt_wcnt_en(filt_wcnt_en),
        .filt_ready(filt_ready),
        .reset_all(reset_all)
    );

endmodule


module filt_read_controller #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire filt_buf_empty,
    input wire filt_end_flag,

    output reg reset_all,
    output reg filt_wcnt_en,
    output reg filt_buf_read,
    output reg filt_scratch_wen,
    output reg filt_ready
);

    // State encoding
    localparam IDLE = 3'd0;
    localparam INIT = 3'd1;
    localparam ACTIVE = 3'd2;

    reg [2:0] current_state, next_state;

    // Sequential logic for present state
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else if (start)
            current_state <= INIT;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state; // Default to current state
        case (current_state)
            IDLE: next_state = (start) ? INIT : IDLE;
            INIT: next_state = (start) ? INIT : ACTIVE;
            ACTIVE: next_state = (filt_end_flag) ? IDLE : ACTIVE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(*) begin
        reset_all = 1'b0;
        {filt_buf_read, filt_scratch_wen, filt_wcnt_en, filt_ready} = 4'd0;

        case (current_state)
            IDLE: filt_ready = 1'b1;
            INIT: reset_all = 1'b1;
            ACTIVE: begin
                {filt_buf_read, filt_scratch_wen, filt_wcnt_en} = 
                    (~filt_buf_empty) ? {2'b11, ~filt_end_flag} : 3'b000;
            end
            default: ; // No action for undefined states
        endcase
    end

endmodule

module filt_read_datapath #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire clk,
    input wire rst,
    input wire filt_wcnt_en,
    input wire [ADDR_LEN - 1:0] filt_len,
    output wire [ADDR_LEN - 1:0] filt_waddr,
    output wire filt_end_flag
);

    // Counter instantiation
    wire counter_overflow;
    Counter #(
        .NUM_BIT(ADDR_LEN)
    ) write_counter (
        .clk(clk),
        .rst(rst),
        .ld_cnt(1'b0),
        .cnt_en(filt_wcnt_en),
        .co(counter_overflow),
        .load_value({ADDR_LEN{1'b0}}),
        .cnt_out_wire(filt_waddr)
    );

    // Flag register connections
    wire [ADDR_LEN:0] flag_reg_out, flag_reg_in;
    wire flag_reg_load;

    assign flag_reg_load = (flag_reg_out == filt_waddr);
    assign flag_reg_in = (flag_reg_out == 0) ? {1'b0, filt_len} + flag_reg_out - 1 : {1'b0, filt_len} + flag_reg_out;

    wire dummy_flag;

    Register #(
        .SIZE(ADDR_LEN + 1)
    ) flag_register (
        .clk(clk),
        .rst(rst),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(flag_reg_out),
        .inval(flag_reg_in),
        .ld_en(flag_reg_load),
        .msb(dummy_flag)
    );

    // End flag logic
    assign filt_end_flag = (flag_reg_in >= SCRATCH_DEPTH) & flag_reg_load;

endmodule