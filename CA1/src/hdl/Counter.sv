
`timescale 1ps/1ps


module Counter_3bit (
    input clk,           
    input Reset,        
    input Inc,          
    output reg [2:0] count
);

    always @(posedge clk or posedge Reset) begin
        if (Reset) 
            count <= 3'b000;     // Reset counter 
        else if (Inc)
            count <= count + 1;  
    end

endmodule

module Counter_4bit (
    input clk,           
    input Reset,        
    input Inc,          
    output reg [3:0] count
);

    always @(posedge clk or posedge Reset) begin
        if (Reset) 
            count <= 4'b0000;     // Reset counter 
        else if (Inc)
            count <= count + 1;  
    end

endmodule




