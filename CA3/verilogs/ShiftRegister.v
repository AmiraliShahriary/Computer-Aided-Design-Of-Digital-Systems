module shift_register #(parameter SIZE = 10) (
    input clk,
    input rst,
    input [1:0] shift_mode,   // Shift mode: 00 = No shift, 01 = Left, 10 = Right, 11 = Parallel load
    input [SIZE-1:0] pin,
    output [SIZE-1:0] pout
);
    wire [SIZE-1:0] shifted_value;


    assign shifted_value = (shift_mode == 2'b01) ? {pout[SIZE-2:0], 1'b0} :
                           (shift_mode == 2'b10) ? {1'b0, pout[SIZE-1:1]} : 
                           pin;

 
    n_bit_reg #(.SIZE(SIZE)) register (
        .clk(clk),
        .rst(rst),
        .pen(shift_mode != 2'b00),
        .pin(shifted_value),
        .pout(pout)
    );

endmodule
