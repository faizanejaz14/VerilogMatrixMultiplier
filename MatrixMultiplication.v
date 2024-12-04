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
  // only need to change memory modules A and B into UART_to_MEM and R into MEM_to_TX
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
  reg rst_MAC, MAC_acc, MAC_sum;
  mac _mac (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A), .b(data_B), .c(write_value_R));
  
  // states
  parameter IDLE = 0, START = 2, LOAD_VAL = 3, MAC = 4, STORE = 5, DONE = 6;
  reg [2:0] state, next_state;
  
  parameter total_elements = 2*2;
  // reg rst_i, rst_j, rst_k;
  reg [2:0] i, j, k;
  // temporary counter to write values in Mem A and Mem B
  reg [2:0] write_counter = 0;
  
  
  always @ (posedge clk or posedge rst) begin
    if (rst) state <= IDLE;
    else state <= next_state;
  end
  
  always @ (*) begin
    next_state = state;
    case (state)
      IDLE: next_state = START; // need to only start after A and B are loaded, make logic for this later
      
      START: next_state = LOAD_VAL;
      
      LOAD_VAL: begin
        if (i >= 2) next_state = DONE;
        else next_state = MAC;
      end
      
      MAC: begin
        if (k == 1) next_state = STORE;
        else next_state = LOAD_VAL;
      end
          
      STORE: next_state = LOAD_VAL;
      
      DONE: if (rst) next_state = IDLE;
      
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
    MAC_sum <= 0;

    case (state)
      IDLE: begin
          write_counter <= 0;
			 complete <= 0;
      end
      
      START: begin
        i <= 0;
        j <= 0;
        k <= 0;
        rst_MAC <= 1;
      end
      
      LOAD_VAL: begin
        read_address_A <= 2*i + k; //for flexibility replace '2' with variable
        read_A <= 1;
        
        read_address_B <= 2*k + j; //for flexibility replace '2' with variable
        read_B <= 1;
        MAC_sum <= 1;
      end
      
      MAC: begin
        k <= k + 1;
        if (k == 1)
          MAC_acc <= 1;
      end
      
      STORE: begin
        write_address_R <= 2*i + j;
        write_R <= 1;
        k <= 0;
        rst_MAC <= 1;
        if (j == 1) begin
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

//-------------- MAC ------------------//
module mac(input clk, rst, sum, acc,
           input [7:0] a, b,
           output reg [15:0] c); // max output is (2^8 - 1) * (2^8 - 1) is 16 bit number
  reg [15:0] temp;
  
  always @ (posedge clk or posedge rst) begin
    if (rst) temp <= 0;
    else if (acc) c <= temp;
    else if (sum) temp <= temp + a*b;
    else temp <= temp;
  end
endmodule
