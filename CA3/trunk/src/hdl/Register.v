

module n_bit_reg #(parameter SIZE = 10 )(
    input clk , rst , pen ,
    input [SIZE-1 : 0 ] pin, 
    output [SIZE-1  : 0] pout
    );
    genvar i; 
    generate
    for (i = 0 ; i<SIZE ; i = i + 1 ) begin : one_bit_reg
        one_bit_reg single_bit_reg(clk,rst,pen,pin[i],pout[i]);
    end
    endgenerate
endmodule