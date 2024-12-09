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



module Counter_dual #(
    parameter WIDTH = 4
) (
    input clk,
    input rst,
    input en1,
    input en2,
    input en_d,
    input [WIDTH-1:0] init,
    output co
);
    wire [WIDTH-1:0] adder_out;
    wire [WIDTH-1:0] out;
    wire co_add;
    
    wire temp;
    
    c1 c1_inst_en1 (
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(1'b1),
        .B1(1'b1),
        .SB(1'b1),  
        .S0(en_d),
        .S1(en1),
        .f(temp)
    );

    adder #(
        .WIDTH(WIDTH)
    ) adder_inst_1( .a(out), .b({3'b0, temp}), .cin(en2), .out(adder_out), .co(co_add) );

    ShiftRegister #(
        .WIDTH(WIDTH)
    ) sr_inst (
        .clk(clk),
        .rst(rst),
        .load(1'b1),
        .shift_en(1'b0),
        .in(adder_out),
        .in_sh(1'b0),
        .out(out)
    );

    // assign co = &out;
    c2 co_calc(
        .A0(out[0]),
        .B0(out[1]),
        .A1(out[2]),
        .B1(out[2]),
        .D11(out[3]), 
        .D10(1'b0),
        .D01(1'b0),
        .D00(1'b0),
        .out(co)
    );
endmodule


