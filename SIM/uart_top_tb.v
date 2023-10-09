`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2023 07:13:14 AM
// Design Name: 
// Module Name: uart_top_tb
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
`timescale 1ns / 1ps

module uart_top_tb;
    // Inputs
    reg Clk;
    reg Rst_n;
    wire Rx;
    reg reg_sel_i;
    reg wr_i;
    reg [31:0] data_i;

    // Outputs
    wire Tx;
    wire [31:0] data_o;

    // Instantiate the uart_top module
    uart_top uart_top_inst (
        .Clk(Clk),
        .Rst_n(Rst_n),
        .Rx(Rx),
        .Tx(Tx),
        .reg_sel_i(reg_sel_i),
        .wr_i(wr_i),
        .data_i(data_i),
        .data_o(data_o)
    );

    wire            tick        ; // Baud rate clock
   wire [15:0]     BaudRate    ; //328; 162 etc... (Read comment in baud rate generator file)
   wire [3:0]      NBits       ;
   wire            RxDone      ;
   wire            TxDone      ;
   reg  [3:0]      reg_in_d    ;
   wire  [7:0]      rx_data,tx_data;
   assign BaudRate = 16'd2;  //baud rate set to 9600 for the HC-06 bluetooth module. Why 325? (Read comment in baud rate generator file)
   assign NBits    = 4'b1000;  //We send/receive 8 bits
   
// Make connections between Rx module and TOP inputs and outputs and the other modules
   UART_rx RX1(
    .Clk(Clk)               ,
    .Rst_n(Rst_n)           ,
    .RxEn(data_o[0])        ,
    .RxData(rx_data)        ,
    .RxDone(RxDone)         ,
    .Rx(Tx)                 ,
    .Tick(tick)             ,
    .NBits(NBits)
   );
//Make connections between Tx module and TOP inputs and outputs and the other modules
   UART_tx TX1(
    .Clk(Clk)               ,
    .Rst_n(Rst_n)           ,
    .TxEn(1'd1)        ,
    .TxData(tx_data)        ,
    .TxDone(TxDone)         ,
    .Tx(Rx)                 ,
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
   
    // Clock generation
    always begin
        #5; // Assuming a 200MHz clock, adjust the delay accordingly
        Clk = ~Clk;
    end

    // Initialize inputs
    initial begin
        Clk = 0;
        Rst_n = 0;
        reg_sel_i = 0;
        wr_i = 0;
        data_i = 32'h00000000;

        // Reset the uart_top module
        #100;
        Rst_n = 1;

        // Set reg_sel_i and wr_i to write data
        //Writing the Data Register from External Agent 
        reg_sel_i = 1;
        wr_i = 1;
        // Send data
        data_i = 32'hA5A5A5A5; // Example data
        repeat (10) @(posedge Clk);
        wr_i = 0;
        repeat (1)@(posedge Clk);
        // Set reg_sel_i to read data
        reg_sel_i = 0;
        wr_i = 1;
        data_i = 32'h1;
        repeat (1)@(posedge Clk);
        wr_i = 0;
        data_i = 32'h0;
        
        // Wait for UART to receive data
        repeat (1000) @(posedge Clk);

        // End simulation

        $finish;
    end
endmodule
