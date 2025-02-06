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
    wire reset_all;
    wire IF_end_reg_en, IF_start_reg_en;

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
        .reset_all(reset_all),
        .IF_end_reg_en(IF_end_reg_en),
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
        .IF_wcnt_en(IF_wcnt_en),
        .IF_start_reg_en(IF_start_reg_en),
        .IF_end_reg_en(IF_end_reg_en),
        .IF_start(IF_start),
        .IF_end(IF_end),
        .IF_waddr(IF_waddr_internal)
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
    input wire IF_buf_end_flag, IF_buf_empty_flag, full_done,
    input wire [ADDR_LEN - 1:0] IF_start, IF_end, IF_waddr,

    output reg IF_buf_read, IF_scratch_wen, IF_end_valid, reset_all,
    output reg IF_wcnt_en, IF_end_reg_en, IF_start_reg_en
);

    // State encoding using one-hot encoding
    localparam IDLE = 3'b001;
    localparam INIT = 3'b010;
    localparam ACTIVE = 3'b100;

    reg [2:0] current_state, next_state;

    // Sequential logic for present state
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state; // Default to current state
        case (current_state)
            IDLE: next_state = (start) ? INIT : IDLE;
            INIT: next_state = ACTIVE;
            ACTIVE: begin
                if (IF_buf_end_flag)
                    next_state = (full_done) ? IDLE : ACTIVE;
                else
                    next_state = ACTIVE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    wire write_not_safe;
    assign write_not_safe = (((IF_waddr + 1) % SCRATCH_DEPTH) == IF_start);

    always @(*) begin
        reset_all = 1'b0;
        {IF_buf_read, IF_scratch_wen, IF_wcnt_en, IF_end_reg_en, IF_end_valid,
         IF_start_reg_en} = 6'b0;

        case (current_state)
            INIT: reset_all = 1'b1;

            ACTIVE: begin
                IF_buf_read = ~IF_buf_empty_flag;
                IF_scratch_wen = ~IF_buf_empty_flag;
                IF_wcnt_en = ~IF_buf_empty_flag;
                IF_end_reg_en = IF_buf_end_flag;

                if (IF_buf_end_flag) begin
                    IF_end_valid = 1'b1;
                    IF_start_reg_en = full_done;
                end
            end
        endcase
    end

endmodule

module IF_read_datapath #(
    parameter ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire clk, rst, IF_wcnt_en, IF_start_reg_en, IF_end_reg_en,
    output wire [ADDR_LEN - 1:0] IF_start, IF_end, IF_waddr
);

    // Address counter logic
    reg [ADDR_LEN - 1:0] write_addr;
    wire counter_overflow;
    assign counter_overflow = (write_addr == SCRATCH_DEPTH - 1);

    always @(posedge clk or posedge rst) begin
        if (rst)
            write_addr <= 0;
        else if (IF_wcnt_en) begin
            if (counter_overflow)
                write_addr <= 0;
            else
                write_addr <= write_addr + 1;
        end
    end

    assign IF_waddr = write_addr;

    // IF End Register
    reg [ADDR_LEN - 1:0] end_reg;
    always @(posedge clk or posedge rst) begin
        if (rst)
            end_reg <= 0;
        else if (IF_end_reg_en)
            end_reg <= write_addr;
    end

    assign IF_end = end_reg;

    // IF Start Register
    reg [ADDR_LEN - 1:0] start_reg;
    wire [ADDR_LEN - 1:0] next_start_addr;
    assign next_start_addr = (end_reg + 1) % SCRATCH_DEPTH;

    always @(posedge clk or posedge rst) begin
        if (rst)
            start_reg <= 0;
        else if (IF_start_reg_en)
            start_reg <= next_start_addr;
    end

    assign IF_start = start_reg;

endmodule