module design_top #(
    parameter P_SUM_ADDR_LEN = 8,
    parameter P_SUM_SCRATCH_WIDTH = 8,
    parameter P_SUM_SCRATCH_DEPTH = 8,
    parameter FILT_ADDR_LEN = 8,
    parameter IF_ADDR_LEN = 8,
    parameter IF_SCRATCH_DEPTH = 8,
    parameter IF_SCRATCH_WIDTH = 8,
    parameter FILT_SCRATCH_DEPTH = 8,
    parameter FILT_SCRATCH_WIDTH = 8,
    parameter IF_par_write = 1,
    parameter filter_par_write = 1,
    parameter P_SUM_PAR_WRITE = 1,
    parameter outbuf_par_read = 1,
    parameter IF_BUFFER_DEPTH = 8,
    parameter FILT_BUFFER_DEPTH = 8,
    parameter PSUM_BUFFER_DEPTH = 8,
    parameter OUT_BUFFER_DEPTH = 8
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire IF_wen,
    input wire [IF_par_write * (IF_SCRATCH_WIDTH + 2) - 1 : 0] IF_din,
    input wire filter_wen,
    input wire [filter_par_write * FILT_SCRATCH_WIDTH - 1 : 0] filter_din,
    input wire outbuf_ren,
    input wire [IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH - 1:0] P_sum_buff_inp,
    output wire [outbuf_par_read * (IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH) - 1 : 0] outbuf_dout,
    output wire IF_full,
    output wire IF_empty,
    output wire filter_full,
    output wire filter_empty,
    output wire outbuf_full,
    output wire outbuf_empty,
    input wire [FILT_ADDR_LEN - 1:0] filt_len,
    input wire [IF_ADDR_LEN - 1:0] stride_len,
    input wire [1:0] calc_mod,
    input wire just_add_flag,
    input wire psum_buf_wen
);

    // Internal signals
    wire accumulate_input_psum;
    wire IF_read_start, filter_read_start, regs_clr, start_rd_gen, reset_all;
    wire IF_buf_read, filter_buf_read, full_done, psum_done;
    wire stride_count_flag, outbuf_write;
    wire [IF_SCRATCH_WIDTH + 1:0] IF_buf_inp;
    wire [FILT_SCRATCH_WIDTH - 1:0] filter_buf_inp;
    wire [IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH - 1:0] module_outval;
    wire psum_clear, psum_ren, psum_same_addr, psum_empty, psum_full;
    wire stride_pos_ld, usage_stride_pos_ld, reset_Filter;
    wire go_next_row;

    // IF Buffer
    Fifo_buffer #(
        .DATA_WIDTH(IF_SCRATCH_WIDTH + 2),
        .PAR_WRITE(IF_par_write),
        .PAR_READ(1),
        .DEPTH(IF_BUFFER_DEPTH)
    ) IF_buffer (
        .clk(clk),
        .rstn(~rst),
        .clear(1'b0),
        .ren(IF_buf_read),
        .wen(IF_wen),
        .din(IF_din),
        .dout(IF_buf_inp),
        .full(IF_full),
        .empty(IF_empty)
    );

    // Filter Buffer
    Fifo_buffer #(
        .DATA_WIDTH(FILT_SCRATCH_WIDTH),
        .PAR_WRITE(filter_par_write),
        .PAR_READ(1),
        .DEPTH(FILT_BUFFER_DEPTH)
    ) filter_buffer (
        .clk(clk),
        .rstn(~rst),
        .clear(1'b0),
        .ren(filter_buf_read),
        .wen(filter_wen),
        .din(filter_din),
        .dout(filter_buf_inp),
        .full(filter_full),
        .empty(filter_empty)
    );

    // P_sum Buffer
    wire [IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH - 1:0] P_sum_buff_out;
    wire P_sum_buff_empty, P_sum_buff_full;
    Fifo_buffer #(
        .DATA_WIDTH(IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH),
        .PAR_WRITE(P_SUM_PAR_WRITE),
        .PAR_READ(1),
        .DEPTH(PSUM_BUFFER_DEPTH)
    ) p_sum_buffer (
        .clk(clk),
        .rstn(~rst),
        .clear(1'b0),
        .ren(accumulate_input_psum),
        .wen(psum_buf_wen),
        .din(P_sum_buff_inp),
        .dout(P_sum_buff_out),
        .full(P_sum_buff_full),
        .empty(P_sum_buff_empty)
    );

    // Output Buffer
    Fifo_buffer #(
        .DATA_WIDTH(IF_SCRATCH_WIDTH + FILT_SCRATCH_WIDTH),
        .PAR_WRITE(1),
        .PAR_READ(outbuf_par_read),
        .DEPTH(OUT_BUFFER_DEPTH)
    ) out_buffer (
        .clk(clk),
        .rstn(~rst),
        .clear(1'b0),
        .ren(outbuf_ren),
        .wen(accumulate_input_psum),
        .din(module_outval),
        .dout(outbuf_dout),
        .full(outbuf_full),
        .empty(outbuf_empty)
    );

    // Datapath
    design_datapath #(
        .P_SUM_ADDR_LEN(P_SUM_ADDR_LEN),
        .P_SUM_SCRATCH_WIDTH(P_SUM_SCRATCH_WIDTH),
        .P_SUM_SCRATCH_DEPTH(P_SUM_SCRATCH_DEPTH),
        .FILT_ADDR_LEN(FILT_ADDR_LEN),
        .IF_ADDR_LEN(IF_ADDR_LEN),
        .IF_SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
        .IF_SCRATCH_WIDTH(IF_SCRATCH_WIDTH),
        .FILT_SCRATCH_DEPTH(FILT_SCRATCH_DEPTH),
        .FILT_SCRATCH_WIDTH(FILT_SCRATCH_WIDTH)
    ) datapath (
        .clk(clk),
        .rst(rst | reset_all),
        .IF_read_start(IF_read_start),
        .filter_read_start(filter_read_start),
        .regs_clr(regs_clr),
        .IF_buf_empty_flag(IF_empty),
        .filt_buf_empty(filter_empty),
        .start_rd_gen(start_rd_gen),
        .outbuf_full(outbuf_full),
        .filt_len(filt_len),
        .stride_len(stride_len),
        .IF_buf_inp(IF_buf_inp),
        .filt_buf_inp(filter_buf_inp),
        .psum_clear(psum_clear),
        .psum_ren(psum_ren),
        .psum_same_addr(psum_same_addr),
        .filter_mux_sel(1'b0), // TODO
        .accumulate_input_psum(accumulate_input_psum),
        .p_sum_input(P_sum_buff_out),
        .usage_stride_pos_ld(usage_stride_pos_ld),
        .reset_Filter(reset_Filter),
        .go_next_row(go_next_row),
        .module_outval(module_outval),
        .IF_buf_read(IF_buf_read),
        .filt_buf_read(filter_buf_read),
        .full_done(full_done),
        .psum_done(psum_done),
        .stride_count_flag(stride_count_flag),
        .outbuf_write(outbuf_write),
        .stride_pos_ld(stride_pos_ld),
        .psum_empty(psum_empty),
        .psum_full(psum_full)
    );

    // Controller
    design_controller #(
        .FILT_ADDR_LEN(FILT_ADDR_LEN),
        .IF_ADDR_LEN(IF_ADDR_LEN),
        .SCRATCH_DEPTH(IF_SCRATCH_DEPTH),
        .SCRATCH_WIDTH(IF_SCRATCH_WIDTH)
    ) controller (
        .clk(clk),
        .rst(rst),
        .start(start),
        .full_done(full_done),
        .psum_done(psum_done),
        .stride_count_flag(stride_count_flag),
        .stride_pos_ld(stride_pos_ld),
        .usage_stride_pos_ld(usage_stride_pos_ld),
        .reset_Filter(reset_Filter),
        .psum_empty(psum_empty),
        .psum_clear(psum_clear),
        .psum_ren(psum_ren),
        .psum_same_addr(psum_same_addr),
        .reset_all(reset_all),
        .IF_read_start(IF_read_start),
        .filter_read_start(filter_read_start),
        .clear_regs(regs_clr),
        .start_rd_gen(start_rd_gen),
        .mod(calc_mod),
        .just_add_flag(just_add_flag),
        .accumulate(accumulate_input_psum),
        .P_sum_buff_empty(P_sum_buff_empty),
        .go_next_row(go_next_row)
    );

endmodule