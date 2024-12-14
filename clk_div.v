`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:55:49 11/04/2024 
// Design Name: 
// Module Name:    clk_div 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clk_div(input clk, 
					output reg slow_clk); 
	reg [26:0] counter = 0; 
	parameter DIV = 1; 
	//parameter DIV = 100; 
	parameter cycles = 100_000_000/DIV; 
	always @ (posedge clk) begin 
		counter <= (counter < cycles - 1) ? counter + 27'b1 : 27'b0; 
		slow_clk <= (counter < cycles/2) ? 1'b1 : 1'b0; 
	end 
endmodule
