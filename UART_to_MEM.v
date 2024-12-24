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
input clk, rst, rx_data, read_A, read_address_A,
output [7:0] data_A,
output reg complete
    );
  
  parameter row = 2, column = 2;
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
  reg [row*column + 1:0] write_address_A; //, read_address_A;
  reg [7:0] write_value_A;
  // wire [7:0] data_A;
  memory #(.row(2), .column(2)) matrix_A (.clk(clk), .rst(rst), .write(write_A), .read(read_A),
                                          .write_address(write_address_A),
                                          .read_address(read_address_A),
                                          .write_value(write_value_A),
                                          .data(data_A));
  
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
				STORE = 2, END = 3;
				
  //reg [2:0] values_received_count;
  reg [2:0] state, next_state;
  wire slow_clk;
  clk_div oneHz(.clk(clk), .slow_clk(slow_clk));
  always @ (posedge slow_clk or posedge rst) begin
    if (rst) begin 
		state <= IDLE;
	 end
	 else state <= next_state;
  end

  // next state logic
  always @ (*) begin
    next_state = state;
    case (state)
      IDLE: if (rx_status == 1) next_state = RECEIVING;
      
      RECEIVING: begin if (rx_status == 0) next_state = STORE; else next_state = RECEIVING; end
      // going to send when we receive all the 4 numbers, otherwise we go to IDLE to get the next input
      STORE: begin if (values_received_count == row*column - 1) next_state = END; else next_state = IDLE; end
      END: begin if (rst) next_state = IDLE; else next_state = END; end
      default: next_state = state;
    endcase
  end
  
  // values_received_count logic, before it was in the always block at line 102 but we seperate it to prevent undefined behaviour before.
  reg [row*column + 1:0] values_received_count = 0;
  reg inc_vrc = 1'b0;
  reg rst_vrc = 1'b0;
  always @ (posedge clk or posedge rst or posedge rst_vrc) begin
	if (rst | rst_vrc) values_received_count <= 0;
	else if (inc_vrc) values_received_count <= values_received_count + 1;
	else values_received_count <= values_received_count;
  end
  
  always @ (*) begin
	 write_A = 1'b0;
//	 display = 1'b0;
	 inc_vrc = 1'b0;
	 rst_vrc = 1'b0;
	 complete = 1'b0;
	 
    case(state)
      IDLE: begin
			write_A = 0;
      end
      
      RECEIVING: begin
    		write_A = 0;
      end
      
      STORE: begin
         write_A = 1'b1;
         write_value_A = temp_reg [8:1];
         write_address_A = values_received_count;
			inc_vrc = 1'b1;
      end
      
      END: begin
		   rst_vrc = 1'b1;
			complete = 1'b1;
			//display = 1'b1;
      end
      
      default: write_A = 0;
    endcase
  end
  
  
endmodule
