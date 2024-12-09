`timescale 1ps/1ps


module TB();
	reg clk, start;
	wire done;
	
	RealTopModule toptop(clk, start, done);
	
	initial begin
		clk = 1'b0;
		start = 1'b1;
		#10 start = 1'b0;
		#50000 $finish;
	end
	always begin
		#20 clk = ~clk;
	end
endmodule
