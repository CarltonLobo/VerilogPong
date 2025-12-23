`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.08.2025 15:43:38
// Design Name: 
// Module Name: gameClk
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


module gameClk(
    input clk,
    output reg gClk
    );
    reg [22:0] counter;
    
    initial 
    begin
        gClk <= 0;
    end
    
    always@(posedge clk)
    begin
        counter <= counter + 1;
        if(counter == 23'd999999)
        begin
            counter <= 23'b0;
            gClk <= ~gClk;
        end
    end
endmodule
