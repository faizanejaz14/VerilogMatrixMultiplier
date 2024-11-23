`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:00:09 10/11/2024
// Design Name:   top_module
// Module Name:   D:/Study/7th Semester/DSD/Labs/lab5/DSDlab5irtazacode/top_module_tb.v
// Project Name:  DSDlab5irtazacode
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_module
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_module_tb;
//   reg clk, rst, write, read;
//   reg [5:0] write_address, read_address;
//   reg [7:0] write_value;
  
//   wire [7:0] data;
  
//   memory #(.row(3), .column(3)) matrix_A (.clk(clk), .rst(rst), .write(write), .read(read),
//                 .write_address(write_address),
//                 .read_address(read_address),
//                 .write_value(write_value),
//                 .data(data));
  
  reg clk, rst;
  wire complete;
  
  top_module tp (.clk(clk), .rst(rst), .complete(complete));
  
  

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  always #1 clk = ~clk;
  
 integer i;
  initial begin
    clk = 1;
    rst = 1;
    
    #10
    rst = 0;

   #100 $finish;
 end
endmodule
