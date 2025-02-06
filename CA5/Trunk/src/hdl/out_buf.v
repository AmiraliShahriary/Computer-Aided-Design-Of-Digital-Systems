module outbuf_module (
    input wire clk, rst, done, outbuf_full, read_from_scratch,
    output reg stall_pipeline, psum_done, outbuf_write
);


    localparam IDLE = 4'b0001;       
    localparam WAIT_READ = 4'b0010;  
    localparam PROCESS = 4'b0100;    
    localparam WAIT_OUTBUF = 4'b1000;
    localparam DONE = 4'b10000;    

    reg [4:0] current_state, next_state;


    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state; 
        case (current_state)
            IDLE: next_state = (done) ? WAIT_READ : IDLE;
            WAIT_READ: next_state = (read_from_scratch) ? PROCESS : WAIT_READ;
            PROCESS: next_state = (read_from_scratch) ? WAIT_OUTBUF : PROCESS;
            WAIT_OUTBUF: next_state = (outbuf_full) ? WAIT_OUTBUF : DONE;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end


    always @(*) begin
        stall_pipeline = 1'b0;
        outbuf_write = 1'b0;
        psum_done = 1'b0;

        case (current_state)
            WAIT_OUTBUF: begin
                stall_pipeline = outbuf_full;
                outbuf_write = ~outbuf_full;
            end
            DONE: psum_done = 1'b1;
            default: ; 
        endcase
    end

endmodule