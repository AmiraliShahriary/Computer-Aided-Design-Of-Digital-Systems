module Datapath(
    input clk,
    input readMem, loadMem, storeA, shiftA, resetCA, incCA, storeB, shiftB, resetCB, incCB, storeR, shiftR, resetAD, incAD, storeMem, save,
    output aDone, bDone, opDone,
    output caDone , cbDone,
    output [3:0] address,
    output [15:0] regAOut, regBOut, mulOut,
    output [31:0] regROut
);
    wire [15:0] memOut;
    wire [3:0] cntAOut, cntBOut;

    InputRAM inputRAM(
        .clk(clk),
        .load(loadMem), 
        .read(readMem),
        .addr(address),
        .data_out(memOut)
    );

    ShiftRegister_16bit_8bit regA(
        .clk(clk),
        .shift(shiftA),
        .store(storeA),
        .data_in(memOut),
        .shifted(regAOut)
    );

    ShiftRegister_16bit_8bit regB(
        .clk(clk),
        .shift(shiftB),
        .store(storeB),
        .data_in(memOut),
        .shifted(regBOut)
    );

    Counter_4bit cntA(
        .clk(clk),
        .Reset(resetCA),
        .Inc(incCA),
        .count(cntAOut)
    );

    Counter_4bit cntB(
        .clk(clk),
        .Reset(resetCB),
        .Inc(incCB),
        .count(cntBOut)
    );

    Multiplier8x8 multiplier(
        .shifted_A(regAOut[15:8]),
        .shifted_B(regBOut[15:8]),
        .Res(mulOut)
    );

    ShiftRegister_32bit_32bit regR(
        .clk(clk), 
        .store(storeR), 
        .shift(shiftR), 
        .data_in({16'b0, mulOut}), 
        .shifted(regROut)
    );

    Counter_4bit cntAD(
        .clk(clk),
        .Reset(resetAD),
        .Inc(incAD),
        .count(address)
    );

    OutputRAM output_ram(
        .clk(clk),
        .save(save),
        .store(storeMem),
        .addr(address[3:1]),
        .val(regROut)
    );

    // Assign outputs for aDone, bDone, and opDone
    assign caDone = cntAOut[3];
    assign cbDone = cntBOut[3];
    assign aDone = cntAOut[3] | regAOut[15];
    assign bDone = cntBOut[3] | regBOut[15];
    assign opDone = &address;

endmodule
