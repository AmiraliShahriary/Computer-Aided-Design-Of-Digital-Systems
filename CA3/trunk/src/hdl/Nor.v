module Nor (
    input wire a,
    input wire b,
    output wire out
);
    c1 nor_inst (
        .A0(1'b1),
        .A1(1'b1),
        .SA(1'b1),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(a),
        .S1(b),
        .f(out)
    );
endmodule


module Or
(
    input a, b,
    output y
);
    c1 or_inst (
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(1'b1),
        .B1(1'b1),
        .SB(1'b1),
        .S0(a),
        .S1(b),
        .f(y)
    );
endmodule

