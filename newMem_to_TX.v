`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:17:35 12/05/2024 
// Design Name: 
// Module Name:    newMem_to_TX 
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
/////////////////////////////////////// made by Faizan. Debugged by Zakria and Irtaza ///////////////////////////////////////////
module newMEM_to_TX(
input clk, rst, read_R_mat, write_R,
input [31:0] write_address_R,
input [7:0] write_value_R,
output tx_data
//output [7:0] data_R,
//output reg [2:0] values_sent_count
    );
	 
	parameter row = 2, column = 2;
  //===TX===//
  wire bclk, bclk_x8;
  wire [9:0] temp_reg;
  reg read_R;
  reg TransmitSignal;
  reg [7:0] data_value;
  wire tx_status;
  wire TransmitPulse;
  wire slow_clk;
  wire [7:0] data_R;
  clk_div #(.cycles(100_000)) eddy (.clk(clk), .slow_clk(slow_clk));
  level_det tsld (.clk(slow_clk), .in(TransmitSignal), .pulse(posTransmitPulse));
  
  baudrate #(.baud_sel(0)) br(.clk(clk), .rst(rst), .bclk(bclk), .bclk_x8(bclk_x8));
  transmitter tr(.bclk(bclk), .rst(rst), .ready(posTransmitPulse), .data(data_R), .tx_status(tx_status), .tx_data(tx_data));

  //===memory===//
  // paramterize later

  // initializing memory R
  //reg write_R;
  reg [31:0] values_sent_count;
  //reg [7:0] write_value_R;
  memory #(.row(row), .column(column), .size(16)) matrix_R (.clk(clk), .rst(rst), .write(write_R), .read(read_R),
                                          .write_address(write_address_R),
                                          .read_address(values_sent_count),
                                          .write_value(write_value_R),
                                          .data(data_R));
	

	//===FSM===//
	parameter IDLE = 0, READ_DATA = 1, TRANSMIT_READY = 2, TRANSMIT_DATA = 3, NEXT_VALUE_PREP = 4, BUFFER_STATE = 5;
	
	// Level edge detector as we only need to check posedge of read_R_mat signal
	wire read_R_pulse;
	level_det ld (.clk(slow_clk), .in(read_R_mat), .pulse(read_R_pulse));
	
	// state registers
	reg [2:0] state, next_state;
	always @ (posedge slow_clk or posedge rst) begin
		if (rst)
			state <= IDLE;
		else 
			state <= next_state;
	end
	
	// state change logic
	always @ (state) begin
		next_state = state;
		case (state)
			IDLE: begin
				read_R = 1'b0;
				TransmitSignal = 1'b0;
				if (read_R_pulse) next_state = READ_DATA;
				else next_state = state;
			end
			READ_DATA: begin
					TransmitSignal = 1'b0;
					if (values_sent_count > row*column - 1) next_state = IDLE;
					else begin
						read_R = 1'b1;
						next_state = TRANSMIT_READY;
					end
					//else next_state = state;
			end
			TRANSMIT_READY: begin
				read_R = 1'b0;
				TransmitSignal = 1'b1;
				next_state = TRANSMIT_DATA;
			end
			TRANSMIT_DATA: begin
				//TransmitSignal = 1'b1;
				read_R = 1'b0;
				next_state = NEXT_VALUE_PREP;
			end
			NEXT_VALUE_PREP: begin
				read_R = 1'b0;
				TransmitSignal = 1'b0;
				if (!tx_status) begin
					next_state = READ_DATA;
				end
				else next_state = state;
			end
			default: next_state = state;
		endcase
	end	
	
	// values_sent_count Logic
	//wire TransmitPulse;
	//neg_level_edge nle (.clk(slow_clk), .btn(TransmitSignal), .pulse(TransmitPulse));
	always @ (posedge slow_clk) begin
		if(posTransmitPulse)
			values_sent_count <= values_sent_count + 1;    // Increment count
		
		else if(state == IDLE)
			values_sent_count <= 0;    // Increment count	
	end
endmodule
