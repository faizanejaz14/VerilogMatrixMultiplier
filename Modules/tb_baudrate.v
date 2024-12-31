`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:59:41 10/26/2024
// Design Name:   top_module
// Module Name:   D:/Study/7th Semester/DSD/Labs/lab7/DSDlab7Irtaza/tb_baudrate.v
// Project Name:  DSDlab7Irtaza
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

module tb_baudrate();
  reg clk, rst, ready;
  reg [7:0] data;
  
  wire tx_status, tx_data, rx_status;
  wire [9:0] rx_output;
  
  top_module tf(.clk(clk), .rst(rst), .ready(ready), .data(data), .tx_status(tx_status), .rx_status(rx_status), .tx_data(tx_data), .rx_output(rx_output));
  
  
  always #1 begin
    clk <= ~clk;
    // $monitor("[$monitor] time=%0t tx_status=%0b tx_data=%0b", $time, tx_status, tx_data);
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    clk <= 0;
    rst <= 1;
    ready <= 0;
    data <= 61;
    
    #200
    rst <= 0;
    ready <= 1;
    
    #1200
    ready <= 0;
    
	 #10_000
	 
    #25_000 $finish;
  end
//	// baud rate tester
//   reg clk, rst;
//   reg [2:0] baud_sel;
  
//   wire bclk, bclk_xEight;
  
//   baudrate br(.clk(clk), .rst(rst), .baud_sel(baud_sel), .bclk(bclk), .bclk_x8(bclk_xEight));
  
//   initial begin
//     $dumpfile("dump.vcd");
//     $dumpvars;
//   end
  
//   always #1 clk <= ~clk;
  
//   initial begin
//     clk <= 0;
//     rst <= 1;
    
//     #10
//     rst <= 0;
//     baud_sel <= 3;
    
//     #50_000 $finish;
//   end
endmodule
