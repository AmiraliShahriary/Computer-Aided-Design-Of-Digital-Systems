module design_controller #(
    parameter FILT_ADDR_LEN,
    parameter IF_ADDR_LEN,
    parameter SCRATCH_DEPTH,
    parameter SCRATCH_WIDTH
) (
    input wire clk, rst,
    input wire start, full_done, psum_done, stride_count_flag, just_add_flag, stride_pos_ld,
    input wire P_sum_buff_empty, psum_empty, // TODO: psum_full
    input wire [1:0] mod,
    output reg psum_clear, psum_ren, psum_same_addr,
    output reg reset_all, IF_read_start, filter_read_start,
    output reg clear_regs, start_rd_gen, usage_stride_pos_ld, reset_Filter, accumulate,
    output reg go_next_row
);

    // State encoding (using parameters instead of enum)
    localparam [3:0] IDLE         = 4'd0;
    localparam [3:0] INIT         = 4'd1;
    localparam [3:0] READY        = 4'd2;
    localparam [3:0] MODE_0       = 4'd3;
    localparam [3:0] MODE_1_PRE   = 4'd10;
    localparam [3:0] MODE_1       = 4'd4;
    localparam [3:0] MODE_1_ROW_2 = 4'd8;
    localparam [3:0] MODE_2_PRE   = 4'd9;
    localparam [3:0] MODE_2       = 4'd5;
    localparam [3:0] MODE_3       = 4'd6;
    localparam [3:0] JUST_ADD_MODE = 4'd7;

    reg [3:0] current_state, next_state;

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
            INIT: next_state = (start) ? INIT : READY;
            READY: begin
                if (just_add_flag)
                    next_state = JUST_ADD_MODE;
                else case (mod)
                    2'd0: next_state = MODE_0;
                    2'd1: next_state = MODE_1_PRE;
                    2'd2: next_state = MODE_2_PRE;
                    2'd3: next_state = MODE_2_PRE;
                    default: next_state = READY;
                endcase
            end
            MODE_0: next_state = (full_done) ? READY : MODE_0;
            MODE_1_PRE: next_state = (stride_pos_ld) ? MODE_1 : MODE_1_PRE;
            MODE_1: next_state = (stride_pos_ld) ? MODE_1_ROW_2 : MODE_1;
            MODE_1_ROW_2: next_state = (stride_pos_ld) ? IDLE : MODE_1_ROW_2;
            MODE_2_PRE: next_state = (stride_pos_ld) ? MODE_2 : MODE_2_PRE;
            MODE_2: next_state = (stride_pos_ld) ? IDLE : MODE_2;
            MODE_3: next_state = (full_done) ? READY : MODE_3;
            JUST_ADD_MODE: next_state = (psum_empty) ? IDLE : JUST_ADD_MODE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(*) begin
        // Default values
        psum_clear = 1'b0; psum_ren = 1'b0; psum_same_addr = 1'b1;
        reset_all = 1'b0; IF_read_start = 1'b0; filter_read_start = 1'b0;
        clear_regs = 1'b0; start_rd_gen = 1'b0; usage_stride_pos_ld = 1'b1;
        reset_Filter = 1'b0; accumulate = 1'b0; go_next_row = 1'b0;

        case (current_state)
            IDLE: reset_all = 1'b1;
            INIT: begin
                IF_read_start = 1'b1;
                filter_read_start = 1'b1;
                reset_all = start;
            end
            READY: start_rd_gen = 1'b1;
            MODE_0: begin
                clear_regs = psum_done | stride_count_flag;
                reset_all = start;
            end
            MODE_1: begin
                clear_regs = psum_done | stride_count_flag;
                reset_Filter = stride_pos_ld;
                usage_stride_pos_ld = 1'b0;
                go_next_row = stride_pos_ld;
            end
            MODE_1_ROW_2: clear_regs = psum_done | stride_count_flag;
            MODE_2: begin
                clear_regs = psum_done | stride_count_flag;
                reset_all = start;
            end
            JUST_ADD_MODE: begin
                accumulate = ~P_sum_buff_empty && ~psum_empty;
                psum_ren = 1'b1;
                psum_same_addr = 1'b0;
            end
            default: ; // No action for undefined states
        endcase
    end

endmodule