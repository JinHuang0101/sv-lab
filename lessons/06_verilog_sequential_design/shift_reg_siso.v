// The module shifts a single-bit serial input into a 4-bit register
// and outputs the most significant bit as a serial output
// with an asynchronous active-low reset 

module shift_reg_siso(
	input reset_n,
	input clk,
	input sdi,		// serial data input (1 bit) 
	output sdo		// serial data output (1 bit, from MSB)  
);
	
	// Internal 4 bits wide register 
	reg [3:0] siso;

	// Async negative reset is used
	// The input data is the same as the output data 
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			siso <= 4'b0;
		else			// If reset_n=1, shift siso left and insert sdi at LSB 
			siso[3:0] <= {siso[2:0], sdi};
			// siso[3] = siso[2], siso[2] = siso[1], siso[1] = siso[0], siso[0] = sdi
	end 

	// Connect the sdo net to the register MSB 
	assign sdo = siso[3];	// Output sdo is the most significant bit of siso 

endmodule 


// <time_unit> / <time_precision>
// time_unit: the base unit of time for all time-related operations in the module
// ...eg., #5 means 5 times the time unit 
// time_precision: the smallest increment of time that the simulator can resolve, 
// affecting how precise delay calculations and scheduling are 
// 1us/1ns: 1 microsecond is the time unit and 1 nanosecond is the time precision 
`timescale 1us/1ns

module tb_shift_reg_siso();

	// Testbench variables 
	reg sdi;
	reg clk = 0;
	reg reset_n;
	wire sdo;

	// Instantiate the DUT 
	shift_reg_siso SISO0(
		.reset_n(reset_n),
		.clk(clk),
		.sdi(sdi),
		.sdo(sdo)
	);

	// Create the clock signal 
	always begin #0.5 clk = ~clk; end	// Because the timeunit is 1us, so #0.5 means 0.5 microseconds
										// Toggle clk every 0.5us


	// Create stimulus 
	initial begin 
		#1;
		reset_n = 0; sdi = 0;

		#1.3;	// release the reset
				// 1.3us = 1300ns, precise to the nearest nanosecond 
		reset_n = 1;

		// Set sdi for 1 clock 
		@(posedge clk); sdi = 1'b1; @(posedge clk); sid = 1'b0;

		// Wait for the bit to shift 
		repeat (5) @(posedge clk);
		@(posedge clk); sdi = 1'b1;
		@(posedge clk);
		@(posedge clk); sdi = 1'b0;
	end 


	// Simulation duration control 
	initial begin 
		#40 $finish;
	end 

endmodule 

