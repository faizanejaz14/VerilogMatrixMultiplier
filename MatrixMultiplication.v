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
module TM_matrix_multiplication(input clk, rst, write_A_TX, write_B_TX, rx_data,
											output reg complete,
											//output reg rst_MAC, MAC_acc, MAC_sum,
											//output reg [2:0] state, 
											//output [7:0] write_value_R,
											output written_completed_A, written_completed_B,
											//output [7:0] data_A, data_B,
											output tx_data
											);
  // only need to change memory modules A and B into UART_to_MEM and R into MEM_to_TX
  integer _i; // temp variable for loading memory
  parameter row = 10, column = 10;

  // initializing memory A
  reg read_A;//, write_A_TX;
  reg [31:0] read_address_A;
  //wire written_completed_A;
  wire [7:0] data_A;
  UART_to_MEM #(.row(row), .column(column)) A(.clk(clk), .rst(rst), .rx_data(rx_data), .read_A(read_A), .write_A_TX(write_A_TX), .read_address_A(read_address_A),
					.written_completed(written_completed_A), .data_A(data_A));

  // initializing memory B
  reg read_B;//, write_B_TX;
  reg [31:0] read_address_B;
  //wire written_completed_B;
  wire [7:0] data_B;
  UART_to_MEM #(.row(row), .column(column)) B(.clk(clk), .rst(rst), .rx_data(rx_data), .read_A(read_B), .write_A_TX(write_B_TX), .read_address_A(read_address_B),
					.written_completed(written_completed_B), .data_A(data_B));
  
  // initializing memory R
  reg write_R, read_R_mat;
  reg [31:0] write_address_R, read_address_R;
  wire [15:0] write_value_R;
  newMEM_to_TX #(.row(row), .column(column)) R(.clk(clk), .rst(rst), .read_R_mat(read_R_mat), .write_R(write_R), .write_address_R(write_address_R),
						.write_value_R(write_value_R), .tx_data(tx_data));
    
  // states
  parameter IDLE = 0, START = 2, LOAD_VAL = 3, MAC = 4, STORE = 5, DONE = 6;
  reg [2:0] next_state, state;
  
  parameter total_elements = 2*2;
  // reg rst_i, rst_j, rst_k;
  reg [31:0] i, j, k;
  // temporary counter to write values in Mem A and Mem B
  reg [31:0] write_counter = 0;
  
  wire slow_clk;
  clk_div #(.DIV(1000)) oneHzclock (.clk(clk), .slow_clk(slow_clk));
  
  // initializing MAC module
  reg rst_MAC, MAC_acc, MAC_sum;
  mac _mac (.clk(slow_clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A), .b(data_B), .c(write_value_R));//, .temp(temp));
  
  initial begin
	rst_MAC <= 1'b0;
	MAC_acc <= 1'b0;
	MAC_sum <= 1'b0;
	state <= IDLE;
  end
  
  always @ (posedge slow_clk or posedge rst) begin
    if (rst) state <= IDLE;
    else state <= next_state;
  end
  
  always @ (*) begin
    next_state = state;
    case (state)
      IDLE: if (written_completed_A && written_completed_B) next_state = START; // need to only start after A and B are loaded, make logic for this later
      
      START: next_state = LOAD_VAL;
      
      LOAD_VAL: begin
        if (i >= row) next_state = DONE;
        else next_state = MAC;
      end
      
      MAC: begin
        if (k == column - 1) next_state = STORE;
        else next_state = LOAD_VAL;
      end
          
      STORE: next_state = LOAD_VAL;
      
      DONE: if (rst) next_state = IDLE;
      
      default: next_state = state;
    endcase
  end
  
  // State outputs
  always @ (posedge slow_clk) begin // replace clk with *
    rst_MAC <= 1'b0;
    MAC_acc <= 1'b0;
    write_R <= 1'b0;
    read_A <= 1'b0;
    read_B <= 1'b0;
    MAC_sum <= 1'b0;
	 read_R_mat <= 1'b0;
	 
    case (state)
      IDLE: begin
          write_counter <= 1'b0;
			 complete <= 1'b0;
      end
      
      START: begin
        i <= 0;
        j <= 0;
        k <= 0;
        rst_MAC <= 1'b1;
      end
      
      LOAD_VAL: begin
        read_address_A <= row*i + k; // getting index of value from mat A
        read_A <= 1'b1;
        
        read_address_B <= row*k + j; // getting index of value from mat B
        read_B <= 1'b1;
        MAC_sum <= 1'b1;
      end
      
      MAC: begin
        k <= k + 1;
        if (k == column - 1)
          MAC_acc <= 1'b1;
      end
      
      STORE: begin
        write_address_R <= row*i + j;
        write_R <= 1'b1;
        k <= 3'b0;
        rst_MAC <= 1'b1;
        if (j == column - 1) begin
          j <= 3'b0;
          i <= i + 1;
        end
        else j <= j + 1;
      end
      
      DONE: begin
		  read_R_mat <= 1'b1;
        complete <= 1'b1;
      end
      
      default: begin
        rst_MAC <= 1'b0;
	     MAC_acc <= 1'b0;
		  write_R <= 1'b0;
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
