// Implements a divide-by-3 clock divider that generates an output clock clock_out
// with a frequency one-third of the input clock (clock_in)
// and a 50% duty cycle, using three flip-flops (A,B,C) and an OR gate,
// with an asynchronous active-low reset
// When reset_n=1, the ffs create a state sequence that results in clock_out
// having a period three times that of clock_in (e.g., 3us for a 1us input period)

// FFs A, B, and C form a state machine where qa, qb, and qc create a sequence
// that repeats every three clock_in cycles 
module clock_div3(
	input clock_in,				// Input clock to be divided 
	input reset_n,
	output clock_out			// Divide-by-3 clock output (wire type)
);

	// Internal variables for the FFs
	reg qa, qb, qc;				// Registers for flip-flops A, B, C

	// Flip-flops A and B - triggered on positive clock edge
	always @(posedge clock_in or negedge reset_n)
	begin 
		if (!reset_n) begin 
			qa <= 1'b0;
			qb <= 1'b0;
		end else begin				// If reset_n=1, update on rising clock_in edge
			qa <= (~qa) & (~qb);	// qa = NOT the current value of qa and NOT the current value of qb
									// Next state of qa is the AND of the inverted current qa and qb
			qb <= qa;				// qb takes the previous value of qa 
		end
	end 


	// Flip-flop C - triggered on negative clock edge 
	always @(negedge clock_in or negedge reset_n)
	begin
		if(!reset_n)
			qc <= 1'b0;
		else			// If reset_n=1, update on falling clock_in edge 
			qc <= qb;	// qc = previous qb 
	end 


	// Make the final OR gate (makes 50% duty cycle)
	// The OR gate ensures clock_out is high for half its period 
	assign clock_out = qb | qc;

endmodule 

`timescale 1us/1ns

module tb_clock_div3();
	
	// Testbench variables 
	reg clk = 0;
	reg reset_n;
	wire clock_out;


	// Instantiate the DUT
	clock_div3 CLK_DIV0
	(
	.clock_in(clk),
	.reset_n(reset_n),
	.clock_out(clock_out)
	);


	// Create the clock signal 
	always begin
		#0.5 clk = ~clk;
	end 


	// Create stimulus 
	initial begin 
		#1; reset_n = 0;			// reset qa, qb, qc to 0
		@(posedge clk);				// Wait for next rising clk edge (1.5us)
		reset_n = 1;				// Release reset to start operation 
		repeat(20) @(posedge clk);	// Wait for 20 rising clock edges (20us)
		$stop;
	end 

endmodule 


