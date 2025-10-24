// Implements a parameterized N-bit counter 
// that counts from 0 to N-1 (modulo-N)
// and wraps around to 0 when reaching N-1,
// with an asynchronous active-low reset and enable control 

module counter_modulo_n
	// Parameters section 
	#(parameter N=10,			// Modulo value (counts from 0 to N-1, default 10)
		parameter CNT_WIDTH=4)	// Counter width in bits (default 4 bits)

	// Ports section 
	(
	input clk,
	input reset_n,
	input enable,					// Enable input (1=count, 0=hold)
	output reg [CNT_WIDTH-1:0] counter_out
	);

	// Use non-blocking assignment for sequential logic 
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			counter_out <= 0;
		else if (enable) begin				// If enable=1, count or wrap around 
			if (counter_out == (N-1)) begin // If counter reaches N-1 (e.g., 9 for N=10)
				counter_out <= 0;			// Wrap around to 0
			end else begin 
				counter_out <= counter_out + 1'b1;		// Increment counter 
			end 
		end
		// If enable = 0, counter_out holds its value (no assignment)
	end 

endmodule 


`timescale 1us/1ns 

module tb_counter_modulo_n();
	// Testbench variables 
	parameter CNT_WIDTH = 4;
	parameter N = 10;

	reg clk =0;
	reg reset_n;
	reg enable;
	wire [CNT_WIDTH-1:0] counter_out;


	// Instantiate the DUT 
	counter_modulo_n
		// Parameters section 
		#(.N(N),
		  .CNT_WIDTH(CNT_WIDTH))
		
		// Ports section
		CNT_MODN0(
		.clk (clk),
		.reset_n (reset_n),
		.enable (enable),
		.counter_out (counter_out)
		);

	// Create the clock signal
	always begin 
		#0.5 clk = ~clk;
	end 

	// Create stimulus 
	initial begin 
		$monitor ($time, "enable = %b, counter_out = %d",
					enable, counter_out);
		#1;  
		reset_n = 0; enable = 0;		// Reset:set reset_n=0, disable counting
		#1.2;							// Wait 1.2us with reset active 
		reset_n = 1;					// Release reset to allow operation 
		repeat(3) @(posedge clk);		// Wait for 3 rising clock edges (3us, until 5.5 us)
		enable = 1;						// Enable counting 
		repeat(14) @(posedge clk);		// Count for 14 clock cycles (14us, until 19.5us)
		$stop;

	end 


endmodule 

