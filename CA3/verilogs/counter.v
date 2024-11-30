module counter #(parameter SIZE = 10) (
    input clk,  
    input rst,  
    input inc,  
    output [SIZE-1:0] count,
    output co
);
    wire [SIZE-1:0] current_value; 
    wire [SIZE-1:0] incremented_value;
    wire [SIZE:0] carry;

    assign carry[0] = 1'b1;

    genvar i;
    generate
        for (i = 0; i < SIZE; i = i + 1) begin : increment_logic
            fa adder(
                .a(current_value[i]),
                .b(1'b0),
                .cin(carry[i]),
                .s(incremented_value[i]),
                .co(carry[i+1])
            );
        end
    endgenerate

    n_bit_reg #(.SIZE(SIZE)) register(
        .clk(clk),
        .rst(rst),
        .pen(inc),
        .pin(incremented_value),
        .pout(current_value)
    );

    assign count = current_value;
    assign co = carry[SIZE];
endmodule
