`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2025 15:07:26
// Design Name: 
// Module Name: top_controller
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

// First Iteration of Pong
module top_controller(
    input clk,
    input reset,
    input aUp,
    input aDown,
    input bUp,
    input bDown,
    output hSync,
    output vSync,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output [7:0] seg,
    output [3:0] anode,
    output [3:0] inactive 
    );
    
    localparam 
        
        srcHeight = 480,
        srcWidth = 640,
        verPorch = 31,
        horPorch = 144,
        
        ball = 5,
        
        padWidth = 8,
        padHeight = 60,
        padVel = 5,
        aPadX = 40,
        bPadX = 600,
        
        offset = 50;
    
    wire [11:0] color;
    wire toDisplay;
    wire VGA_clk;
    wire hDisp;
    wire EOL;
    wire [10:0] hCount;
    wire vDisp;
    wire EOD;
    wire [10:0]vCount;
    
    wire game_clk;
    wire display;
    reg [12:0] pos [1:0];
    reg [1:0] dir;
    reg [2:0] vel [1:0];
    reg [9:0] paddle [1:0];
    
    reg [3:0] pts [3:0];
    
    initial
    begin
        pos[0] <= 13'd319 + offset;
        pos[1] <= 13'd239 + offset;
        dir <= 2'b0;
        vel[0] <= 3'd2;
        vel[1] <= 3'd2;
        paddle[0] <= 10'd239 + offset;
        paddle[1] <= 10'd239 + offset;
        pts[0] <= 1'b0;
        pts[1] <= 1'b0;
        pts[2] <= 1'b0;
        pts[3] <= 1'b0;
    end
    always@(posedge game_clk)
    begin
        if(reset)
        begin
            pos[0] <= 13'd319 + offset;
            pos[1] <= 13'd239 + offset;
            pts[0] <= 1'b0;
            pts[1] <= 1'b0;
            pts[2] <= 1'b0;
            pts[3] <= 1'b0;
        end
        pos[0] <= (dir[0])? pos[0] - vel[0] : pos[0] + vel[0];
        pos[1] <= (dir[1])? pos[1] - vel[1] : pos[1] + vel[1];
        // logic for the win loose
        //  pos[0] >= srcWidth - 1 + offset - ball
        //  pos[0] <= offset + ball
        //  && ((pos[1] >= paddle[0] - padHeight - ball + offset)&&(pos[1] <= paddle[0] + padHeight + ball + offset))
        if (((pos[0] == bPadX - padWidth - ball + offset)&&(pos[1] >= paddle[1] - padHeight - ball && pos[1] <= paddle[1] + padHeight + ball)))begin
            dir[0] <= 1'b1;
            pos[0] <= pos[0] - vel[0];
        end
        //(pos[1] >= paddle[1] - padHeight - ball + offset)&&(pos[1] <= paddle[1] + padHeight + ball + offset))
        else if(((pos[0] == aPadX + padWidth + ball + offset)&&(pos[1] >= paddle[0] - padHeight - ball && pos[1] <= paddle[0] + padHeight + ball)))begin
            dir[0] <= 1'b0;
            pos[0] <= pos[0] + vel[0];
        end
        else
            dir[0] <= dir[0];
        if(pos[0] >= srcWidth - 1 + offset - ball)
        begin
            // code for if it goes out 
            pos[0] <= 13'd319 + offset;
            pos[1] <= 13'd239 + offset;
            dir[0] <= ~dir[0];
            dir[1] <= ~dir[1];
            pts[1] <= pts[1]+1;
            if(pts[1]== 9)
            begin 
                pts[0] <= pts[0] + 1;
                pts[1] <= 0;
            end
        end
        else if(pos[0] <= offset + ball)
        begin
            //code for if it goes out
            pos[0] <= 13'd319 + offset;
            pos[1] <= 13'd239 + offset;
            dir[0] <= ~dir[0];
            dir[1] <= ~dir[1];
            pts[3] <= pts[3]+1;
            if(pts[3]== 9)
            begin 
                pts[2] <= pts[2] + 1;
                pts[3] <= 0;
            end
            
        end
            
        // logic required to win / loose
        // pos[1] >= srcHeight - 1 + offset - ball //left side
        // pos[1] <= offset + ball //right side
        if(pos[1] >= srcHeight - 1 + offset - ball)begin
            dir[1] <= 1'b1;
            pos[1] <= pos[1] - vel[1];
        end
        else if(pos[1] <= offset + ball)begin
            dir[1] <= 1'b0;
            pos[1] <= pos[1] + vel[1];
        end
        else
            dir[1] <= dir[1];
        
        paddle[0] <= (aUp)? paddle[0] + padVel : (aDown)? paddle[0] - padVel: paddle[0];
        paddle[1] <= (bUp)? paddle[1] + padVel : (bDown)? paddle[1] - padVel: paddle[1];
    end
    
    // all the objects to be displayed on the screen
    wire bBall = ((hCount>pos[0][9:0]+horPorch-ball-offset)&&(hCount<pos[0][9:0]+horPorch+ball-offset))&&((vCount>pos[1][9:0]+verPorch-ball-offset)&&(vCount<pos[1][9:0]+verPorch+ball-offset));
    wire bPaddleA = (hCount>aPadX+horPorch-padWidth)&&(hCount<aPadX+horPorch+padWidth)&&(vCount>paddle[0]+verPorch-padHeight-offset)&&(vCount<paddle[0]+verPorch+padHeight-offset);
    wire bPaddleB = (hCount>bPadX+horPorch-padWidth)&&(hCount<bPadX+horPorch+padWidth)&&(vCount>paddle[1]+verPorch-padHeight-offset)&&(vCount<paddle[1]+verPorch+padHeight-offset);
    
    // if the pointer is inside any of the objects then display a white color
    assign toDisplay = (bBall||bPaddleA||bPaddleB)? 4'b1 : 4'b0;
    assign display = (vDisp&hDisp)? toDisplay : 0;
    
    assign color[11:8] = (bBall || bPaddleA)? {4{1'b1}} : 4'b0; // setting the R color
    assign color[7:4] = (bBall)? {4{1'b1}} : 4'b0; // setting the G color
    assign color[3:0] = (bBall || bPaddleB)? {4{1'b1}} : 4'b0; // setting the B color
    
    assign VGA_R = display? color[11:8] : 4'b0001; 
    assign VGA_G = display? color[7:4] : 4'b0001;
    assign VGA_B = display? color[3:0] : 4'b0001;
    
    // Convert the clk to a 25 MHz clk
    clkStepDown c1 (.clk100(clk), .clk25(VGA_clk));
    gameClk gc (.clk(clk), .gClk(game_clk));
//    wire clks1, clks2, clks3, clks4, clks5, clk6, clk7, clk8, clk9;
//    clkStepDown g1 (.clk100(VGA_clk), .clk25(clks1));
//    clkStepDown g2 (.clk100(clks1), .clk25(clks2));
//    clkStepDown g3 (.clk100(clks2), .clk25(clks3));
//    clkStepDown g4 (.clk100(clks3), .clk25(clks4));
//    clkStepDown g5 (.clk100(clks4), .clk25(clks5));
//    clkStepDown g6 (.clk100(clks5), .clk25(clks6));
//    clkStepDown g7 (.clk100(clks6), .clk25(clks7));
//    clkStepDown g8 (.clk100(clks7), .clk25(clks8));
//    clkStepDown g9 (.clk100(clks8), .clk25(clks9));
//    clkStepDown g10 (.clk100(clks9), .clk25(game_clk));
    segCont segController (.clk(clk), .inp({pts[3], pts[2], pts[1], pts[0]}), .seg(seg), .anode(anode), .inactive(inactive));
    //counter HS 
    hsCounter c2 (.clk(VGA_clk), .hSync(hSync), .hDisp(hDisp), .EOL(EOL), .hCount(hCount));
    
    // counter VS
    vsCounter c3 (.clk(VGA_clk), .EOL(EOL), .vSync(vSync), .vDisp(vDisp), .EOD(EOD), .vCount(vCount));
    
endmodule
