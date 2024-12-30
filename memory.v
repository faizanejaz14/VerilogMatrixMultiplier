`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:55:05 11/04/2024 
// Design Name: 
// Module Name:    memory 
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
//-------------------------------------- memory --------------------------------------//

module memory(input clk, rst, write, read,
              input [31:0] write_address0, write_address1, write_address2, write_address3, write_address4, write_address5, write_address6, write_address7, write_address8, write_address9,
              input [31:0] read_address0, read_address1, read_address2, read_address3, read_address4, read_address5, read_address6, read_address7, read_address8, read_address9,
              input [size - 1:0] write_value0, write_value1, write_value2, write_value3, write_value4, write_value5, write_value6, write_value7, write_value8, write_value9,
              output reg [size - 1:0] data0, data1, data2, data3, data4, data5, data6, data7, data8, data9);
  parameter row = 2;
  parameter column = 2;
  parameter size = 8;
  
  // 8 bit 2x2 matrix
  reg [size - 1 : 0] mem [0 : (row*column) - 1]; // https://www.chipverify.com/verilog/verilog-arrays-memories
  integer i;
  integer j;
  // sync writing
  
  //// zakria addition
  initial begin
  //initialize
  for (i = 0; i < row; i = i + 1)
        for (j = 0; j < column; j = j + 1)
          mem[row*i + j] = 0; // make 0 
  end
  //// zakria close
  
  always @ (posedge clk) begin
    // writing in memory
    if (write) begin
      mem[write_address0] <= write_value0;
      mem[write_address1] <= write_value1;
      mem[write_address2] <= write_value2;
      mem[write_address3] <= write_value3;
      mem[write_address4] <= write_value4;
      mem[write_address5] <= write_value5;
      mem[write_address6] <= write_value6;
      mem[write_address7] <= write_value7;
      mem[write_address8] <= write_value8;
      mem[write_address9] <= write_value9;
    end
  end 
	
  // async reading
  always @ (read) begin
    if (read) begin
      data0 = mem[read_address0];
      data1 = mem[read_address1];
      data2 = mem[read_address2];
      data3 = mem[read_address3];
      data4 = mem[read_address4];
      data5 = mem[read_address5];
      data6 = mem[read_address6];
      data7 = mem[read_address7];
      data8 = mem[read_address8];
      data9 = mem[read_address9];
    end else begin
      data0 = data0;
      data1 = data1;
      data2 = data2;
      data3 = data3;
      data4 = data4;
      data5 = data5;
      data6 = data6;
      data7 = data7;
      data8 = data8;
      data9 = data9;
    end
  end
endmodule
