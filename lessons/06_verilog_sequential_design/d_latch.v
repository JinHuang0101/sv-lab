// Define a D latch module: captures the input d when enable is high(1) and holds the value when enable is low (0)
//
module d_latch(
	input d,			// Data input: 1 bit 
	input enable,		// Enable input: controls when d is captured 
	output q,			// Output, a wire: stored value 
	output q_not		// Complementary output: inverse of q
);
	
	reg dlatch;			// Internal register to store the latch state 

	// Combinational always block, sensitive to enable and d
	// The D latch is level sensitive 
	always @(enable or d) begin
		if (enable)				// When enable = 1, latch is transparent 
			dlatch <= d;		// Capture d into dlatch 
			// when enable = 0, no assignment (dlatch holds its previous value)
	end 

	// Continuous assignments for outputs 
	assign q = dlatch;		// continuously assigned the value of dlatch
							// makes q the external interface for the stored value, visible to other modules 
	assign q_not = ~q;		// q_not is the logical inverse of q 

endmodule 


`timescale 1us/1ns

module tb_d_latch();
	
	// Testbench variables 
	reg d;				// Register for data input
	reg enable;			// Register for enable input 
	wire q;				// Wire for q output 
	wire q_not;			// Wire for q_not output 

	// Instantiate the DUT
	d_latch DL0(
		.d(d),					// Connect data input
		.enable(enable),		// Connect enable input 
		.q(q),					// Connect q output 
		.q_not(q_not)			// Connect q_not output 
	);



	// Initial block to generate stimulus and monitor outputs 
	initial begin 
		$monitor($time, "enable = %b, d = %b, q = %b, q_not = %b",
						 enable, d, q, q_not);
		enable = 0;			// Initialize enable to 0, latch holds state 
		#2; d = 0;
		#0.5; d = 1;
		#1; d = 0;
		#1; d = 1;
		#1.5; enable = 1;	// At 6us, set enable=1 (latch becomes transparent)
		#0.1; d = 1;
		#0.2; d = 0;
		#0.3; d = 1;
		#1; enable = 0; d = 0;
		#1; d = 1;
		#2; d = 0;
	end 

	// Stop the simulator when the time expires 
	initial begin 
		#40;
		$finish;
	end 

endmodule 
