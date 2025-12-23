`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2025 15:07:26
// Design Name: 
// Module Name: clkStepDown
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clkStepDown(
    input clk100,
    output reg clk25
    );
    
    reg counter;
    
    //initial level of the clocks
    initial 
    begin
        counter <= 0;
        clk25 <= 0;
    end
    
    // counter to get a 4 : 1 split
    always@(posedge clk100)
    begin
        counter <= ~counter;
        
        if(counter)
            clk25 <= ~clk25;
        
    end
    
endmodule
