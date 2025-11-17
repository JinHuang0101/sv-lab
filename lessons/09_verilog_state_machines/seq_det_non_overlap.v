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
		parameter [1:0] S1 = 2'd0,			// State name: S1, assigned value: decimal 0, starting state 
						S10 = 2'd1,			// State name: S10, assigned value: decimal 1
						S101 = 2'd2;		// State name: S101, assigned value: decimal 2

		// Declare the logic for the state machine 
		reg [3:0] state;
		reg [3:0] next_state;

		// Next state logic 
		always @(*) begin 
			detected = 1'b0;

			case(state)
				S1: begin 
						if (seq_in == 1) next_state = S10;
						else			 next_state = S1;
					end 

				S10: begin 
						if (seq_in == 0) next_state = S101;
						else			 next_state = S10;
					 end 

				S101: begin 
						if (seq_in == 1) begin 
							detected = 1'b1;
						end 
						next_state = S1;
					end 

				default: next_state = S1;
			endcase 

		end 

		// State sequencer logic 
		always @(posedge clk or negedge rst_n) begin 
			if(!rst_n)
				state <= S1;
			else
				state <= next_state;

		end 

		assign state_out = state;

endmodule 

`timescale 1us/1ns

module tb_seq_det_non_overlap();

endmodule 

