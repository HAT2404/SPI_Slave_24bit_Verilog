`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/16/2025 11:01:51 AM
// Design Name: 
// Module Name: SPI_Slave_24bit_Protocol
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


module SPI_Slave_24bit_Protocol(
    input sclk, 
    input cs, 
    input mosi, 
    output miso, 
    // phan thuc hien test 
    output reg [23:0] data_in_test,
    output reg [7:0] counter_sclk, 
    output reg latch_data_write, 
    output reg [7:0] raddr,
    output reg start_tranmist
    );
    // define cac thanh ghi can doc ghi 
    reg [15:0] mode_read_write = 16'h0001;   // read: 16'h01     write: 16'h00
    reg [15:0] config_mode = 16'h0000;
    reg [15:0] data_value = 16'h0000;
    
    
    wire RW_Select; 
    assign RW_Select = mode_read_write[0];
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //QUA TRINH PHAN TICH DU LIEU TU MASTER VAO SLAVE TREN BUS MOSI///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    //reg [7:0] counter_sclk;
    
    // Thuc hien su dung cs de reset 
    always @(posedge sclk or posedge cs) begin 
        if(cs) begin counter_sclk <= 25; end
        else begin 
            if(counter_sclk >= 23) begin counter_sclk <= 0; end 
            else begin counter_sclk <= counter_sclk +1; end
        end
    end
    
    // Thuc hien ghep bit de doc data tu master 
    always @(posedge sclk or posedge cs) begin 
        if(cs) begin data_in_test <=0; raddr <= 8'h00; end 
        else begin
            data_in_test <= {data_in_test, mosi};
            if(counter_sclk == 6) begin raddr <= {data_in_test, mosi};  end 
        end 
    end 
    
    
    reg [15:0]data_transmit; 
    reg miso_start; 
    reg miso_flow;
    //reg start_tranmist;
    reg select_miso;
   // Tien hanh xuat du lieu cho master khi slave duoc cau hinh o che do read
   always @(negedge sclk or posedge cs) begin
        if(cs) begin miso_start <=0; data_transmit<=0; start_tranmist <=0; select_miso <=0;  end 
        else begin 
            if(counter_sclk >= 7) begin 
                // qua trinh xuat du lieu cho qua trinh read 
                start_tranmist <=1;
                if(RW_Select) begin 
                    case(raddr) 
                        8'h00:
                            begin 
                                miso_start <= mode_read_write[15];
                                data_transmit <= mode_read_write;
                            end 
                        8'h01:
                            begin 
                                miso_start <= config_mode[15];
                                data_transmit <= config_mode;
                            end 
                        8'h02: 
                            begin 
                                miso_start <= data_value[15];
                                data_transmit <= data_value;
                            end
                     endcase 
                end 
                if(counter_sclk ==8) begin select_miso <=1; end 
            end 
        end
   end 
   
   // FSM Thuc hien qua trinh xuat du lieu cho cac bit du lieu con lai 
   reg[7:0] counter_transmit;
   always @(negedge sclk or posedge cs) begin 
        if(cs) begin miso_flow <=0; counter_transmit <=0; end 
        else begin 
            if(data_transmit) begin
                 if(counter_transmit >=15) begin miso_flow <= miso_flow;   end 
                 else begin 
                    counter_transmit <= counter_transmit+1; 
                    miso_flow <= data_transmit[14-counter_transmit];
                 end
            end 
        end 
   end
   
   assign miso = (select_miso) ? miso_flow : miso_start;
   
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //QUA TRINH WRITE DU LIEU TU MASTER VAO SLAVE///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   // thoi diem chot du lieu vao thanh ghi 
   //reg latch_data_write;
   always @(negedge sclk or posedge cs) begin 
        if(cs) begin latch_data_write <=0;end
        else begin 
            // qua trinh chot du lieu master write xuong register 
            if(counter_sclk == 23 && data_in_test[23:16] == 8'h00) begin 
                latch_data_write <=1;
            end 
            else begin 
                if(!RW_Select) begin 
                    if(counter_sclk == 23) begin latch_data_write <=1; end 
                    else begin latch_data_write <=0; end 
                end
            end
            
        end 
   end 
   
   // thuc hien cho du lieu write theo dia chi 
   always @(posedge latch_data_write) begin 
        case(data_in_test[23:16])
            8'h00: mode_read_write <= data_in_test[15:0];
            8'h01: config_mode <= data_in_test[15:0];
            8'h02: data_value <= data_in_test[15:0];
            default:
                begin 
                    mode_read_write <= mode_read_write; 
                    config_mode <= config_mode;
                    data_value <= data_value;
                end 
        endcase
   end 
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    
endmodule
