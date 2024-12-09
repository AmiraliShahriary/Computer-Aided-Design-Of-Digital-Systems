module TB ();
    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    reg [15:0] in1;
    reg [15:0] in2;
    wire [31:0] out;
    wire done;


    initial begin
        in1 = 16'd14335;
        in2 = 16'd7935;
        rst = 1;
        #10 rst = 0;
        #10 start = 1;
        #10 start = 0;
        
        #250 $finish;
    end
    always #5 clk = ~clk;

    TopModule tm (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(in1),
        .B(in2),
        .result(out),
        .done(done)
    );
    

endmodule