// An 8-bit shift register module with load and left/right shift capabilities 

module shift_left_right_load_reg(
	input clk,
	input reset_n,
	input [7:0] i,
	input load_enable,			// Load/shift control (0 for load i, 1 = shift) 
	input shift_left_right,		// Shift direction(0 = left, 1 = right) 
	output reg [7:0] q
);

	// Async negative reset is used 
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			q <= 8'b0;
		else if (load_enable == 1'b0)		// if load_enable = 0, load parallel input i
			q <= i;
		else begin							// if load_enable = 1, perform shift operation  
			if (shift_left_right == 1'b0) begin 
				q <= {q[6:0], 1'b0};	// shift left: q[7]=q[6],...,q[0] = 0 
			end else begin 
				q <= {1'b0, q[7:1]};	// shift right: q[7]=0, q[6]=q[7],...q[0]=q[1]
			end 

		end 

	end 

endmodule 

`timescale 1us/1ns 

module tb_shift_left_right_reg();

	// Testbench variables 
	reg clk = 0;		// clk is a register initially set to 0
	reg reset_n;
	reg [7:0] i;
	reg load_enable;			// Register for load/shift control 
	reg shift_left_right;		// Register for shift direction control 
	wire [7:0] q;


	// Instantiate the DUT 
	shift_left_right_load_reg SRL0(
		.clk(clk),
		.reset_n(reset_n),
		.i(i),
		.load_enable(load_enable),
		.shift_left_right(shift_left_right),
		.q(q)
	);


	// Create the clock signal 
	// Starting at time 0us, clk = 0
	// At 0.5us, clk toggles to 1 (rising edge)
	// At 1.0us, clk toggles to 0 (falling edge)
	// At 1.5us, clk toggles to 1 (rising edge)
	// At 2.0us, clk toggles to 0 (falling edge)
	//....repeating every 1us
	// Rising edges: 0.5us, 1.5us, 2.5us, 3.5us, 
	// Falling edges: 1us, 2us, 3us, 4us
	always begin 
		#0.5 clk = ~clk;
	end 

	// Create stimulus 
	initial begin 
		$monitor($time, "i=%8b, load_enable=%1b, shift_left_right=%1b, q=%8b",
				i, load_enable, shift_left_right, q);
		#1;
		reset_n=0; i=0; load_enable=0; shift_left_right=0;
		#1.3; 
		reset_n=1;		// At 2.3us

		// Set the vlaue of i
		@(posedge clk); i = 8'b1111_1111;		// At 2.5us, which is the next clocking edge after 2.3us
		@(posedge clk); load_enable = 1'b1;		// Enable shifting left 

		// Wait for the bits to shift left 
		repeat (5) @(posedge clk);
		@(posedge clk); load_enable = 1'b0; i = 8'b1010_1000;
		@(posedge clk); load_enable = 1'b1; shift_left_right = 1;
		repeat (5) @(posedge clk);
		@(posedge clk);
	end 

	// Simulator time control 
	initial begin 
		#40 $finish;
	end 



endmodule 


