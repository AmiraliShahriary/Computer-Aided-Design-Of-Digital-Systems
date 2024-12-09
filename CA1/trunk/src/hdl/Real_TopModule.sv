module RealTopModule(
    input clk,
    input start,
    output done
);

    wire [31:0] regROut;
    wire [15:0] regAOut, regBOut, mulOut;
    wire [3:0] address;
    wire aDone, bDone, opDone;
    wire readMem, loadMem, storeA, shiftA, resetCA, incCA, storeB, shiftB, resetCB, incCB, storeR, shiftR, resetAD, incAD, storeMem, save;
    wire caDone , cbDone;
    // Instantiate the Datapath
    Datapath datapath(
        .clk(clk),
        .readMem(readMem), 
        .loadMem(loadMem), 
        .storeA(storeA), 
        .shiftA(shiftA), 
        .resetCA(resetCA), 
        .incCA(incCA), 
        .storeB(storeB), 
        .shiftB(shiftB), 
        .resetCB(resetCB), 
        .incCB(incCB), 
        .storeR(storeR), 
        .shiftR(shiftR), 
        .resetAD(resetAD), 
        .incAD(incAD), 
        .storeMem(storeMem), 
        .save(save), 
        .aDone(aDone), 
        .bDone(bDone), 
        .opDone(opDone),
	.caDone(caDone),
	.cbDone(cbDone),
        .address(address),
        .regAOut(regAOut),
        .regBOut(regBOut),
        .mulOut(mulOut),
        .regROut(regROut)
    );

    // Instantiate the Controller
    Controller controller(
        .clk(clk), 
        .start(start), 
        .aDone(aDone), 
        .bDone(bDone), 
	.caDone(caDone),
	.cbDone(cbDone),
        .opDone(opDone), 
        .readMem(readMem), 
        .loadMem(loadMem), 
        .storeA(storeA), 
        .shiftA(shiftA), 
        .resetCA(resetCA), 
        .incCA(incCA), 
        .storeB(storeB), 
        .shiftB(shiftB), 
        .resetCB(resetCB), 
        .incCB(incCB), 
        .storeR(storeR), 
        .shiftR(shiftR), 
        .resetAD(resetAD), 
        .incAD(incAD), 
        .storeMem(storeMem), 
        .save(save), 
        .done(done)
    );

endmodule

