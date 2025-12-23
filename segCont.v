`timescale 1ns / 1ps

module segCont(
    input clk,
    input [15:0] inp,
    output wire [7:0] seg,
    output wire [3:0] anode,
    output wire [3:0] inactive
    );
    
    wire [3:0] bcdDigit [3:0];
    assign {bcdDigit[0], bcdDigit[1], bcdDigit[2], bcdDigit[3] }= inp;
    
    wire divclk;
    assign inactive=4'b1111;
    clockdivider khz10(
        .clk(clk),
        .divclk(divclk)
    );
    
    wire [1:0] refreshcount;
    refreshcounter refreshcountbox(
        .refresh_clk(divclk),
        .refreshcounter(refreshcount)
    );
    andctrl anodecontrol(
        .refreshcounter(refreshcount),
        .anode(anode)
    );
    
    wire [3:0] bcd;
    bcdctrl bcdctrl(
        refreshcount,
        bcdDigit[0],
        bcdDigit[1],
        bcdDigit[2],
        bcdDigit[3],
        bcd
    );
    bcdtocathode bcdcathodeconvert(
        bcd,
        seg
    );
endmodule