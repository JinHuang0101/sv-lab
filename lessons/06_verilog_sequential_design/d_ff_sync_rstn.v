// The D flip-flop: edge-triggered memory element that captures data
// on the rising edge of the clock, with a synchronous reset 
// The reset operationis part of the sequential logic's clocked behavior 
// Clock dependency: requires a clock edge to activate the reset 
// Timing Predicatability: Reset occurs at precise clock edges, aligning with the system's sync design 
// Sync designs (e.g., CPUs, counters) where all state changes are clock-driven 
// Avoids glitches or partial resets since the reset is only effective on clock edges 
// Requires a clock signal to be active, so reset won't occur if the clock is stopped

module d_ff_sync_rstn(
	input reset_n,		// Active-low reset input (sync with clk)
	input clk,			// Clockinput (positive edge-triggered)
	input d,			// Data input(1 bit)
	output reg q,
	output q_not
);
	
	// Sequential always block, sensitive to positive edge of clk
	// The D flip-flop is positive edge-triggered
	// reset_n is synchronous with the clk signal 
	always @(posedge clk) begin 
		// Use non-blocking operator (<=) for sequential logic 
		// Check reset_n on rising clock edge 
		if (!reset_n)			// The reset only resets q to 0 when a rising edge of clk occurs
								// Meaning, if reset_n changes between clock edges,
								// it has no immediate effect on q.
								// The reset is aligned with the clock's rising edge,
								// ensuring the reset operation is part of the system's synchronous timing 
			q <= 1'b0;
		else					// If reset_n = 1, capture d on clock edge 
			q <= d;
	end 

	assign q_not = ~q;

endmodule 


`timescale 1us/1ns 

module tb_d_dff_rstn();

	// Testbench variables 
	reg d;
	reg clk = 0;
	reg reset_n;
	wire q;
	wire q_not;
	reg [1:0] delay;			// 2bit register for randomly delay (1 to 4us)
	integer i;

	// Instantiate the DUT
	d_ff_sync_rstn DFF0(
		.reset_n(reset_n),
		.clk (clk),
		.d(d),
		.q(q),
		.q_not(q_not)
	);


	// Always block to generate clock signal
	// 1 MHz, 50% duty cycle 
	always begin 
		#0.5 clk = ~clk;		// Toggle clk every 0.5us (1us period, 1 MHz)
	end 


	// Create stimulus 
	initial begin 
		reset_n = 0; d = 0;		// Initialize: reset active(reset_n = 0), d = 0

		// First loop: test with reset active (reset_n = 0)
		for (i=0; i<5; i=i+1) begin 
			delay = $random+1;		// Generate random delay (1 to 4us, since $random is 32bit
			// but only lower bits used)
			#(delay) d = ~d;		// Wait for random delay, then toggle d
		end 

		reset_n = 1;		// Release reset (allow normal operation)

		// Second loop: test with reset inactive (reset_n = 1)
		for (i=0; i<5; i=i+1) begin 
			delay = $random+1;		// Generate another random delay (1 to 4us)
			#(delay) d= ~d;			// Wait for random delay, toggle d to test FF capture
		end 
		#(0.2); reset_n = 0;		// After 0.2us, assert reset again to test reset behavior
	end 


	// Initial block to control simulation duration 
	initial begin 
		#40; 
		$finish;
	end 

endmodule 

