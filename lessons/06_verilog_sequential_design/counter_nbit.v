// Implements a parameterized N-bit binary counter that increments by 1
// on each rising clock edge when reset_n = 1, 
// with an asynchronous active-low reset 
// to clear the counter to 0

module counter_nbit

	// Parameters section 
	
	#( parameter CNT_WIDTH = 3)		// Parameter to set counter width (default 3 bits)

	// Ports section 
	(
	input clk,
	input reset_n,
	output reg [CNT_WIDTH-1:0] counter
	);

	// Use non-blocking assignment for sequential logic 
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			counter <= 0;
		else				// If reset_n=1, increment counter on rising clock edge
			counter <= counter + 1'b1;
	end 

endmodule 


// Set simulation time scale 
`timescale 1us/1ns

// Define testbench module for the N-bit counter 
module tb_counter_nbit();

	// Testbench variables 
	parameter CNT_WIDTH = 3;
	reg clk = 0;
	reg reset_n;
	wire [CNT_WIDTH-1:0] counter;

	// Instantiate the DUT 
	counter_nbit
		// Parameters section 
		#(.CNT_WIDTH(CNT_WIDTH))
			CNT_NBIT0
		// Ports section 
		(.clk(clk),
		 .reset_n(reset_n),
		 .counter(counter)
		);


	// Create the clock signal 
	always begin 
		#0.5 clk = ~clk;

	end 


	// Create stimulus 
	initial begin 
		$monitor($time, "counter = %d", counter);
		#1; 
		reset_n = 0;		// Reset counter to 0
		#1.2;				// Wait 1.2us with reset active  
		reset_n = 1;		// Release reset to allow counting 
	end 



	// Initial block to control simulation duration 
	initial begin 
		#20;
		$stop;
	end 

endmodule 

