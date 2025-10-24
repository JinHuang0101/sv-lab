// A parameterized N-bit up/down counter 
// that can load a parallel input, count up or down,
// and has an async active-low reset.
// The counter operates based on load_en and up_down controls.

module counter_up_down_load_nbit
	// Parameters section
	#( parameter CNT_WIDTH=3)

	// Ports section
	(
	input clk,
	input reset_n,
	input load_en,			// Load enable (1=load counter_in, 0=count)
	input [CNT_WIDTH-1:0] counter_in,		// N-bit parallel input for loading 
	input up_down,							// Direction control (1=count up, 0=count down)
	output reg [CNT_WIDTH-1:0] counter_out	// N-bit counter output 
	);


	// Use non-blocking assignment for sequential logic 
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			counter_out <= 0;
		else if (load_en)			// If load_en = 1, load counter_in (has priority)
			counter_out <= counter_in;
		else begin					// If load_en =0, count up or down based on up_down 
			if (up_down == 1'b1) begin 
				counter_out <= counter_out + 1'b1;		// Count up 
			end else begin 
				counter_out <= counter_out - 1'b1;		// Count down 
			end 
		end 
	end 

endmodule 

// Set simulation time scale 
`timescale 1us/1ns

// Define testbench module 
module tb_counter_up_down_load_nbit();
	// Testbench variables 
	parameter CNT_WIDTH = 3;
	reg clk = 0;
	reg reset_n;
	reg load_en;
	reg [CNT_WIDTH-1:0] counter_in;			// Register for parallel input 
	reg up_down;							// Register for direction control
	wire [CNT_WIDTH-1:0] counter_out;		// Wire for N-bit counter output 


	// Instantiate the DUT 
	counter_up_down_load_nbit
		// Parameters section 
		#(.CNT_WIDTH(CNT_WIDTH))			// Pass CNT_WIDTH parameter (3 bits)

		// Ports section 
		CNT_UP_DOWN0(						// Connect 
			.clk (clk),
			.reset_n (reset_n),
			.load_en (load_en),
			.up_down (up_down),
			.counter_in (counter_in),
			.counter_out (counter_out)
		);


	// Create the clock signal 
	always begin 
		#0.5 clk = ~clk;					// Toggle clk every 0.5us (1us period, 1 MHz)
	end 


	// Create stimulus 
	initial begin 
		$monitor ($time, " load_en = %b, up_down = %b, counter_in = %d, counter_out = %d",
					load_en, up_down, counter_in, counter_out);
		#1; 
		reset_n = 0; load_en = 0; counter_in = 0; up_down = 0;		// Reset and set to count down  
		#1.2;					// Wait 1.2us with reset active 
		reset_n = 1;			// Release reset to allow operation 	
		@(posedge clk);				// Wait for rising clock edge (2.5us)
		repeat(2) @(posedge clk);		// Wait for 2 more clock edges (3.5us, 4.5us)
		counter_in = 3; load_en = 1;	// At 4.5us, set input to 3, enable load 
		@(posedge clk);					// Wait for next clock edge (5.5us)
		load_en = 0; up_down = 1;		// Disable load, set to count up

		wait(counter_out == 0) up_down = 0;		// Wait until counter_out=0, then count down 

	end 


	//Simulation duration control 
	initial begin
		#20;
		$stop;
	end 
endmodule 

