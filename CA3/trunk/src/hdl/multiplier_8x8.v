module mult_8x8(
    input [7:0] A, B,
    output [15:0] out
);
    wire [9:0] P0, P1, P2, P3;
    wire [15:0] shifted_P1, shifted_P2, shifted_P3;
    wire [15:0] sum1, sum2;


    wire [4:0] A_high = {1'b0 ,A[7:4]}, A_low = {1'b0 ,A[3:0]};
    wire [4:0] B_high = {1'b0 ,B[7:4]}, B_low = {1'b0 ,B[3:0]};


    mult_4x4 mul0 (.D1(A_low),  .D2(B_low),  .out(P0)); // A_low * B_low
    mult_4x4 mul1 (.D1(A_high), .D2(B_low),  .out(P1)); // A_high * B_low
    mult_4x4 mul2 (.D1(A_low),  .D2(B_high), .out(P2)); // A_low * B_high
    mult_4x4 mul3 (.D1(A_high), .D2(B_high), .out(P3)); // A_high * B_high

    assign shifted_P1 = {P1, 4'b0};  // Multiply by 2^4
    assign shifted_P2 = {P2, 4'b0};  // Multiply by 2^4
    assign shifted_P3 = {P3, 8'b0};  // Multiply by 2^8

    assign out  = shifted_P1 + shifted_P2 + shifted_P3 + P0;

endmodule