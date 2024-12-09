`timescale 1ps/1ps
`define IDLE     5'b00000
`define INIT     5'b00001
`define READA    5'b00010
`define STOREA   5'b00011
`define CHECKA   5'b00100
`define SHIFTA   5'b00101
`define READB    5'b00110
`define STOREB   5'b00111
`define CHECKB   5'b01000
`define SHIFTB   5'b01001
`define STORER   5'b01010
`define CHECKCA  5'b01011
`define SHIFTCA  5'b01100
`define CHECKCB  5'b01101
`define SHIFTCB  5'b01110
`define STOREMEM 5'b01111
`define SAVE     5'b10000
`define DONE     5'b10001

module Controller(clk, start, aDone, bDone, caDone, cbDone, opDone, readMem, loadMem, storeA, shiftA, resetCA, incCA, storeB, shiftB, resetCB, incCB, storeR, shiftR, resetAD, incAD, storeMem, save, done);
	input clk, start, aDone, bDone, caDone, cbDone, opDone;
	output readMem, loadMem, storeA, shiftA, resetCA, incCA, storeB, shiftB, resetCB, incCB, storeR, shiftR, resetAD, incAD, storeMem, save, done;

	reg readMem, loadMem, storeA, shiftA, resetCA, incCA, storeB, shiftB, resetCB, incCB, storeR, shiftR, resetAD, incAD, storeMem, save, done;
	reg [4:0] ps, ns;
	
	initial begin
		ps = `IDLE;
	end

	always @(posedge clk)begin
		ps <= ns;
	end

	always @(ps or aDone or bDone or caDone or cbDone or opDone) begin
		case(ps)
			`IDLE:     ns = start ? `INIT : `IDLE;
			`INIT:     ns = `READA;
			`READA:    ns = `STOREA;
			`STOREA:   ns = `CHECKA;
			`CHECKA:   ns = aDone ? `READB : `SHIFTA;
			`SHIFTA:   ns = `CHECKA;
			`READB:    ns = `STOREB;
			`STOREB:   ns = `CHECKB;
			`CHECKB:   ns = bDone ? `STORER : `SHIFTB;
			`SHIFTB:   ns = `CHECKB;
			`STORER:   ns = `CHECKCA;
			`CHECKCA:  ns = caDone ? `CHECKCB : `SHIFTCA;
			`SHIFTCA:  ns = `CHECKCA;
			`CHECKCB:  ns = cbDone ? `STOREMEM : `SHIFTCB;
			`SHIFTCB:  ns = `CHECKCB;
			`STOREMEM: ns = opDone ? `SAVE : `READA;
			`SAVE:     ns = `DONE;
			`DONE:     ns = `IDLE;
		endcase
	end
	
	always @(ps) begin
		{readMem, loadMem, storeA, shiftA, resetCA, incCA, storeB, shiftB, resetCB, incCB, storeR, shiftR, resetAD, incAD, storeMem, save, done} = 17'b0;
		case(ps)
			`INIT:     {resetCA, resetCB, resetAD, loadMem} = 4'b1111;
			`READA:    {readMem, incAD} = 2'b11;
			`STOREA:   storeA = 1;
			`SHIFTA:   {shiftA, incCA} = 2'b11;
			`READB:    readMem = 2'b11;
			`STOREB:   storeB = 1;
			`SHIFTB:   {shiftB, incCB} = 2'b11;
			`STORER:   storeR = 1;
			`SHIFTCA:  {shiftR, incCA} = 2'b11;
			`SHIFTCB:  {shiftR, incCB} = 2'b11;
			`STOREMEM: {storeMem, incAD, resetCA, resetCB} = 4'b1111;
			`SAVE:     save = 1;
			`DONE:     done = 1;
		endcase
	end
endmodule
