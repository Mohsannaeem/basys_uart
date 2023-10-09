`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2023 02:35:22 AM
// Design Name: 
// Module Name: uart_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:
module uart_control(
    input        Clk,
    input        Rst_n,
    input [31:0] reg_in,
    input [10:0] fifo_tx_status,
    input [10:0] fifo_rx_status,
    input [7:0]  tx_data,
    output[7:0]  rx_data,
    output       tx_fifo_rd,
    output       rx_fifo_rd,
    output       rx_fifo_wr,
    output reg [31:0] s_d_dc,
    input        Rx,
    output       Tx
       
); 
   wire            tick        ; // Baud rate clock
   wire [15:0]     BaudRate    ; //328; 162 etc... (Read comment in baud rate generator file)
   wire [3:0]      NBits       ;
   wire            RxDone      ;
   wire            TxDone      ;
   reg  [3:0]      reg_in_d    ;
   
   assign BaudRate = 16'd2;  //baud rate set to 9600 for the HC-06 bluetooth module. Why 325? (Read comment in baud rate generator file)
   assign NBits    = 4'b1000;  //We send/receive 8 bits
   
// Make connections between Rx module and TOP inputs and outputs and the other modules
   UART_rx RX(
    .Clk(Clk)               ,
    .Rst_n(Rst_n)           ,
    .RxEn(reg_in[2])        ,
    .RxData(rx_data)        ,
    .RxDone(RxDone)         ,
    .Rx(Rx)                 ,
    .Tick(tick)             ,
    .NBits(NBits)
   );
//Make connections between Tx module and TOP inputs and outputs and the other modules
   UART_tx TX(
    .Clk(Clk)               ,
    .Rst_n(Rst_n)           ,
    .TxEn(reg_in[0])        ,
    .TxData(tx_data)        ,
    .TxDone(TxDone)         ,
    .Tx(Tx)                 ,
    .Tick(tick)             ,
    .NBits(NBits)
    );
//Make connections between tick generator module and TOP inputs and outputs and the other modules
   UART_BaudRate_generator I_BAUDGEN(
    .Clk(Clk)               ,
    .Rst_n(Rst_n)           ,
    .Tick(tick)             ,
    .BaudRate(BaudRate)
    );
    always @(*) begin 
      s_d_dc[0]     <= reg_in[0] & ~TxDone; //Send 
      s_d_dc[1]     <= fifo_tx_status[0];  // TX Fifo Full
      s_d_dc[2]     <= reg_in[2] & ~RxDone; //Recieve
      s_d_dc[3]     <= ~fifo_rx_status[1];  //RX FiFO Empty
      s_d_dc[7:4]   <= 4'h0; //Reserved
      s_d_dc[16:8]  <= fifo_rx_status[10:2]; //TX Byte Available
      s_d_dc[19:17] <= 3'h0;
      s_d_dc[28:20] <= fifo_tx_status[10:2]; //Rx Byte Avaiable 
      s_d_dc[31:29] <= 3'h0;
    end 
    always @(posedge Clk or negedge Rst_n) begin
        if(~Rst_n) begin 
         reg_in_d <= 4'h0; 
        end
        else begin 
         reg_in_d <= reg_in[3:0];
        end
    end
    assign tx_fifo_rd = reg_in[0] & ~reg_in_d[0] & ~fifo_tx_status[1] ;  //Pulse Generator and Fifo is not empty
    assign rx_fifo_rd = reg_in[2] & ~reg_in_d[2] & fifo_rx_status[1] ; //Pulse Generator and FIFO is not empty 
    assign rx_fifo_wr = ~fifo_rx_status[0] && RxDone; //RX FiFo is not full so it read 
endmodule
