`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:13:40 12/13/2024
// Design Name:   newMEM_to_TX
// Module Name:   D:/Study/7th Semester/DSD/MidProject/DSDmidprojectNEW/tb_newMEM_to_TX.v
// Project Name:  DSDmidprojectNEW
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: newMEM_to_TX
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_newMEM_to_TX;

	// Inputs
	reg clk;
	reg rst;
	reg read_R_mat;

	// Outputs
	wire [4:0] state_LED;
	wire [2:0] values_sent_count;
	wire tx_data;
	wire tx_status;

	// Instantiate the Unit Under Test (UUT)
	newMEM_to_TX uut (
		.clk(clk), 
		.rst(rst), 
		.read_R_mat(read_R_mat), 
		.state_LED(state_LED), 
		.values_sent_count(values_sent_count), 
		.tx_data(tx_data), 
		.tx_status(tx_status)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		read_R_mat = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;
      read_R_mat = 1;
		
		#5_500_000 read_R_mat = 0;
		// Add stimulus here
		
		#5_000_000 read_R_mat = 1;
		#5_000_000 read_R_mat = 0;
		
		#15_000_000;
		#10_000_000 $finish;
	end
      
endmodule

