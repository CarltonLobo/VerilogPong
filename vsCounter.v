`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2025 15:07:26
// Design Name: 
// Module Name: vsCounter
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


module vsCounter(
    input clk,
    input EOL,
    output vSync,
    output vDisp,
    output EOD,
    output [10:0] vCount
    );
    
    reg [10:0] Vcount;
    assign vCount = Vcount;
    
    initial
    begin
        Vcount <= 0;
    end
    
    always@(posedge clk)
    begin
        if(EOL)
        begin
            Vcount <= Vcount + 1;
            if(Vcount == 524)
            begin 
                Vcount <= 0;
            end
        end
    end
    
    //assigning an active low sync if the counter is in the sync stage
    assign vSync = (Vcount < 2)? 0 : 1;
    
    // assigning a active high signal if the counter is in the display stage
    assign vDisp = (Vcount > 31)? ((Vcount < 511)? 1:0):0;//check values
    
    // assigning the eolconditions 
    assign EOD  = (Vcount == 524)? 1:0;
    
    
endmodule
