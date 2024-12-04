`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:20:26 11/25/2024
// Design Name:   MEM_to_TX
// Module Name:   D:/Study/7th Semester/DSD/MidProject/DSDmidprojectNEW/tb_MEM_to_TX.v
// Project Name:  DSDmidprojectNEW
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MEM_to_TX
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_MEM_to_TX;

	// Inputs
	reg clk;
	reg rst;
	reg read_R_mat;

	// Outputs
	wire tx_data;

	// Instantiate the Unit Under Test (UUT)
	MEM_to_TX uut (
		.clk(clk), 
		.rst(rst), 
		.read_R_mat(read_R_mat), 
		.tx_data(tx_data)
	);

	always #5 clk <= ~clk;
	
	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		read_R_mat = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;
      read_R_mat = 1;
		
		//#5_500_000 read_R_mat = 0;
		// Add stimulus here
		
		//#5_000_000 read_R_mat = 1;
		//#5_000_000 read_R_mat = 0;
		
		#15_000_000;
		#10_000_000 $finish;
	end
      
endmodule

