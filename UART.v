`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:58:56 10/26/2024 
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
//-------------------------------------- top module --------------------------------------//
module TM_UART(input clk, rst, ready, rx_data,
                  input [7:0] data,
                  output tx_status, tx_data, rx_status,
                  output [7:0] rx_output);
  wire bclk, bclk_x8;
  wire [9:0] temp_reg;
  baudrate #(.baud_sel(0)) br(.clk(clk), .rst(rst), .bclk(bclk), .bclk_x8(bclk_x8));
  transmitter tr(.bclk(bclk), .rst(rst), .ready(ready), .data(data), .tx_status(tx_status), .tx_data(tx_data));
  reciever rc(.bclk_x8(bclk_x8), .rst(rst), .rx_data(rx_data), .rx_status(rx_status), .rx_output(temp_reg));
  assign rx_output = temp_reg[8:1];
endmodule

//-------------------------------------- reciever --------------------------------------//
module reciever(input bclk_x8, rst, rx_data,
                output reg rx_status,
                output reg [9:0] rx_output);
  parameter DATA_SIZE = 8;
  // states
  parameter START = 0, SAMPLE = 1,
  			STORE = 2, END = 3;
  
  reg [2:0] state, next_state;
  always @ (posedge bclk_x8 or posedge rst) begin
    if (rst) state <= START;
    else state <= next_state;
  end

  reg [3:0] bit_counter = 0; // counting the bits we get initially
  reg inc_bit_counter = 0; // for incrementing bit counter
  reg clear_buffer = 0;
  always @ (posedge bclk_x8 or posedge clear_buffer) begin
    if (clear_buffer) bit_counter <= 4'd0;
    else if (inc_bit_counter) bit_counter <= bit_counter + 4'd1;
    else bit_counter <= bit_counter;
  end
  
  // sample counter logic
  reg [3:0] sample_counter = 0;
  reg rst_sample_counter;
  always @ (posedge bclk_x8 or posedge rst_sample_counter) begin
    if (rst_sample_counter) sample_counter <= 4'd0;
    else sample_counter <= sample_counter + 4'd1;
  end
  
  // next state logic
  always @ (*) begin
    next_state = state;
    case (state)
      START: begin if (rx_data == 0) next_state = SAMPLE; else next_state = START; end
      // we want to sample till the second last value, so we can store the next value in rx_register
      SAMPLE: begin if (sample_counter == DATA_SIZE - 2) next_state = STORE; else next_state = SAMPLE; end
      // store needs 8 bits as input as we are also taking stop bit as input
      STORE: begin if(bit_counter == 10) next_state = END; else next_state = SAMPLE; end
      END: next_state = START;
      default: next_state = state;
    endcase
  end
  
  // updating the rx_output
  reg write_reg = 0;
  always @ (posedge bclk_x8 or posedge rst) begin
		if (rst) rx_output <= 10'd0;
		else if (write_reg) rx_output[bit_counter] <= snap_shot[3];
		else rx_output <= rx_output;
  end
  
  reg [7:0] snap_shot = 0;
  // state outputs
  always @ (*) begin
    rst_sample_counter = 0;
    inc_bit_counter = 0;
    clear_buffer = 0;
	 write_reg = 0;
	 snap_shot = snap_shot;
    case(state)
      START: begin
        rx_status = 0;
        rst_sample_counter = 1;
        clear_buffer = 1;
      end
      
      SAMPLE: begin
        rx_status = 1;
        snap_shot[sample_counter] = rx_data;
      end
      
      STORE: begin
        //rx_output[bit_counter] = snap_shot[3];
		  write_reg = 1;
        rx_status = 1;
        inc_bit_counter = 1;
        rst_sample_counter = 1;
      end
      
      END: begin
        rx_status = 0;
      end
      
      default: rx_status = 0;
    endcase
  end
endmodule


//-------------------------------------- transmitter --------------------------------------//
module transmitter(input bclk, rst, ready,
                   input [7:0] data,
                   output reg tx_status, tx_data);
  
  parameter DATA_SIZE = 8; // by default making data 8 bits
  reg [3:0] bit_counter = 0; // counter to count which bit we are transmitting
  // states
  parameter START = 0, LOAD = 1,
  			TR_START = 2, TR_DATA = 3,
  			TR_END = 4;
  
  // state registers
  reg [2:0] state, next_state;
  
  // level edge detector
  //wire ready_pulse;
  level_det ld (.clk(bclk), .in(ready), .pulse(ready_pulse));
 
  always @ (posedge bclk or posedge rst) begin
    if (rst) state <= START;
    else state <= next_state;
  end
  
  always @ (posedge bclk or posedge rst) begin
    if (rst) bit_counter <= 0;
    else if (tx_status) bit_counter <= bit_counter + 4'b1;
    else bit_counter <= -1;
  end
  
  // next state logic
  always @ (*) begin
    next_state = state;
    case (state)
      START: if (ready_pulse) next_state = LOAD;
      LOAD: next_state = TR_START;
      TR_START: next_state = TR_DATA;
      // transmitting from LSB
      TR_DATA: if (bit_counter == DATA_SIZE - 1) next_state = TR_END; // as counting starts from 0, we count 0 to seven
      TR_END: if (!ready_pulse) next_state = START; 
      default: next_state = state;
    endcase
  end
  
  // data reg
  reg [7:0] data_reg;
  reg write_data;
  always @ (posedge bclk or posedge rst) begin
   if (rst) data_reg <= 0;
	else if (write_data) data_reg <= data;
	else data_reg <= data_reg;
  end
  // output
  always @ (*) begin
  write_data = 0;
    case(state)
      START: begin
        tx_status = 0; // no transmission taking place here so tx_status 0
        tx_data = 1; // data line high when we are not sending data
      end
      LOAD: begin
        tx_status = 0;
        tx_data = 1;
		  write_data = 1;
      end
      TR_START: begin
        tx_status = 1;
        tx_data = 0; // sending the start bit
      end
      TR_DATA: begin
        tx_status = 1;
        tx_data = data_reg[bit_counter]; // sending the data bit by bit
      end
      TR_END: begin
        tx_status = 1;
        tx_data = 1; // sending stop bit
      end
      default: begin tx_status = 0; tx_data = 1; end //faizan and zak changed 'tx_data = 1' to 'tx_data = 0' but it apparently it didnt effect.
    endcase
  end
endmodule

//-------------------------------------- baud rate --------------------------------------//
module baudrate(input clk, rst,
                output reg bclk,
                output reg bclk_x8);
  
  // states
  parameter IDLE = 0, TEST = 5,	// does nothing in this state
            S0 = 1, S1 = 2, // S1: 9600, S2: 19200
            S2 = 3, S3 = 4; // S3: 57600, S4: 115200
  
  parameter baud_sel = 0;

  reg [13:0] baud_rate, br_counter; // for transmitter
  reg [10:0] baud_rate_x8, br_x8_counter; // for reciever
  
  // state registers
  reg [2:0] state, next_state;
  always @ (posedge clk or posedge rst) begin
    if (rst) state <= 0;
    else state <= next_state;
  end
  
  // Counter logic
  always @ (posedge clk or posedge rst) begin
    if (rst) begin
      br_counter <= 0;
      br_x8_counter <= 0;
    end
    else begin
      br_counter <= (br_counter < baud_rate - 1) ? br_counter + 14'd1 : 14'd0;
      br_x8_counter <= (br_x8_counter < baud_rate_x8 - 1) ? br_x8_counter + 11'd1 : 11'd0;
      bclk <= (br_counter < baud_rate/2 - 1) ? 1'b0 : 1'b1;
      bclk_x8 <= (br_x8_counter < baud_rate_x8/2 - 1) ? 1'b0 : 1'b1;
    end
  end
  
  // next state logic
  always @ (*) begin
    next_state = state;
    case (baud_sel)
      3'd0: next_state = S0;
      3'd1: next_state = S1;
      3'd2: next_state = S2;
      3'd3: next_state = S3;
      default: next_state = state;
    endcase
  end
  
  // output logic, computing baudrate in terms of clock cycles when using 100MHz clk
  always @ (*) begin
    case(next_state)
      S0: begin baud_rate = 14'd10417; baud_rate_x8 = 11'd1302; end // 9600
      S1: begin baud_rate = 14'd5208; baud_rate_x8 = 11'd651; end // 19200
      S2: begin baud_rate = 14'd1736; baud_rate_x8 = 11'd217; end // 57600
      S3: begin baud_rate = 14'd868; baud_rate_x8 = 11'd109; end // 115200
      // For testing if Data bits are being sent, we set the bclk to 1 Hz
      default: begin baud_rate = 17'd10417; baud_rate_x8 = 11'd1302; end // 9600
    endcase
  end
endmodule
