`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:44:04 11/24/2024 
// Design Name: 
// Module Name:    test_receive_counter 
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
module test_receive_counter(input clk, rst, rx_data,
output reg [3:0] receive_counter
    );
	 
  //===receiver===//
  wire bclk, bclk_x8;
  wire [9:0] temp_reg;
  wire rx_status;
  
  baudrate #(.baud_sel(0)) br(.clk(clk), .rst(rst), .bclk(bclk), .bclk_x8(bclk_x8));
  //transmitter tr(.bclk(bclk), .rst(rst), .ready(ready), .data(data), .tx_status(tx_status), .tx_data(tx_data));
  reciever rc(.bclk_x8(bclk_x8), .rst(rst), .rx_data(rx_data), .rx_status(rx_status), .rx_output(temp_reg));
  
  // FSM
  parameter IDLE = 0, RECEIVE = 1, UPDATE = 2;
  reg [1:0] state, next_state;
  always @ (posedge clk) begin
		if (rst) state = IDLE;
		else state = next_state;
  end
  
  //updating counter logic
  reg update_counter = 1'b0;
  always @ (posedge clk or posedge rst) begin
		if (rst) receive_counter <= 4'd1;
		else if (update_counter) receive_counter <= receive_counter + 4'd1;
		else receive_counter <= receive_counter;
  end
  
  // State change logic
  always @ (*) begin
		next_state = state;
		update_counter = 1'b0;
		case (state)
			IDLE: if (rx_status == 1'b1) next_state = RECEIVE;
			RECEIVE: if (rx_status == 1'b0) next_state = UPDATE;
			UPDATE: begin 
				next_state = IDLE;
				update_counter = 1'b1;
			end
			default: next_state = IDLE;
		endcase
  end
  
endmodule
