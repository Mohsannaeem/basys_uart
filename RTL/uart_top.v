module uart_top(
    input           Clk     ,  // Clock
    input           Rst_n   ,  // Reset
    input           Rx      ,  // UArt RX line.
    output          Tx      ,  // Uart TX line.
    input           reg_sel_i, // Agent Write Sel/address
    input           wr_i     , // Agent Write enable     
    input  [31:0]   data_i   , // Agent Write Data
    output reg[31:0] data_o   // Agent Read Data
    );
    // Data to transmit.
    wire [7:0]  RxData1;
    wire [7:0]  TxData;
    reg         cntr_wr_in;
    wire [31:0] s_c_dc_in;
    wire [31:0] cntr_data_out;
    reg         fifo_wr_in;
    wire        fifo_tx_rd_en;
    wire        fifo_rx_wr_en;
    wire        fifo_rx_rd_en;
    wire [10:0] fifo_tx_status;
    wire [10:0] fifo_rx_status;
    wire [7:0]  fifo_rx_out;
   // Write Enable DEMUX Implementation 
   always @(*) begin 
    if(reg_sel_i ==0) 
       data_o <= cntr_data_out ;  // Write Data out from Contol registers file
    else
        data_o <= {24'd0,fifo_rx_out};
       
   end
// Read Data Mux Implementation
   always@(*)begin 
    if(reg_sel_i ==0)
        cntr_wr_in <= wr_i;
    else 
        fifo_wr_in <= wr_i;    
   end 
//Control Register Declaration
control_registers i_control_registers (
  .clk      (Clk        ),
  .rst_n    (Rst_n      ),
  .data_in  (data_i    ),
  .wr_in    (cntr_wr_in ),
  .s_c_dc_in(s_c_dc_in  ),
  .data_out (cntr_data_out )
);
//TX FiFo Instansiations
fifo_generator_0 fifo_tx(
  .clk(Clk),                // input wire clk
  .din(data_i[7:0]),                // input wire [7 : 0] din
  .wr_en(fifo_wr_in),            // input wire wr_en
  .rd_en(fifo_tx_rd_en),            // input wire rd_en
  .dout(TxData),              // output wire [7 : 0] dout
  .full(fifo_tx_status[0]),              // output wire full
  .empty(fifo_tx_status[1]),            // output wire empty
  .data_count(fifo_tx_status[10:2])  // output wire [8 : 0] data_count
);
//RX FIFO Instansiations
fifo_generator_0 fifo_rx(
  .clk(Clk),                // input wire clk
  .din(RxData1),                // input wire [7 : 0] din
  .wr_en(fifo_rx_wr_en),            // input wire wr_en
  .rd_en(fifo_rx_rd_en),            // input wire rd_en
  .dout(fifo_rx_out),              // output wire [7 : 0] dout
  .full(fifo_rx_status[0]),              // output wire full
  .empty(fifo_rx_status[1]),            // output wire empty
  .data_count(fifo_rx_status[10:2])  // output wire [8 : 0] data_count
);
//UART Interface Control Instansiations
uart_control uart_cntl(
    .Clk(Clk),
    .Rst_n(Rst_n),
    .reg_in(cntr_data_out),
    .fifo_tx_status(fifo_tx_status),
    .fifo_rx_status(fifo_rx_status),
    .tx_data(TxData),
    .rx_data(RxData1),
    .tx_fifo_rd(fifo_tx_rd_en),
    .rx_fifo_rd(fifo_rx_rd_en),
    .rx_fifo_wr(fifo_rx_wr_en),
    .s_d_dc(s_c_dc_in),
    .Rx(Rx),
    .Tx(Tx)
);

endmodule
