module NAnd(input a , b , output out );
	wire temp;
	And an(a , b , temp);
	inverter n(temp, out);
endmodule