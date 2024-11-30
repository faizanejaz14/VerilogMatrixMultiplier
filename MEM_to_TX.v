`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:29:47 11/25/2024 
// Design Name: 
// Module Name:    MEM_to_TX 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Rdditional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MEM_to_TX(
input clk, rst, read_R_mat,
output tx_data
    );
	 
	//===TX===//
  wire bclk, bclk_x8;
  wire [9:0] temp_reg;
  wire tx_status;
  wire [7:0] data_R;
  reg read_R;
  baudrate #(.baud_sel(0)) br(.clk(clk), .rst(rst), .bclk(bclk), .bclk_x8(bclk_x8));
  transmitter tr(.bclk(bclk), .rst(rst), .ready(read_R), .data(data_R), .tx_status(tx_status), .tx_data(tx_data));
  //reciever rc(.bclk_x8(bclk_x8), .rst(rst), .rx_data(rx_data), .rx_status(rx_status), .rx_output(temp_reg));

//===memory===//
// paramterize later

  // initializing memory R
  reg write_R;
  reg [5:0] write_address_R, read_address_R;
  reg [7:0] write_value_R;
  memory #(.row(2), .column(2)) matrix_R (.clk(clk), .rst(rst), .write(write_R), .read(read_R),
                                          .write_address(write_address_R),
                                          .read_address(read_address_R),
                                          .write_value(write_value_R),
                                          .data(data_R));
	

	//===FSM===//
	parameter IDLE = 0, START_TRANSMIT = 1, TRANSMIT = 2;
	
	// Level edge detector as we only need to check posedge of read_R_mat signal
	wire read_R_pulse;
	level_det ld (.clk(clk), .in(read_R_mat), .pulse(read_R_pulse));
	
	// state registers
	reg [1:0] state, next_state;
	always @ (posedge clk or posedge rst) begin
		if (rst) state <= IDLE;
		else state <= next_state;
	end
	
	// state change logic
	always @ (*) begin
		next_state = state;
		case (state)
			IDLE: if (read_R_pulse) next_state = START_TRANSMIT;
			START_TRANSMIT: begin
				if (tx_status) begin
					if (values_sent_count < 4) next_state = TRANSMIT;
					else next_state = IDLE;
				end
			end
			TRANSMIT: if (!tx_status) next_state = START_TRANSMIT;
			default: next_state = state;
		endcase
	end
	
	// output logic
	reg [2:0] values_sent_count = 3'b0;
	reg inc_vsc, rst_vsc;
	always @ (posedge inc_vsc or posedge rst_vsc) begin
		if (rst_vsc) values_sent_count <= 3'd0;
		else if (inc_vsc) values_sent_count <= values_sent_count + 3'd1;
		else values_sent_count <= values_sent_count;
	end
  
	always @ (state) begin // at * it is changing state too many times, causing simulation to crash
		read_address_R = values_sent_count;
		read_R = 1'b0;
		inc_vsc = 1'b0;
		rst_vsc = 1'b0;
		case(state)
			IDLE: begin
				rst_vsc = 1'b1;
			end
			START_TRANSMIT: begin
				read_R = 1'b1;
				inc_vsc = 1'b1;
			end
			default: begin read_R = 1'b0; inc_vsc = 1'b0; end
		endcase
	end
endmodule

module level_det(input clk, in,
						output pulse);
	reg r1, r2, r3;
	
	always @ (posedge clk) begin
		r1 <= in;
		r2 <= r1;
		r3 <= r2;
	end
	
	assign pulse = r2 & ~r3;
endmodule
