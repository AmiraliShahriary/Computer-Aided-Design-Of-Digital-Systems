// module shift_register #(parameter SIZE = 10) (
//     input clk,
//     input rst,
//     input [1:0] shift_mode,   // Shift mode: 00 = No shift, 01 = Left, 10 = Right, 11 = Parallel load
//     input [SIZE-1:0] pin,
//     output [SIZE-1:0] pout
// );
//     wire [SIZE-1:0] shifted_value;


//     assign shifted_value = (shift_mode == 2'b01) ? {pout[SIZE-2:0], 1'b0} :
//                            (shift_mode == 2'b10) ? {1'b0, pout[SIZE-1:1]} : 
//                            pin;

 
//     n_bit_reg #(.SIZE(SIZE)) register (
//         .clk(clk),
//         .rst(rst),
//         .pen(shift_mode != 2'b00),
//         .pin(shifted_value),
//         .pout(pout)
//     );

// endmodule


// ------------------------------
// module ShiftRegister #(
//     parameter WIDTH = 10  // Default size of the shift register
// ) (
//     input clk,
//     input rst,
//     input load,
//     input shift_en,
//     input [WIDTH - 1:0] in,
//     input in_sh,
//     output [WIDTH - 1:0] out
// );

//     wire [WIDTH - 1:0] data;
//     genvar i;

//     generate
//         for (i = 0; i < WIDTH; i = i + 1) begin : shift_block
//             // Logic for selecting input to the S2 module:
//             // - `in[i]` is selected when `load` is enabled.
//             // - `data[i-1]` is selected when `shift_en` is enabled (for left shift).
//             // - `data[i]` is selected for no shift.
//             wire [3:0] D;
//             assign D = {
//                 in[i],                                // Parallel load
//                 (i == 0) ? in_sh : data[i-1],        // Left shift
//                 1'b0,                                // Unused for this mode
//                 data[i]                              // No shift
//             };

//             s2 reg_inst (
//                 .A0(shift_en),
//                 .B0(shift_en),
//                 .A1(load),
//                 .B1(load),
//                 .D(D),
//                 .CLR(rst),
//                 .clk(clk),
//                 .out(data[i])
//             );
//         end
//     endgenerate

//     assign out = data;

// endmodule


//-------------------------------------

// module shift_register #(parameter SIZE = 10) (
//     input clk,
//     input rst,
//     input [1:0] shift_mode,   // Shift mode: 00 = No shift, 01 = Left, 10 = Right, 11 = Parallel load
//     input [SIZE-1:0] pin,
//     output [SIZE-1:0] pout
// );

//     wire [SIZE-1:0] data;
//     genvar i;

//     generate
//         for (i = 0; i < SIZE; i = i + 1) begin : shift_block
//             // Logic for selecting input to the S2 module:
//             // - pin[i] is selected for parallel load (shift_mode == 11)
//             // - data[i-1] is selected for left shift (shift_mode == 01)
//             // - data[i+1] is selected for right shift (shift_mode == 10)
//             // - data[i] is selected for no shift (shift_mode == 00)
//             wire [3:0] D;
//             assign D = {
//                 pin[i],                                  // Parallel load
//                 (i == 0) ? 1'b0 : data[i-1],            // Left shift
//                 (i == SIZE-1) ? 1'b0 : data[i+1],       // Right shift
//                 data[i]                                 // No shift
//             };

//             S2 reg_inst (
//                 .A0(shift_mode[0]),
//                 .B0(shift_mode[0]),
//                 .A1(shift_mode[1]),
//                 .B1(shift_mode[1]),
//                 .D(D),
//                 .clr(rst),
//                 .clk(clk),
//                 .out(data[i])
//             );
//         end
//     endgenerate

//     assign pout = data;

// endmodule


module ShiftRegister #(
    parameter WIDTH = 16
)  (
    input clk,
    input rst,
    input load,
    input shift_en,
    input [WIDTH - 1:0] in,
    input in_sh,
    output [WIDTH - 1:0] out
);

wire [WIDTH - 1:0] data;
genvar i;

generate
    for (i = 0; i < WIDTH; i = i + 1) begin : register_block
        s2 reg_inst (
            .A0(shift_en),
            .B0(shift_en),
            .A1(load),
            .B1(load),
            .D11(in[i]), 
            .D10(in[i]), 
            .D01((i == 0) ? in_sh : data[i-1]), 
            .D00(data[i]),
            .clk(clk),
            .clr(rst),
            .out(data[i])
        );
    end
endgenerate

assign out = data;

endmodule
