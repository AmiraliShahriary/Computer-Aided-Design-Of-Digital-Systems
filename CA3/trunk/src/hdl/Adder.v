module adder #(
    parameter WIDTH = 16
) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire cin,
    output wire [WIDTH-1:0] out,
    output wire co
);
    wire [WIDTH:0] carry;
    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_adder
            fa u_adder (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .s(out[i]),
                .co(carry[i+1])
            );
        end
    endgenerate

    assign co = carry[WIDTH];
endmodule
