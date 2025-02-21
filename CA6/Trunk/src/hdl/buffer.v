`define SIMULATION // Comment this out for synthesis

module Buffer #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 4,
    parameter PAR_WRITE = 1,
    parameter PAR_READ = 1,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input clk,
    input wen,
    input [ADDR_WIDTH - 1 : 0] waddr, //write address
    input [ADDR_WIDTH - 1 : 0] raddr, //read address
    input [PAR_WRITE * DATA_WIDTH - 1 : 0] din, //write data in
    output [PAR_READ * DATA_WIDTH - 1 : 0] dout //read data out
);
    localparam DEPTH_POW2 = (DEPTH & (DEPTH - 1)) == 0;

    reg [DATA_WIDTH - 1 : 0] memory [0 : DEPTH - 1];
    
    reg [$clog2(PAR_WRITE) : 0] par_cnt;

    reg [ADDR_WIDTH - 1 : 0] waddr_mod, waddr_plus_par_cnt;

    always @(posedge clk) begin
    if (wen) begin
        for(par_cnt = 0; par_cnt < PAR_WRITE; par_cnt = par_cnt + 1) begin
            waddr_plus_par_cnt = waddr + par_cnt;

            if (DEPTH_POW2) begin
                waddr_mod = waddr_plus_par_cnt[ADDR_WIDTH - 1 : 0];
            end else begin
                waddr_mod = waddr_plus_par_cnt;
                if (waddr_plus_par_cnt >= DEPTH)
                    waddr_mod = waddr_plus_par_cnt - DEPTH;
            end

            memory[waddr_mod] <= din[par_cnt * DATA_WIDTH +: DATA_WIDTH];
        end
    end
end

    genvar i;
    generate
        for (i = 0; i < PAR_READ; i = i + 1) begin : read_loop
            wire [ADDR_WIDTH : 0] raddr_plus_i = raddr + i;
            wire [ADDR_WIDTH - 1 : 0] ind;

            if (DEPTH_POW2) begin
                assign ind = raddr_plus_i[ADDR_WIDTH - 1 : 0];
            end else begin
                assign ind = (raddr_plus_i >= DEPTH) ? raddr_plus_i - DEPTH : raddr_plus_i;
            end

            assign dout[i * DATA_WIDTH +: DATA_WIDTH] = memory[ind];
        end
    endgenerate

    `ifdef SIMULATION
    integer c;
    initial begin
        for (c = 0; c < DEPTH; c = c + 1)
            memory[c] = 0;
    end
    `endif
        
endmodule







// NEED MORE REVIEW

module Fifo_buffer #(
    parameter DATA_WIDTH = 16, // Data bitwidth
    parameter PAR_WRITE = 1,
    parameter PAR_READ = 1,
    parameter DEPTH = 4 // Total size
) (
    input clk,
    input rstn, // Active low reset
    input clear, // Clear buffer counters
    input ren, // Read enable 
    input wen, // Write enable
    input [PAR_WRITE * DATA_WIDTH - 1 : 0] din, // Input data to write into the buffer
    output [PAR_READ * DATA_WIDTH - 1 : 0] dout, // Output data to read from the buffer
    output full, // Output to signal if buffer is full
    output empty // Output to signal if buffer is empty
);

    // For circular buffer, consider one more register as one is always unused
    localparam BUFFER_DEPTH = DEPTH + 1;
    localparam BUFFER_ADDR_WIDTH = $clog2(BUFFER_DEPTH);
    localparam PAR_DATA_WRITE = PAR_WRITE == 1 ? PAR_WRITE - 1 : PAR_WRITE;
    localparam PAR_DATA_READ = PAR_READ == 1 ? PAR_READ - 1 : PAR_READ;

    reg [BUFFER_ADDR_WIDTH - 1 : 0] read_ptr, write_ptr;
    wire buffer_wen, buffer_ren;
    wire write_ptr_max, read_ptr_max;

    assign buffer_wen = wen & !full;
    assign buffer_ren = ren & !empty;

    assign write_ptr_max = write_ptr >= BUFFER_DEPTH;
    assign read_ptr_max = read_ptr >= DEPTH;

    wire [PAR_DATA_WRITE : 0] full_flags;
    wire [PAR_DATA_READ : 0] empty_flags;

    genvar i;
    generate
        for (i = 0; i <= PAR_DATA_WRITE; i = i + 1) begin : FULL_FLAG_GEN
            wire [BUFFER_ADDR_WIDTH - 1 : 0] write_ptr_next = write_ptr + (i + 1);
            assign full_flags[i] = (write_ptr_next >= BUFFER_DEPTH) ? (write_ptr_next - BUFFER_DEPTH) == read_ptr : write_ptr_next == read_ptr;
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j <= PAR_DATA_READ; j = j + 1) begin : EMPTY_FLAG_GEN
            wire [BUFFER_ADDR_WIDTH - 1 : 0] read_ptr_next = read_ptr + j;
            assign empty_flags[j] = (read_ptr_next >= DEPTH) ? (read_ptr_next - DEPTH) == write_ptr : read_ptr_next == write_ptr;
        end
    endgenerate

    assign full = |full_flags;
    assign empty = |empty_flags;

    Buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .PAR_WRITE(PAR_WRITE),
        .PAR_READ(PAR_READ),
        .DEPTH(BUFFER_DEPTH),
        .ADDR_WIDTH(BUFFER_ADDR_WIDTH)
    ) buffer (
        .clk(clk),
        .wen(buffer_wen),
        .waddr(write_ptr),
        .raddr(read_ptr),
        .din(din),
        .dout(dout)
    );

    always @(posedge clk) begin
        if (!rstn) begin
            read_ptr <= 0;
            write_ptr <= 0;
        end
        else if (clear) begin
            read_ptr <= 0;
            write_ptr <= 0;
        end
        else begin
            if (buffer_wen) begin
                write_ptr <= write_ptr + PAR_WRITE;
                if (write_ptr >= BUFFER_DEPTH)
                    write_ptr <= write_ptr - BUFFER_DEPTH;
            end

            if (buffer_ren) begin
                read_ptr <= read_ptr + PAR_READ;
                if (read_ptr >= BUFFER_DEPTH)
                    read_ptr <= read_ptr - BUFFER_DEPTH;
            end
        end
    end

endmodule

module Psum_scratch_pad #(
    parameter DATA_WIDTH = 16, // Data bitwidth
    parameter PAR_WRITE = 1,
    parameter PAR_READ = 1,
    parameter DEPTH = 4 // Total size
) (
    input clk,
    input rstn, // Active low reset
    input clear, // Clear buffer counters
    input ren, // Read enable 
    input wen, // Write enable
    input freeze, // Freeze buffer
    input same_addr, // Use same address for read and write
    input [PAR_WRITE * DATA_WIDTH - 1 : 0] din, // Input data to write into the buffer
    output [PAR_READ * DATA_WIDTH - 1 : 0] dout, // Output data to read from the buffer
    output full, // Output to signal if buffer is full
    output empty // Output to signal if buffer is empty
);

    wire [DATA_WIDTH - 1 : 0] din_buffer;
    wire [DATA_WIDTH - 1 : 0] dout_buffer;
    wire [DATA_WIDTH - 1 : 0] din_register;
    wire [DATA_WIDTH - 1 : 0] dout_register;
    wire temp;
    reg wen_buffer;
    wire ren_buffer;
    wire full_buffer;
    reg reset_register;
    reg rstn_buffer;

    always @(posedge clk) begin
        if (rstn_buffer === 1'bX) begin
            rstn_buffer <= 1'b0;
        end
        else begin
            rstn_buffer <= 1'b1;
        end
    end

    Fifo_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .PAR_WRITE(PAR_WRITE),
        .PAR_READ(PAR_READ),
        .DEPTH(DEPTH)
    ) psum_buffer (
        .clk(clk),
        .rstn(rstn_buffer),
        .clear(clear),
        .ren(ren_buffer),
        .wen(wen_buffer),
        .din(din_buffer),
        .dout(dout_buffer),
        .full(full),
        .empty(empty)
    );

    Register #(
        .SIZE(DATA_WIDTH)
    ) temp_register (
        .clk(clk),
        .rst(~rstn | reset_register),
        .right_shen(1'b0),
        .left_shen(1'b0),
        .ser_in(1'b0),
        .outval(dout_register),
        .inval(din_register),
        .ld_en(wen_register),
        .msb(temp)
    );

    Mux2to1 #(
        .WIDTH(DATA_WIDTH)
    ) output_mux (
        .a(dout_buffer),
        .b(dout_register),
        .sel(same_addr),
        .c(dout)
    );

    assign din_buffer = dout_register;
    assign din_register = din;
    assign ren_buffer = ren;
    assign wen_register = wen;

    reg freeze_flag;

    always @(posedge clk) begin
        wen_buffer <= 1'b0;
        if (freeze == 1'b0 && freeze_flag == 1'b1 && same_addr) begin
            freeze_flag <= 1'b0;
            wen_buffer <= 1'b1;
        end
        if (freeze && same_addr) begin
            freeze_flag <= 1'b1;
        end
        reset_register <= wen_buffer;
    end

endmodule