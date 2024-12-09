module one_bit_reg(input clk , rst,pen , pin , output pout );
    wire out ; 
    s2 cell1(out,out,pin , pin,pen,0,1,0,rst,clk,out);
    assign pout= out ;
endmodule
