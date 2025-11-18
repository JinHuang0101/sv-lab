module seq_det_non_overlap(
		input clk,
		input rst_n,
		input seq_in,		// serial input data stream
							// the single bit that arrives one bit per clock cycle 
							// This is the stream that the sequence detector that needs to watch
							// to look for the pattern 101
		output reg detected,
		output [1:0] state_out 
);

		// Declare the state values as parameters using binary values 
		parameter [1:0] IDLE = 2'd0,			// State name: IDLE, assigned value: decimal 0 (2'b00), starting state 
												// nothing seen yet
						GOT_1 = 2'd1,			// State name: GOT_1, assigned value: decimal 1 (2'b01)
												// have seen '1'
						GOT_10 = 2'd2;		// State name: S101, assigned value: decimal 2 (2'b10)
											// have seen '10'

		// Declare the logic for the state machine 
		reg [3:0] state;
		reg [3:0] next_state;

		// Next state logic 
		always @(*) begin 
			detected = 1'b0;

			case(state)
				IDLE: begin 
						if (seq_in == 1) next_state = GOT_1;
						else			 next_state = IDLE;
					end 

				GOT_1: begin 
						if (seq_in == 0) next_state = GOT_10;
						else			 next_state = GOT_1;
					 end 

				GOT_10: begin 
						if (seq_in == 1) begin 
							detected = 1'b1;
						end 
						next_state = IDLE;
					end 

				default: next_state = IDLE;
			endcase 

		end 

		// State sequencer logic 
		always @(posedge clk or negedge rst_n) begin 
			if(!rst_n)
				state <= IDLE;
			else
				state <= next_state;

		end 

		assign state_out = state;

endmodule 

`timescale 1us/1ns

// Verify that the non-overlapping 101 sequence detector works correctly 
// Feeds a known bit pattern + random bits
// checks when detected goes high 

module tb_seq_det_non_overlap();
	
	// Signals 
	reg clk = 0;		// Clock starts at 0
	reg rst_n;			// active-low reset 
	reg seq_in;			// the serial input bit (one per clock)
	wire detected;		// output: 1 when '101' is found
	wire [1:0] state_out;		// for debugging (shows current state)

	// The main test pattern 
	// 14 bits: from MSB to LSB, fed from left to right 
	// 0011_0001_0101_01
	reg [0:13] test_vect = 14'b00_1100_0101_0101;
	integer i;		// loop counter 

	// DUT instantiation 
	seq_det_non_overlap SEQ_DET(
		.clk (clk),
		.rst_n (rst_n),
		.seq_in (seq_in),
		.detected (detected),
		.state_out (state_out)
	);

	// clock signal generation 
	initial begin 
		forever begin 
			#1 clk = ~clk;
		end 
	end 

	// Main stimulus 
	initial begin 
		$monitor ($time, " seq_in = %b, detected = %b, state = %d", 
							seq_in, detected, state_out);
		
		// reset sequence 
		rst_n = 0;		// assert reset  
		#2.5; 
		rst_n = 1;		// release reset 

		repeat(2) @ (posedge clk);		// wait 2 clock cycles for settling 

		// Feed the known test vecotr (14 bits)
		for (i=0; i<14; i = i+1) begin 
			seq_in = test_vect[i];		// Apply next bit 
			@(posedge clk);				// Wait until clock rises 
										// FSM waits for the rising edge to reads seq_in
		end 

		for(i=0; i<15; i=i+1) begin 
			seq_in = $random;
			@(posedge clk);
		end 

		// Idle for a while 
		repeat(10) @(posedge clk);
		@(posedge clk);

		#40 $stop;			// Stop simulation 

	end 

endmodule 

