`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:18:37 11/04/2024 
// Design Name: 
// Module Name:    UART_to_MEM 
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
module UART_to_MEM(
input clk, rst, rx_data, read_A, write_A_TX,
input [31:0] read_address_A0, read_address_A1, read_address_A2, read_address_A3, read_address_A4, read_address_A5, read_address_A6, read_address_A7, read_address_A8, read_address_A9,
output reg written_completed,
//output reg [7:0] write_address_A,
//output reg state,
output [7:0] data_A0, data_A1, data_A2, data_A3, data_A4, data_A5, data_A6, data_A7, data_A8, data_A9
//output reg [7:0] values_received_count
    );
  
  reg [31:0] values_received_count = 0;
  initial begin
	written_completed <= 1'b0;
  end
  parameter row = 2, column = 2;
  parameter total_values = row*column;
  //===receiver===//
  wire bclk, bclk_x8;
  wire [9:0] temp_reg;
  wire rx_status;
  
  baudrate #(.baud_sel(0)) br(.clk(clk), .rst(rst), .bclk(bclk), .bclk_x8(bclk_x8));
  //transmitter tr(.bclk(bclk), .rst(rst), .ready(ready), .data(data), .tx_status(tx_status), .tx_data(tx_data));
  reciever rc(.bclk_x8(bclk_x8), .rst(rst), .rx_data(rx_data), .rx_status(rx_status), .rx_output(temp_reg));

  //===memory===//
  // initializing memory A
  reg write_A; //, read_A;
//  reg [5:0] write_address_A; //, read_address_A;
  reg [7:0] write_value_A;
  // wire [7:0] data_A;
  memory #(.row(row), .column(column)) matrix_A (.clk(clk), .rst(rst), .write(write_A && write_A_TX), .read(read_A),
    .write_address0(values_received_count),
    .read_address0(read_address_A0), .read_address1(read_address_A1), .read_address2(read_address_A2), 
    .read_address3(read_address_A3), .read_address4(read_address_A4), .read_address5(read_address_A5), 
    .read_address6(read_address_A6), .read_address7(read_address_A7), .read_address8(read_address_A8), 
    .read_address9(read_address_A9),
    .write_value0(write_value_A),
    .data0(data_A0), .data1(data_A1), .data2(data_A2), .data3(data_A3), .data4(data_A4),
    .data5(data_A5), .data6(data_A6), .data7(data_A7), .data8(data_A8), .data9(data_A9));

  
  //=== 1HZ Clock by clk divider ===//
  // wire slow_clk;
  // reg display;
  // reg [1:0] display_value_index;
  // clk_div #(.DIV(1000)) oneHz (.clk(clk), .slow_clk(slow_clk)); // For SIMULATION
  // clk_div oneHz (.clk(clk), .slow_clk(slow_clk));
  
  //always @(posedge slow_clk or posedge rst) begin
  // if (rst) begin display_value_index <= 0; read_A <= 0; end
	//else if (display && display_value_index < 4) begin
		//read_A <= 1;
		//read_address_A <= display_value_index;
		//value <= data_A;
		//display_value_index <= display_value_index + 2'd1;
	  //end
	  //else read_A <= 0;
  //end
  
  //===FSM===//
  parameter IDLE = 0, RECEIVING = 1,
				STORE = 2, END = 3, RESET = 4;
				
  //reg [2:0] values_received_count;
  reg [2:0] next_state, state;
  always @ (posedge clk or posedge rst) begin
    if (rst) begin 
		state <= IDLE;
	 end
	 else state <= next_state;
  end

  // next state logic
  always @ (*) begin
    next_state = state;
    case (state)
      IDLE: if (rx_status == 1 && write_A_TX) next_state = RECEIVING;
      
      RECEIVING: begin if (rx_status == 0) next_state = STORE; else next_state = RECEIVING; end
      // going to send when we receive all the 4 numbers, otherwise we go to IDLE to get the next input
      STORE: begin if (values_received_count >= total_values - 1) next_state = END; else next_state = IDLE; end
      END: begin if (rst) next_state = RESET; else next_state = END; end
		RESET: next_state = IDLE;
      default: next_state = state;
    endcase
  end
  
  // values_received_count logic, before it was in the always block at line 102 but we seperate it to prevent undefined behaviour before.
  reg inc_vrc = 1'b0;
  reg rst_vrc = 1'b0;
  always @ (posedge clk or posedge rst or posedge rst_vrc) begin
	if (rst | rst_vrc) values_received_count <= 0;
	else if (inc_vrc) values_received_count <= values_received_count + 1;
	else values_received_count <= values_received_count;
  end
  
  always @ (*) begin
	 write_A = 1'b0;
	 written_completed = 1'b0;
	 inc_vrc = 1'b0;
	 rst_vrc = 1'b0;
	 
    case(state)
      IDLE: begin
			write_A = 1'b0;
      end
      
      RECEIVING: begin
    		write_A = 1'b0;
      end
      
      STORE: begin
         write_A = 1'b1;
         write_value_A = temp_reg [8:1];
         //write_address_A = values_received_count - 1;
			inc_vrc = 1'b1;
      end
      
      END: begin
			written_completed = 1'b1;
      end
      
		RESET: begin
			rst_vrc = 1'b1;
		end
      default: write_A = 0;
    endcase
  end
  
  
endmodule
