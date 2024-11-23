`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:58:15 10/10/2024 
// Design Name: 
// Module Name:    top_module 
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
// Defining memory Module
module TM_matrix_multiplication(input clk, rst, output reg complete);
  
  integer _i; // temp variable for loading memory
  // initializing memory A
  reg write_A, read_A;
  reg [5:0] write_address_A, read_address_A;
  reg [7:0] write_value_A;
  wire [7:0] data_A;
  memory #(.row(2), .column(2)) matrix_A (.clk(clk), .rst(rst), .write(write_A), .read(read_A),
                                          .write_address(write_address_A),
                                          .read_address(read_address_A),
                                          .write_value(write_value_A),
                                          .data(data_A));
  // initializing memory B
  reg write_B, read_B;
  reg [5:0] write_address_B, read_address_B;
  reg [7:0] write_value_B;
  wire [7:0] data_B;
  memory #(.row(2), .column(2)) matrix_B (.clk(clk), .rst(rst), .write(write_B), .read(read_B),
                                          .write_address(write_address_B),
                                          .read_address(read_address_B),
                                          .write_value(write_value_B),
                                          .data(data_B));
  
  // initializing memory R
  reg write_R, read_R;
  reg [5:0] write_address_R, read_address_R;
  wire [15:0] write_value_R;
  wire [15:0] data_R;
  memory #(.row(2), .column(2), .size(16)) matrix_R (.clk(clk), .rst(rst), .write(write_R), .read(read_R),
                                          .write_address(write_address_R),
                                          .read_address(read_address_R),
                                          .write_value(write_value_R),
                                          .data(data_R));
    
  // initializing MAC module
  reg rst_MAC, MAC_acc;
  mac _mac (.clk(clk), .rst(rst_MAC), .acc(MAC_acc), .a(data_A), .b(data_B), .c(write_value_R));
  
  // states
  parameter IDLE = 0, LOAD_MEM = 1, START = 2, LOAD_VAL = 3, MAC = 4, STORE = 5, DONE = 6;
  reg [2:0] state, next_state;
  
  parameter total_elements = 2*2;
  // reg rst_i, rst_j, rst_k;
  reg [2:0] i, j, k;
  
  always @ (posedge clk or posedge rst) begin
    if (rst) state <= IDLE;
    else state <= next_state;
  end
  
  always @ (*) begin
    next_state = state;
    case (state)
      IDLE: next_state = LOAD_MEM;
      
      LOAD_MEM: next_state = START;

      START: next_state = LOAD_VAL;
      
      LOAD_VAL:	next_state = MAC;
      
      MAC: if (k == 2) next_state = STORE;
          
      STORE: begin
        if (i < 2 || j < 2)
          next_state = LOAD_VAL;
        else
          next_state = DONE;
      end
      
      DONE: next_state = LOAD_MEM;
      
      default: next_state = state;
    endcase
  end
  
  // State outputs
  always @ (posedge clk) begin // replace clk with *
    rst_MAC <= 0;
    MAC_acc <= 0;
    write_R <= 0;
    read_A <= 0;
    read_B <= 0;
    write_A <= 0;
    write_B <= 0;
	 complete <= 0;
    case (state)
      LOAD_MEM: begin
        // Loading data in memory
        write_A <= 1;
        for (_i = 0; _i < 9; _i=_i+1) begin
          write_value_A <= _i*2 + 1;
          write_address_A <= _i;
        end

        write_B <= 1;
        for (_i = 0; _i < 9; _i=_i+1) begin
          write_value_B <= _i*2;
          write_address_B <= _i;
        end
      end
		
      START: begin
        i <= 0;
        j <= 0;
        k <= 0;
        rst_MAC <= 1;
      end
      
      LOAD_VAL: begin
        read_address_A <= 2*i + k;
        read_A <= 1;
        read_address_B <= 2*k + j;
        read_B <= 1;
      end
      
      MAC: begin
        k <= k + 1;
      end
      
      STORE: begin
        write_address_R <= 2*i + j;
        MAC_acc <= 1;
        rst_MAC <= 1;
        write_R <= 1;
        k <= 0;
        if (j == 2) begin
          j <= 0;
          i <= i + 1;
        end
        else j <= j + 1;
      end
      
      DONE: begin
        complete <= 1;
      end
      
      default: begin
        rst_MAC <= 0;
	    MAC_acc <= 0;
    	write_R <= 0;
      end
    endcase
  end
endmodule


//-------------------------------------- MAC --------------------------------------//

module mac(input clk, rst, acc,
           input [7:0] a, b,
           output reg [15:0] c); // max output is (2^8 - 1) * (2^8 - 1) is 16 bit number
  reg [15:0] temp;
  
  always @ (posedge clk or posedge rst) begin
    if (rst) temp <= 0;
    else if (acc) c <= temp;
    else temp <= temp + a*b;
  end
endmodule
