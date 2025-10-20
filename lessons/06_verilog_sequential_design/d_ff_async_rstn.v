// A D flip-flop that is an edge-triggered memory element
// that captures data on the rising edge of the clock,
// with an asynchronous reset that acts immediately
// Active-low reset: a reset signal that activates its function (resetting a circuit to a known state, typically 0)
// when the signal is at a logic low level (0).
// An active-high reset would activate when the signal is high.
// $random: generates a 32bit signed random number, which can range from -2,147,483,648 to +2,147,483,647
// When $random is assigned to a 2bit register (delay), only the two LSB of the 32bit random number
// are used, because a 2bit register can only hold values 0 to 3
module d_ff_async_rstn(
	input reset_n,
	input clk,				// positive edge-triggered clock input 
	input d,
	output reg q,
	output q_not
);
	
	// The D-Flip Flop has a positive edge clock
	// reset_n is asynchronous with the clk signal 
	// Use non-blocking opereator for sequential logic 
	always @(posedge clk or negedge reset_n) begin 
		
		// Use non-blocking operator (<=) for sequential logic 
		if (!reset_n)		// If reset_n = 0(active), reset q to 0 immediately 
			q <= 1'b0;
		else				// If reset_n = 1, capture d on rising clock edge 
			q <= d;
	end 

	// Continous assignment for complementary output 
	assign q_not = ~q;

endmodule 

`timescale 1us/1ns 

module tb_d_ff_rstn();

	// Testbench variables
	reg d;
	reg clk = 0;
	reg reset_n;
	wire q;
	wire q_not;
	reg [1:0] delay;		// delay is a 2bit register capable of holding values from 0 to 3 (00, 01, 10, 11)
	integer i;

	// Instantiate the DUT 
	d_ff_async_rstn DFF0(
		.reset_n(reset_n),
		.clk (clk),
		.d (d),
		.q (q),
		.q_not (q_not)
	);


	// Create the clk signal (1 MHz, 50% duty cycle) 
	always begin 
		#0.5 clk = ~clk;		// Toggle clk every 0.5us (1us period, 1 MHz)
	end 


	// Create stimulus 
	initial begin 

		// First loop: test with reset active (starts with reset_n = 0)
		reset_n = 0; d = 0;				// Initialize: reset active (reset_n=0), d=0
		for (i=0; i<5; i=i+1) begin 
			delay = $random + 1;		// introduce random timing to reset the D ff's behavior 
			#(delay) d = ~d;
		end 

		// Second loop: test with reset inactive (starts with reset_n = 1)
		reset_n = 1;
		
		for (i=0; i<5; i=i+1) begin 
			delay = $random + 1;
			#(delay) d = ~d;		// toggle d to test FF capture 
		end 
		#(0.2);
		reset_n = 0;				// assert reset again to test asynchronous reset behavior 
	end 

	// Stop the simulator when the time expires 
	initial begin 
		#40 $finish;
	end 

endmodule 


