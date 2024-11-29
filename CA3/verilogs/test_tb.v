`timescale 1ns / 1ps

// module mult_tbbb;

//     // Inputs
//     reg [7:0] D1;
//     reg [7:0] D2;

//     // Output
//     wire [15:0] out;

//     // Instantiate the Unit Under Test (UUT)
//     mult_8x8 uut (
//         .A(D1),
//         .B(D2),
//         .out(out)
//     );

//     initial begin
//         // Test Case 1
//         D1 = 8'b00011111; // 3
//         D2 = 8'b00010010; // 2 
//         #200;
//         $display("Test Case 1: D1=%b, D2=%b, out=%b", D1, D2, out);


//     end

// endmodule


module tb_counter;
    reg clk, rst, inc;
    wire [9:0] count;

    // Instantiate the counter
    counter #(.SIZE(5)) uut (
        .clk(clk),
        .rst(rst),
        .inc(inc),
        .count(count)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        inc = 0;

        // Reset the counter
        #10 rst = 0;
        inc = 1;

        // Run for a few cycles
        #100 $finish;
    end

    initial begin
        $monitor("Time=%0t, Count=%b", $time, count);
    end
endmodule
