// A 16-bit Linear Feedback Shift Register (LFSR) module
// It generates a pseudo-random sequence of 16-bit values 
// based on a feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1
// with an async reset and enable control 
// The LFSR shifts left on each clock cycle when enabled, 
// with feedback computed via XOR 
// and includes an asynchronous reset to a non-zero seed 

module lfsr_16(
	input clk,
	input reset_n,
	input enable,
	output reg [15:0] lfsr		// 16-bit LFSR output register 
);

	// Seed has to be non-zero to ensure LFSR generates a sequence 
	localparam RST_SEED = 16'h1001;		// Initial seed value (non-zero)
	wire feedback;						// Wire for feedback term based on polynomial 

	// Define feedback for the polynomial x^16 + x^14 + x^13 + x^11 + 1
	// XOR of bits 15, 13, 12, and 10 of lfsr 
	assign feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];

	// Sequential always block, sensitive to positive edge of clk or 
	// negative edge of reset_n
	always @(posedge clk or negedge reset_n)
	begin
		if(!reset_n)		// If reset_n=0(active), reset lfsr to seed value 
			lfsr <= RST_SEED;
		else if (enable == 1'b1)	// If enable=1, shift lfsr left and insert feedback 
			lfsr <= {lfsr[14:0], feedback}; 
			// Shift left: lfsr[15]=lfsr[14],...lfsr[0]=feedback 
	end 

endmodule

// Set simulation time scale: 1 microsecond time unit, 1 nanosecond precision 
`timescale 1us/1ns 

// Define testbench module for the LFSR
module tb_lfsr_16();

	// Testbench variables 
	reg clk = 0;			// Input
	reg reset_n;			// Input 
	reg enable;				// Input 
	wire [15:0] lfsr;		// Output 

	// Instantiate the DUT 
	lfsr_16 LFSR(
		.clk (clk),			// Connect input
		.reset_n(reset_n),
		.enable(enable),
		.lfsr(lfsr)			// Connect output 
	);

	// Create the clock signal 
	always begin 
		#0.5 clk = ~clk;
	end 

	// Create stimulus 
	initial begin 
		$monitor($time, " enable = %d, lfsr = 0x%x", enable, lfsr);
		#1;							// Wait 1us to settle initial conditions 
		reset_n = 0; enable = 0;	// Reset: set reset_n = 0, disable shifting 
		#1.2;						// Wait 1.2us with reset active
		reset_n = 1;				// Release reset to allow normal operation 
		repeat(2) @(posedge clk);	// Wait for 2 rising clock edges (2us)
		enable = 1;					// Enable LFSR shifting 

		repeat(10) @(posedge clk);	// Shift for 10 clock cycles (10us)
		enable = 0;					// Disable shifting 
	end 


	// Initial block to control simulation duration
	initial begin 
		#20 $stop;
	end 
endmodule 

