module ha(input a , b, output s, co);
    wire a_b_sum;
    Xor x1(a,b,a_b_sum);
    And carry (a,b,co);
endmodule