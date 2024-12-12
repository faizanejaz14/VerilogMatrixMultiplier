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
input clk, rst, read_R_mat,
output reg [4:0] state_LED,
output reg [2:0] values_sent_count = 3'b0,
output tx_data,
output tx_status
    );
	 
	//===TX===//
  wire bclk, bclk_x8;
  wire [9:0] temp_reg;
  //wire tx_status;
  wire [7:0] data_R;
  reg read_R;
  reg TransmitSignal;
  reg [7:0] data_value;
  
  baudrate #(.baud_sel(0)) br(.clk(clk), .rst(rst), .bclk(bclk), .bclk_x8(bclk_x8));
  transmitter tr(.bclk(bclk), .rst(rst), .ready(TransmitSignal), .data(data_value), .tx_status(tx_status), .tx_data(tx_data));
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
	parameter IDLE = 0, READ_DATA = 1, TRANSMIT_READY = 2, TRANSMIT_DATA = 3, NEXT_VALUE_PREP = 4;
	
	// Level edge detector as we only need to check posedge of read_R_mat signal
	wire read_R_pulse;
	wire slow_clk;
	clk_div #(.cycles(1_00_000_000)) eddy (.clk(clk), .slow_clk(slow_clk));
	level_det ld (.clk(slow_clk), .in(read_R_mat), .pulse(read_R_pulse));
	
	// state registers
	reg [2:0] state, next_state;
	always @ (posedge slow_clk or posedge rst) begin
		if (rst)
			state <= IDLE;
		else 
			state <= next_state;
	end
	
	//reg [2:0] values_sent_count = 3'b0;
	// state change logic
	always @ (*) begin
		next_state = state;
		case (state)
			IDLE: begin
				state_LED = 5'b10000;
				read_R = 1'b0;
				TransmitSignal = 1'b0;
				//values_sent_count = 3'd0;   // Reset count after transmission is done
				read_address_R = 3'd0;      // Reset read address
				if (read_R_pulse) next_state = READ_DATA;
				else next_state = state;
			end
			READ_DATA: begin
				state_LED = 5'b01000;
					//if (values_sent_count < 4 && !read_R_pulse) begin
					if (values_sent_count < 4) begin
						read_R = 1'b1;
						TransmitSignal = 1'b0;
						read_address_R = values_sent_count;              // Update read address
						next_state = TRANSMIT_READY;
					end
					else if (values_sent_count >= 4) next_state = IDLE;
					else next_state = state;
				//end
			end
			TRANSMIT_READY: begin
				state_LED = 5'b00100;
				if (data_R > 0) begin //previously (data_R)
					data_value = data_R;
					read_R = 1'b0;
					TransmitSignal = 1'b1;
					next_state = TRANSMIT_DATA;
					//next_state = NEXT_VALUE_PREP;
				end
				else next_state = state;
			end
			TRANSMIT_DATA: begin
				state_LED = 5'b00010;
				//TransmitSignal = 1'b0;
				//read_R = 1'b0;
				//if (tx_status) begin
					//if (values_sent_count < 4) begin
					//	read_R = 1'b1;
					//	read_address_R = values_sent_count;              // Update read address
					//if (!tx_status)
							next_state = NEXT_VALUE_PREP;
					//else next_state = state;
					//end
					//else next_state = IDLE;
				//end
			end
			NEXT_VALUE_PREP: begin
				state_LED = 5'b00001;
				//state_LEDprep = 1'b1;
				read_R = 1'b0;
				TransmitSignal = 1'b0;
				if (!tx_status) begin
					//values_sent_count = values_sent_count + 3'd1;    // Increment count
						//TransmitSignal = 1'b0;
						//if (!tx_status) 
					next_state = READ_DATA;
				end
				else next_state = state;
			end
			default: next_state = state;
		endcase
	end	
	
	wire TransmitPulse;
	neg_level_edge nle (.clk(clk), .btn(TransmitSignal), .pulse(TransmitPulse));
	always @ (posedge clk) begin
		if(TransmitPulse)
			values_sent_count = values_sent_count + 3'd1;    // Increment count
		
		else if(state_LED == 5'b10000)
			values_sent_count = 3'd0;    // Increment count
		
		
	end
	//end
endmodule

module neg_level_edge(input clk, btn,
								output pulse);
		reg r1, r2, r3;
		initial begin
			r1 <= 0;
			r2 <= 0;
			r3 <= 0;
		end
		
		always @ (posedge clk) begin
			r1 <= btn;
			r2 <= r1;
			r3 <= r2;
		end
		
		assign pulse = ~r2 & r3;
endmodule
