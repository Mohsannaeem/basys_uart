`timescale 1ns / 1ps

module tb_uart_top;

    // Inputs
    reg Clk;
    reg Rst_n;
    reg Rx;

    // Outputs
    wire Tx;
    wire [7:0] RxData;
    wire [7:0] led;
  	bit [7:0] AsciiArray [4:0]; // Array to hold ASCII values of characters
    // Baud rate generator parameters
    parameter BAUD_RATE = 9600; // Adjust the baud rate as needed

    // Baud rate generator counter
    reg [15:0] BaudRateCounter;

    // Baud rate generator logic
    always @(posedge Clk) begin
        if (Rst_n == 0) begin
            BaudRateCounter <= 16'h0000; // Reset counter
        end else begin
            if (BaudRateCounter == (16'b0)) begin
                BaudRateCounter <= (50000000 / BAUD_RATE) - 1; // Adjust for your clock frequency
            end else begin
                BaudRateCounter <= BaudRateCounter - 1;
            end
        end
    end
    // Instantiate the uart_top module
    uart_top uart_top_inst (
        .Clk(Clk),
        .Rst_n(Rst_n),
        .Rx(Rx),
        .Tx(Tx),
        .RxData(RxData),
        .led(led)
    );

    // Clock generation
    always begin
        #5; // Assuming a 200MHz clock, adjust the delay accordingly
        Clk = ~Clk;
    end

    // Initialize inputs and variables
    initial begin
        Clk = 0;
        Rst_n = 0;
        Rx = 0;
        #50;
        // Reset the uart_top module
        Rst_n = 1;
        
        // ASCII values of characters "Hello"
        AsciiArray[0] = 8'h48; // 'H' in ASCII (72 in decimal)
        AsciiArray[1] = 8'h65; // 'e' in ASCII (101 in decimal)
        AsciiArray[2] = 8'h6C; // 'l' in ASCII (108 in decimal)
        AsciiArray[3] = 8'h6C; // 'l' in ASCII (108 in decimal)
        AsciiArray[4] = 8'h6F; // 'o' in ASCII (111 in decimal)
			
	  // Start sending characters from the array
      foreach(AsciiArray[ArrayIndex]) begin
        	repeat (BAUD_RATE) @(posedge Clk);
        	// Wait for baud rate interval
            Rx = 0;
        foreach(AsciiArray[ArrayIndex][Character]) begin  
          // Wait for half of the baud rate interval
          repeat (BAUD_RATE) @(posedge Clk);	
          Rx = AsciiArray[ArrayIndex][Character];	
        end
        $display(" Index: %d", ArrayIndex);
        end

        // End simulation
        $finish;
    end
	initial begin 
    	$dumpfile("uart_simulation.vcd"); // Specify VCD file
        $dumpvars(0, tb_uart_top); // Dump all signals
    end
endmodule
