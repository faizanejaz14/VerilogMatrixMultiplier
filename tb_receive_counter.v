`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:29:37 11/24/2024
// Design Name:   test_receive_counter
// Module Name:   D:/Study/7th Semester/DSD/MidProject/DSDmidprojectNEW/tb_receive_counter.v
// Project Name:  DSDmidprojectNEW
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: test_receive_counter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_receive_counter;

	// Inputs
	reg clk;
	reg rst;
	reg rx_data;

	// Outputs
	wire [3:0] receive_counter;

	// Instantiate the Unit Under Test (UUT)
	test_receive_counter uut (
		.clk(clk), 
		.rst(rst), 
		.rx_data(rx_data), 
		.receive_counter(receive_counter)
	);

	always #5 clk <= ~clk;

	integer i;
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		rx_data = 1;

		// Wait 100 ns for global reset to finish
		for (i = 0; i < 10; i = i + 1) begin
			#13025;
			rst = 0;
			rx_data = i[0];
      end
		// Add stimulus here
		#6000 $finish;
   end
endmodule
