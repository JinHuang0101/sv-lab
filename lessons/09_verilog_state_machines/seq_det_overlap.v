module seq_det_overlap(
		input clk,
		input rst_n,
		input seq_in,
		output reg detected,
		output [1:0] state_out
);

		parameter [1:0] IDLE = 2'd0,
						GOT1 = 2'd1,
						GOT10 = 2'd2;

		reg [3:0] state;
		reg [3:0] next_state;

		always @(*) begin 
			detected = 1'b0;
			case(state)
				IDLE		: begin 
							if (seq_in == 1) next_state = GOT1;
							else			 next_state = IDLE;
						end 
				GOT1		: begin 
							if (seq_in == 0) next_state = GOT10;
							else			 next_state = GOT1;
						end 
				GOT10	: begin 
							if (seq_in == 1) begin 
									next_state = GOT1;		// Overlap: reuse last '1'
									detected = 1'b1;
							end else begin 
									next_state = IDLE;
							end 
						end 

				default: next_state = IDLE;
			endcase 

		end 


endmodule 

`timescale 1us/1ns

module tb_seq_det_overlap();
		reg clk = 0;
		reg rst_n;
		reg seq_in;
		wire detected;
		wire [1:0] state_out;

		reg [0:13] test_vect = 14'b00_1100_0101_0101;
		integer i;

		seq_det_overlap SEQ_DET0(
				.clk		(clk),
				.rst_n		(rst_n),
				.seq_in		(seq_in),
				.detected	(detected),
				.state_out	(state_out)
		);

		initial begin 
			forever begin 
				#1	clk = ~clk;
			end 
		end 

		initial begin 
			$monitor($time, " seq_in = %b, detected = %b", seq_in, detected);

			rst_n = 0; #2.5; rst_n = 1;
			repeat(2) @ (posedge clk);

			for(i=0; i<14; i=i+1) begin 
				seq_in = test_vect[i];
				@(posedge clk);
			end 

			for(i=0; i<15; i=i+1) begin 
				seq_in = $random;
				$(posedge clk);

			end 

			repeat(10) @(posedge clk);
			@(posedge clk);

			#40 $stop;

		end 

endmodule 

