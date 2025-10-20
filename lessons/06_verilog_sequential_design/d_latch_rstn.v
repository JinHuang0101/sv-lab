// A D latch module with an active-low reset and its testbench 
// An asynchronous reset takes effect immediately when the reset signal is asserted
// regardless of the clock or enable signal
// The reset is independent of any clock or timing signal, acting as soon as reset_n changes to 0
// Reset occurs instantly, even if no clock is present 
// Immediate reset, useful for initializing a circuit without waiting for a clock edge (e.g., during power-up)
// Can introduce timing issues, like glitches, needs to avoid race conditions

module d_latch_rstn(
	input d,
	input enable,
	input reset_n,			// Active-low reset input (0 resets latch)
	output q,
	output q_not
);
	
	reg dlatch;

	// The D-latch is level sensitive
	always @(enable or d or reset_n) begin 
		if (!reset_n)			// Reset takes priority, acts immediately, dlatch set to 0
								// regardless of the state of enable or any clock
								// The reset has priority over the enable condition 
			dlatch <= 1'b0;
		else if(enable)			// If reset_n = 1 and enable = 1, latch is transparent 
			dlatch <= d;		// Capture d into dlatch 
	end 

	// If reset_n = 1 and enable = 0, dlatch holds its previous value (no assignment)

	assign q = dlatch;
	assign q_not = ~q;

endmodule 

`timescale 1us/1ns

module tb_d_latch_rstn();
	
	// Testbench variables 
	reg d;
	reg enable;
	reg reset_n;
	wire q;
	wire q_not;


	// Instantiate the DUT
	d_latch_rstn DL0(
		.d(d),
		.enable(enable),
		.reset_n(reset_n),
		.q(q),
		.q_not(q_not)
	);


	// Create stimulus 
	initial begin 
		$monitor($time, "enable = %b, d = %b, q = %b, q_not = %b",
				enable, d, q, q_not);
		enable = 0; reset_n = 0;
		#2; d = 0;
		#0.5; d = 1;
		#1;  d = 0;
		#1;  d = 1;
		#1.5;  enable = 1;
		#0.1  d = 1;
		#0.2; d = 0; reset_n = 1;
		#0.3; d = 1;
		#1;   enable = 0; d = 0;
		#1;  d = 1;  reset_n = 0;
		#2;  d = 0;
	end 


	// This will stop the simulator when the time expires 
	initial begin 
		#40 $finish;
	end 

endmodule 
