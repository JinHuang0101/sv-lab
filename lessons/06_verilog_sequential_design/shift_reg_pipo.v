// A 4bit parallel-in, parallel-out(PIPO) shift register module
// This is a pipeline register that captures a 4bit input on each clock edge
// with an async active-low reset 
module shift_reg_pipo(
	input reset_n,
	input clk,
	input [3:0] d,				// 4bit parallel data input 
	output reg [3:0] q			// 4bit parallel data output (stored value)
);
	// Async negative result_n is used 
	// The input data is the same as the output data 
	// This can be used as a "pipeline register"

	// Sequential always block, sensitive to positive edge of clk
	// or negative edge of reset_n, which creates an async reset 

	always @(posedge clk or negedge reset_n) begin 
		
		// negedge reset_n is unreleated to the clock's negative edge;
		// it only addressesses the reset signal's falling edge to impelment the async reset 
		
		// 1, Rising edge of clk: when clk transitions from 0 to 1 and reset_n = 1, q captures d 
		// 2, Falling edge of reset_n: when reset_n transitions from 1 to 0, q is immediately set to 4'b0, 
		// regardless of clk 

		// If reset_n = 0 (active), reset q to 0 immediately
		// including negedge reset_n in the sensitive list triggers the block independently of clk
		if (!reset_n)			
			q <=4'b0;
		else					// 
			q[3:0] <= d[3:0];
	end 

endmodule 


`timescale 1us/1ns

module tb_shift_reg_pipo();

	// Testbench variables 
	reg [3:0] d;
	reg clk = 0;
	reg reset_n;
	wire [3:0] q;
	integer i;

	// Instantiate the DUT
	shift_reg_pipo PIPO0(
		.reset_n(reset_n),
		.clk (clk),
		.d (d),
		.q (q)
	);


	// Create the clock signal 
	always begin 
		#0.5 clk = ~clk;
	end 

	// Create stimulus 
	initial begin 
		#1;
		// Apply reset to the circuit 
		reset_n = 0; d = 0;
		#1.3;
		// release the reset 
		reset_n = 1;

		// Wait for the positive edge of clk 
		// and change the data input d 
		for (i=0; i<5; i=i+1) begin 
			@(posedge clk); d = $random;
		end 
	end 

	// Stop the simulator when the time expires 
	initial begin 
		#20 $finish;
	end 

endmodule 
