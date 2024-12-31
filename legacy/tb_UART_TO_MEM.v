`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:58:18 11/24/2024
// Design Name:   UART_to_MEM
// Module Name:   D:/Study/7th Semester/DSD/MidProject/DSDmidprojectNEW/tb_UART_TO_MEM.v
// Project Name:  DSDmidprojectNEW
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UART_to_MEM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_UART_TO_MEM;

	// Inputs
	reg clk;
	reg rst;
	reg ready;
	reg rx_data;

	// Outputs
	wire [7:0] value;

	// Instantiate the Unit Under Test (UUT)
	UART_to_MEM uut (
		.clk(clk), 
		.rst(rst), 
		.ready(ready), 
		.rx_data(rx_data), 
		.value(value)
	);
	
	always #5 clk <= ~clk;
	
	reg [9:0] dataA = 10'b1111101110;
	reg [9:0] dataB = 10'b1001110110;
	reg [9:0] dataC = 10'b1000001110;
	reg [9:0] dataD = 10'b1111100000;	
	
	integer i;
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		ready = 0;
		rx_data = 1;

		// Wait 100 ns for global reset to finish
		
		for (i = 0; i < 10; i = i + 1) begin
			#104200;
			rst = 0;
			rx_data = dataA[i];
      end

		#208400;
		for (i = 0; i < 10; i = i + 1) begin
			#104200;
			rst = 0;
			rx_data = dataB[i];
      end

		#208400;
		for (i = 0; i < 10; i = i + 1) begin
			#104200;
			rst = 0;
			rx_data = dataC[i];
      end

		#208400;
		for (i = 0; i < 10; i = i + 1) begin
			#104200;
			rst = 0;
			rx_data = dataD[i];
      end

		#416400;
		#1_000_000 $finish;

		// Add stimulus here
	end
endmodule

