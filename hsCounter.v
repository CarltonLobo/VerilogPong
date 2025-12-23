`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2025 15:07:26
// Design Name: 
// Module Name: hsCounter
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


module hsCounter(
    input clk,
    output hSync,
    output hDisp,
    output EOL,
    output [10:0] hCount
    );
    
    reg [10:0] Hcount;
    assign hCount = Hcount;
    
    initial
    begin
        Hcount <= 0;
    end
    
    always@(posedge clk)
    begin
        Hcount <= Hcount + 1;
        if(Hcount == 799)
        begin 
            Hcount <= 0;
        end
    end
    
    //assigning an active low sync if the counter is in the sync stage
    assign hSync = (Hcount < 96)? 0 : 1;
    
    // assigning a active high signal if the counter is in the display stage
    assign hDisp = (Hcount > 144)? ((Hcount < 784)? 1:0):0;//check values
    
    // assigning the eolconditions 
    assign EOL  = (Hcount == 799)? 1:0;
    
endmodule
