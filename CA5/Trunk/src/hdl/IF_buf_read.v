module IF_read_module #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire IF_buf_end_flag,
    input wire IF_buf_empty_flag,
    input wire full_done,
    input wire go_next_row,

    output wire [ADDR_LEN - 1:0] start_IF,
    output wire [ADDR_LEN - 1:0] end_IF,
    output wire IF_buf_read,
    output wire IF_scratch_wen,
    output wire [ADDR_LEN - 1:0] IF_waddr,
    output wire IF_end_valid
);

    // Internal wires for connections
    wire IF_wcnt_en;
    wire [ADDR_LEN - 1:0] IF_start, IF_end, IF_waddr_internal;
    wire IF_end_valid_internal;
    wire last_was_end, reset_all;
    wire IF_end_reg_en, LWE_en, LWE_set, IF_start_reg_en;

    // Instantiate the IF_read_controller
    IF_read_controller #(
        .ADDR_LEN(ADDR_LEN),
        .SCRATCH_DEPTH(SCRATCH_DEPTH),
        .SCRATCH_WIDTH(SCRATCH_WIDTH)
    ) controller (
        .start(start),
        .clk(clk),
        .rst(rst),
        .IF_buf_end_flag(IF_buf_end_flag),
        .IF_buf_empty_flag(IF_buf_empty_flag),
        .full_done(full_done),
        .IF_wcnt_en(IF_wcnt_en),
        .IF_start(IF_start),
        .IF_end(IF_end),
        .IF_waddr(IF_waddr_internal),
        .IF_buf_read(IF_buf_read),
        .IF_scratch_wen(IF_scratch_wen),
        .IF_end_valid(IF_end_valid_internal),
        .last_was_end(last_was_end),
        .reset_all(reset_all),
        .IF_end_reg_en(IF_end_reg_en),
        .LWE_en(LWE_en),
        .LWE_set(LWE_set),
        .IF_start_reg_en(IF_start_reg_en)
    );

    // Instantiate the IF_read_datapath
    IF_read_datapath #(
        .ADDR_LEN(ADDR_LEN),
        .SCRATCH_DEPTH(SCRATCH_DEPTH),
        .SCRATCH_WIDTH(SCRATCH_WIDTH)
    ) datapath (
        .clk(clk),
        .rst(rst | reset_all),
        .LWE_en(LWE_en),
        .IF_wcnt_en(IF_wcnt_en),
        .LWE_set(LWE_set),
        .IF_start_reg_en(IF_start_reg_en | go_next_row),
        .IF_end_reg_en(IF_end_reg_en),
        .IF_start(IF_start),
        .IF_end(IF_end),
        .IF_waddr(IF_waddr_internal),
        .last_was_end(last_was_end)
    );

    // Assign outputs
    assign start_IF = IF_start;
    assign end_IF = IF_end;
    assign IF_waddr = IF_waddr_internal;
    assign IF_end_valid = IF_end_valid_internal;

endmodule


module IF_read_controller #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire start, clk, rst,
    input wire IF_buf_end_flag, IF_buf_empty_flag, full_done, last_was_end,
    input wire [ADDR_LEN - 1:0] IF_start, IF_end, IF_waddr,

    output reg IF_buf_read, IF_scratch_wen, IF_end_valid, reset_all,
    output reg IF_wcnt_en, IF_end_reg_en, LWE_en, LWE_set, IF_start_reg_en
);

    // State encoding
    localparam IDLE = 3'd0;
    localparam INIT = 3'd1;
    localparam ACTIVE = 3'd2;
    localparam WAIT = 3'd3;

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
            ACTIVE: next_state = (IF_buf_end_flag) ? WAIT : ACTIVE;
            WAIT: next_state = (~full_done || (full_done && last_was_end)) ? WAIT : ACTIVE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    wire write_not_safe;
    assign write_not_safe = (((IF_waddr + 1) % SCRATCH_DEPTH) == IF_start);

    always @(*) begin
        reset_all = 1'b0;
        {IF_buf_read, IF_scratch_wen, IF_wcnt_en, IF_end_reg_en, IF_end_valid,
         LWE_en, LWE_set, IF_start_reg_en} = 8'b0;

        case (current_state)
            INIT: reset_all = 1'b1;

            ACTIVE: begin
                {IF_buf_read, IF_scratch_wen, IF_wcnt_en} = 
                    (~IF_buf_empty_flag) ? 3'b111 : 3'b000;
                IF_end_reg_en = IF_buf_end_flag;
            end

            WAIT: begin
                IF_end_valid = 1'b1;
                {IF_buf_read, IF_scratch_wen, LWE_set} = 
                    (IF_buf_empty_flag || write_not_safe) ? 
                    3'b000 : {2'b11, IF_buf_end_flag};
                IF_wcnt_en = ~(IF_buf_empty_flag || write_not_safe);
                {IF_start_reg_en, IF_end_reg_en} = 
                    (full_done) ? {1'b1, last_was_end} : 2'b00;
                LWE_en = (full_done || ~(IF_buf_empty_flag || ((IF_waddr + 1) % SCRATCH_DEPTH == IF_start))) ? 1'b1 : 1'b0;
            end
        endcase
    end

endmodule

module IF_read_datapath #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire clk, rst, LWE_en, IF_wcnt_en, LWE_set, IF_start_reg_en, IF_end_reg_en,
    output wire [ADDR_LEN - 1:0] IF_start, IF_end, IF_waddr,
    output wire last_was_end
);

    wire ld_cnt, wcnt_co_dum;
    assign ld_cnt = (IF_waddr == SCRATCH_DEPTH - 1) & IF_wcnt_en;

    // Counter for write address
    Counter #(
        .NUM_BIT(ADDR_LEN)
    ) write_counter (
        .clk(clk),
        .load_value({ADDR_LEN{1'b0}}),
        .rst(rst),
        .ld_cnt(ld_cnt),
        .cnt_en(IF_wcnt_en),
        .co(wcnt_co_dum),
        .cnt_out_wire(IF_waddr)
    );

    // Last Was End (LWE) Register
    wire lwe_dum;
    Register #(
        .SIZE(1)
    ) LWE_register (
        .clk(clk),
        .rst(rst),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(last_was_end),
        .inval(LWE_set),
        .ld_en(LWE_en),
        .msb(lwe_dum)
    );

    // IF End Register
    wire end_reg_dum;
    wire [ADDR_LEN - 1:0] end_reg_inval;
    assign end_reg_inval = IF_waddr - last_was_end;

    Register #(
        .SIZE(ADDR_LEN)
    ) IF_end_register (
        .clk(clk),
        .rst(rst),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(IF_end),
        .inval(end_reg_inval),
        .ld_en(IF_end_reg_en),
        .msb(end_reg_dum)
    );

    // IF Start Register
    wire [ADDR_LEN - 1:0] start_reg_inval;
    assign start_reg_inval = (IF_end + 1) % (SCRATCH_DEPTH);

    Register #(
        .SIZE(ADDR_LEN)
    ) IF_start_register (
        .clk(clk),
        .rst(rst),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(IF_start),
        .inval(start_reg_inval),
        .ld_en(IF_start_reg_en),
        .msb()
    );

endmodule