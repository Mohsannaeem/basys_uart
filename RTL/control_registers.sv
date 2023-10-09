module control_registers (
	input 			 clk,    // Clock
	input 			 rst_n,  // Asynchronous reset active low
	input [31:0]    data_in,
	input  		 	 wr_in,
	input [31:0] s_c_dc_in,
	output reg [31:0]  data_out
);
 
 reg       reg_cntl_send;
 reg       reg_cntl_ftxv;
 reg       reg_cntl_rcv;
 reg       reg_cntl_rxav;
 reg [8:0] reg_cntl_rx;
 reg [8:0] reg_cntl_tx;
 always @(*) begin 
		if(~rst_n) begin
			reg_cntl_send <= 0;
			reg_cntl_ftxv <= 0;
			reg_cntl_rcv  <= 0;
			reg_cntl_rxav <= 0;
			reg_cntl_rx   <= 0;
			reg_cntl_tx   <= 0;
		end 
		else begin
			reg_cntl_send <=s_c_dc_in[0];
			reg_cntl_ftxv <=s_c_dc_in[1];
			reg_cntl_rcv <=s_c_dc_in[2];
			reg_cntl_rxav <=s_c_dc_in[3];
			reg_cntl_rx <=s_c_dc_in[16:8]; 
			reg_cntl_tx <=s_c_dc_in[28:20];
			//Setting the Control register when reg_sel_i is zero and wr is enabled 
			if(wr_in)begin
			  reg_cntl_send <=data_in[0];
				// reg_cntl_ftxv <=data_in[1]; //Read-only
				reg_cntl_rcv <=data_in[2];
				// reg_cntl_rxav <=data_in[3];  //Read-only
				// reg_cntl_rx <=data_in[16:8]; //Read-only
				// reg_cntl_tx <=data_in[28:20]; //Read-only
			end	
		end
	end
	//Register Read Logic
	always @(posedge clk or negedge rst_n) begin 
		if(~rst_n) begin
			data_out <= 0;
		end else begin
			data_out <= {3'd0,reg_cntl_tx,4'd0,reg_cntl_rx,4'd0,reg_cntl_rxav,
									reg_cntl_rcv,reg_cntl_ftxv,reg_cntl_send};
		end	
	end



endmodule 