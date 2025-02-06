module Mux2to1(a, b, sel, c);
  parameter WIDTH = 4;
  input [WIDTH-1:0] a, b;
  input sel;
  output reg [WIDTH-1:0] c;  // Output declared as reg for procedural assignment

  always @(*) begin
    if (sel) 
      c = b;
    else 
      c = a;
  end
endmodule
