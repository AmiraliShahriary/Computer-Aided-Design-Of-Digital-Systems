`timescale 1ns/1ns

`define HALF_CLK 5
`define CLK (2 * `HALF_CLK)

module TB;
    parameter BUFFER_WIDTH = 16;
    parameter BUFFER_DEPTH = 8;
    parameter PAR_WRITE = 4;
    parameter PAR_READ = 1;

    reg clk;
    reg rstn;
    reg wen, ren;
    reg [PAR_WRITE * BUFFER_WIDTH - 1 : 0] din;
    wire [PAR_READ * BUFFER_WIDTH - 1 : 0] dout;
    wire buffer_ready, ready_out, empty, full;

    CircularBuffer #(
        .WIDTH(BUFFER_WIDTH),
        .DEPTH(BUFFER_DEPTH),
        .PW(PAR_WRITE),
        .PR(PAR_READ)
    ) dut (
        .clk(clk),             
        .wEn(wen),             
        .rEn(ren),             
        .rst(rstn),           
        .in(din),             
        .out(dout),           
        .ready(buffer_ready),  
        .valid(ready_out),    
        .empty(empty),         
        .full(full)            
    );


    always begin
        #`HALF_CLK clk = ~clk;
    end


    initial begin
        clk = 0;
        rstn = 0;
        wen = 0;
        din = 0;

        #`CLK;
        rstn = 1;

 
        #`CLK;
        

        wen = 1;
        din = {16'd12, 16'd8, 16'd1, 16'd5};
        #`CLK;
        wen = 0;


        while (!buffer_ready) begin
            #`CLK;
        end
        wen = 1;
        din = {16'd120, 16'd130, 16'd150, 16'd170};
        #`CLK;
        wen = 0;
    end


    initial begin
        ren = 0;


        #(`CLK * 5);
        

        ren = 1;
        #`CLK;
        ren = 0;
        #`CLK;
        ren = 1;
        #`CLK;
        ren = 0;
        

        #100 $finish;
    end
endmodule
