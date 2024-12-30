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
  parameter row = 3, column = 3;

  // initializing memory A
  reg read_A;//, write_A_TX;
  reg [31:0] read_address_A0, read_address_A1, read_address_A2, read_address_A3, read_address_A4, read_address_A5, read_address_A6, read_address_A7, read_address_A8, read_address_A9;
  //wire written_completed_A;
  wire [7:0] data_A0, data_A1, data_A2, data_A3, data_A4, data_A5, data_A7, data_A8, data_A9;
  UART_to_MEM #(.row(row), .column(column)) A(.clk(clk), .rst(rst), .rx_data(rx_data), .read_A(read_A), .write_A_TX(write_A_TX),
					.read_address_A0(read_address_A0), .read_address_A1(read_address_A1), .read_address_A2(read_address_A2),
					.read_address_A3(read_address_A3), .read_address_A4(read_address_A4), .read_address_A5(read_address_A5),
					.read_address_A6(read_address_A6), .read_address_A7(read_address_A7), .read_address_A8(read_address_A8),
					.read_address_A9(read_address_A9),
					.written_completed(written_completed_A),
					.data_A0(data_A0), .data_A1(data_A1), .data_A2(data_A2),
					.data_A3(data_A3), .data_A4(data_A4), .data_A5(data_A5),
					.data_A6(data_A6), .data_A7(data_A7), .data_A8(data_A8),
					.data_A9(data_A9));

  // initializing memory B
  reg read_B;//, write_B_TX;
  reg [31:0] read_address_B;
  //wire written_completed_B;
  wire [7:0] data_B;
  UART_to_MEM #(.row(row), .column(column)) B(.clk(clk), .rst(rst), .rx_data(rx_data), .read_A(read_B), .write_A_TX(write_B_TX),
					.read_address_A0(read_address_B),
					.written_completed(written_completed_B), .data_A0(data_B));
  
  // initializing memory R
  reg write_R, read_R_mat;
  reg [31:0] write_address_R0, write_address_R1, write_address_R2, write_address_R3, write_address_R4, write_address_R5, write_address_R6, write_address_R7, write_address_R8, write_address_R9;//, read_address_R;
  wire [15:0] write_value_R0, write_value_R1, write_value_R2, write_value_R3, write_value_R4, write_value_R5, write_value_R6, write_value_R7, write_value_R8, write_value_R9;
  newMEM_to_TX #(.row(row), .column(column)) R(.clk(clk), .rst(rst), .read_R_mat(read_R_mat), .write_R(write_R),
					.write_address_R0(write_address_R0), .write_address_R1(write_address_R1), .write_address_R2(write_address_R2),
					.write_address_R3(write_address_R3), .write_address_R4(write_address_R4), .write_address_R5(write_address_R5),
					.write_address_R6(write_address_R6), .write_address_R7(write_address_R7), .write_address_R8(write_address_R8),
					.write_address_R9(write_address_R9),
					.write_value_R0(write_value_R0), .write_value_R1(write_value_R1), .write_value_R2(write_value_R2),
					.write_value_R3(write_value_R3), .write_value_R4(write_value_R4), .write_value_R5(write_value_R5),
					.write_value_R6(write_value_R6), .write_value_R7(write_value_R7), .write_value_R8(write_value_R8),
					.write_value_R9(write_value_R9),
					.tx_data(tx_data));
    
  // states
  parameter IDLE = 0, START = 2, LOAD_VAL = 3, MAC = 4, STORE = 5, DONE = 6;
  reg [2:0] next_state, state;
  
  parameter total_elements = 2*2;
  // reg rst_i, rst_j, rst_k;
  reg [31:0] i, j, k;
  // temporary counter to write values in Mem A and Mem B
  reg [31:0] write_counter = 0;
  
  //wire slow_clk;
  //clk_div #(.DIV(1000)) oneHzclock (.clk(clk), .slow_clk(slow_clk));
  
  // initializing MAC module
  reg rst_MAC, MAC_acc, MAC_sum;
  mac _mac0 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A0), .b(data_B), .c(write_value_R0));//, .temp(temp));
  mac _mac1 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A1), .b(data_B), .c(write_value_R1));//, .temp(temp));
  mac _mac2 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A2), .b(data_B), .c(write_value_R2));//, .temp(temp));
  //mac _mac3 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A3), .b(data_B), .c(write_value_R3));//, .temp(temp));
  //mac _mac4 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A4), .b(data_B), .c(write_value_R4));//, .temp(temp));
  //mac _mac5 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A5), .b(data_B), .c(write_value_R5));//, .temp(temp));
  //mac _mac6 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A6), .b(data_B), .c(write_value_R6));//, .temp(temp));
  //mac _mac7 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A7), .b(data_B), .c(write_value_R7));//, .temp(temp));
  //mac _mac8 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A8), .b(data_B), .c(write_value_R8));//, .temp(temp));
  //mac _mac9 (.clk(clk), .rst(rst_MAC), .sum(MAC_sum), .acc(MAC_acc), .a(data_A9), .b(data_B), .c(write_value_R9));//, .temp(temp));

  initial begin
	rst_MAC <= 1'b0;
	MAC_acc <= 1'b0;
	MAC_sum <= 1'b0;
	state <= IDLE;
  end
  
  always @ (posedge clk or posedge rst) begin
    if (rst) state <= IDLE;
    else state <= next_state;
  end
  
  always @ (*) begin
    next_state = state;
    case (state)
      IDLE: if (written_completed_A && written_completed_B) next_state = START; // need to only start after A and B are loaded, make logic for this later
      
      START: next_state = LOAD_VAL;
      
      LOAD_VAL: begin
        if (i >= 1) next_state = DONE;
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
  always @ (posedge clk) begin // replace clk with *
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
        read_address_A0 <= k; // getting index of value from mat A
        read_address_A1 <= row + k; // getting index of value from mat A
        read_address_A2 <= row*2 + k; // getting index of value from mat A
        //read_address_A3 <= row*3 +k; // getting index of value from mat A
        //read_address_A4 <= row*4 +k; // getting index of value from mat A
        //read_address_A5 <= row*5 +k; // getting index of value from mat A
        //read_address_A6 <= row*6 +k; // getting index of value from mat A
        //read_address_A7 <= row*7 +k; // getting index of value from mat A
        //read_address_A8 <= row*8 +k; // getting index of value from mat A
        //read_address_A9 <= row*9 +k; // getting index of value from mat A

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
        write_address_R0 <= j;
        write_address_R1 <= row + j;
        write_address_R2 <= 2*row + j;
        //write_address_R3 <= 3*row + j;
        //write_address_R4 <= 4*row + j;
        //write_address_R5 <= 5*row + j;
        //write_address_R6 <= 6*row + j;
        //write_address_R7 <= 7*row + j;
        //write_address_R8 <= 8*row + j;
        //write_address_R9 <= 9*row + j;

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
  reg [15:0] temp = 0;
  
  always @ (posedge clk or posedge rst) begin
    if (rst) temp <= 0;
    else if (acc) c <= temp;
    else if (sum) temp <= temp + a*b;
    else temp <= temp;
  end
endmodule
