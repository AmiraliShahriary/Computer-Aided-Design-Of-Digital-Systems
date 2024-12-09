module multiplexer #(parameter WIDTH = 8) (input wire [WIDTH-1:0] A,input wire [WIDTH-1:0] B,input wire sel,output wire [WIDTH-1:0] out);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_block
            c1 mux_inst (
                .A0(A[i]),
                .A1(B[i]),
                .SA(sel),
                .B0(1'b1),
                .B1(1'b1),
                .SB(1'b1),
                .S0(1'b0),
                .S1(1'b0),
                .f(out[i])
            );
        end
    endgenerate

endmodule