`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2025 04:18:26 PM
// Design Name: 
// Module Name: Simulator
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


module Simulator();
    reg sclk;
    reg cs;
    reg mosi; 
    wire miso; 
    wire [23:0] data_in_test; 
    wire [7:0] counter_sclk;
    wire latch_data_write;
    wire [7:0] raddr;
    wire start_tranmist;
    
    
    SPI_Slave_24bit_Protocol test(
    .sclk(sclk), 
    .cs(cs), 
    .mosi(mosi), 
    .miso(miso), 
    .data_in_test(data_in_test), 
    .counter_sclk(counter_sclk), 
    .latch_data_write(latch_data_write), 
    .raddr(raddr), 
    .start_tranmist(start_tranmist)
    ); 
    
    initial 
    begin 
    sclk = 0; cs =1;
    #10 cs = 0;
    repeat(25) begin
        #1 sclk = 1;
        #1 sclk = 0;
    end
    #1 cs = 1;
    #1000
    $finish;
    end 
    
    
    initial 
    begin 
    #10 mosi = 1; 
    repeat (12)begin 
        #2 mosi = 0;
        #2 mosi = 1; 
    end 
    
    end 
     
    
    
endmodule
