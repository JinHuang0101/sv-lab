// Implements a clock divider that generates a divide-by-2 clock signal, 
// and includes an N-bit counter from the counter_nbit module 
// Both are controlled by an asynchronous active-low reset 
// clk_div2: Generates a clock signal with half the frequency of the input clk
// counter: Provides an N-bit counter value that increments on each rising clk edge, 
// counting from 0 to 2^n - 1 (e.g., 0 to 15 for CNT_WIDTH=4)
// The counter is driven by the counter_nbit module, which increments counter on each clk edge when reset_n=1
// The counter is used to track the number of clock cycles, useful for timing events, 
// generating sequences, or triggering actions after a specific count 
// This single component offers a divided clock and a cycle count, which are often needed together in digital systems 
// E.g., a system might use clk_div2 to drive slower logic 
// and counter to monitor how many input clock cycles have passed, 
// enabling coordinated timing control 
// Both clk_div2 and counter are driven by the same input clock (clk) and reset(reset_n)
// Divide-by-2 clock: a clock siganl whose frequency is half that of the input clock, 
// thus its period is twice that of the input clock 

// input clk toggles every 0.5us (half the time unit), 
// while clk_div2 toggles every 1us(full clk cycle),
// resuing in a period twice as long (2us).
module clock_div_nbit 
	// Parameters section 
	#( parameter CNT_WIDTH = 4)

	// Ports section 
	(
	input clk,
	input reset_n,
	output reg clk_div2,				// Divided clock output (frequency halved)
	output [CNT_WIDTH-1:0] counter		// N-bit counter output (wire, driven by counter_nbit)
	);

	// Make a separate divider by two 
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			clk_div2 <= 0
		else								// If reset_n=1, toggle clk_div2 on each rising clk edge
			clk_div2 <= ~clk_div2;			// feedback loop creates divide-by-2 clock 
			// Feedback loop: the self-referential assignment where the next value of 
			// clk_div2 depends on its current value
			// That is, the output of clk_div2 is fed back as an input to itself 
			// This creates a toggle flip-flop, where the state of clk_div2
			// alternates with each clock cycle, 
			// The inversion is scheduled on each rising edge of clk 
			// So clk_div2 toggles every 1us,
			// on each rising clk edge,
			// the duration of one full clk cycle 
			// So, one full cycle of clk_div2 (0 to 1 to 0), requires
			// 2us for one complete cycle of clk_div2

	end 

	// Instantiate the counter_nbit module with the same CNT_WIDTH 
	counter_nbit 
		#(.CNT_WIDTH(CNT_WIDTH))		// Pass CNT_WIDTH parameter (4bits)
		CNT_NBIT0
		(
		.clk (clk),						// Connect input clock
		.reset_n(reset_n),				// Connect reset input
		.counter(counter)				// Connect counter output 
		);

endmodule 


module counter_nbit 
	// Parameters section 
	#( parameter CNT_WIDTH = 3)

	// Ports section 
	(
	input clk,
	input reset_n,
	output reg [CNT_WIDTH-1: 0] counter
	);


	// Use non-blocking assignment for sequential logic 
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			counter <= 0;
		else
			counter <= counter + 1'b1;
	end 

endmodule 

`timescale 1us/1ns

module tb_clock_div_nbit();

	// Testbench variables 
	parameter CNT_WIDTH = 4;
	reg clk = 0;
	reg reset_n;
	wire clk_div2;
	wire [CNT_WIDTH-1:0] counter;

	// Instantiate the DUT
	clock_div_nbit 
		// Parameters section 
		#(.CNT_WIDTH(CNT_WIDTH))

		// Ports section 
		CLK_DIV0
		(
		.clk (clk),
		.reset_n(reset_n),
		.clk_div2(clk_div2),
		.counter(counter)
		);


	// Create the clock signal 
	// This is the input clock
	// which toggles every 0.5us (half a microsecond)
	always begin 
		#0.5 clk = ~clk;
	end 


	// Create stimulus 
	initial begin 
		#1;
		reset_n = 0;
		#1.2;
		reset_n = 1;
		repeat(20) @ (posedge clk);
		$stop;
	end 


	

endmodule 

