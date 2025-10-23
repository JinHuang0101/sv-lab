// Define a 4bit serial-in, parallel-out(SIPO) shift register module 
// A SIPO takes a single bit input (sdi) and shifts into a multi-bit register (q) on each clock cycle 
// The existing bits in q move left, and the new bit (sdi) enters at the lowest index(q[0])
// After four clock cycles, four serial bits are collected in q[3:0], available as a parallel output
// E.g., if initially q = 4'b0000 and sdi = 1,0,1,0,
// then after four cycles, q = 4'b1010
// This is a shift register. It collects serial data into a parallel format
// Useful in applications like serial communication protocols (SPI, UART)
// where data is received bit-by-bit and then


module shift_reg_sipo(
	input reset_n,
	input clk,
	input sdi,		// serial data input (1bit)
	output reg [3:0] q			// 4-bit parallel output (stored value)
);

	// Async negative reset_n is used 
	// The input data is serial (sdi), shifted into q 
	// The output data is parallel (q[3:0])

	// Sequential always block, sensitive to positive edge of clk
	// or negative edge of reset_n
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			q <= 4'b0;
		else		// If reset_n = 1, shift q left, insert sdi at LSB  

			// q[3:0]: the entire 4bit vector of q
			// the right-hand side: 
			// creates a 4bit vecotr by concatenating q[2], q[1], q[0], and sdi
			q[3:0] <= {q[2:0], sdi};	//{} concatenation: combining multiple signals into a single vector 
			// result:
			// q[3] = q[2] (previous q[2] shifts to q[3])
			// q[2] = q[1] (previous q[1] shifts to q[2])
			// q[1] = q[0] (previous q[0] shifts to q[1])
			// q[0] = sdi (new serial input sdi enters at the least significant bit)
			// This implements a left shift operation, where the contents of q shift one position left
			// and the new bit (sdi) is inserted into q[0]
	end 
endmodule 

`timescale 1us/1ns
module tb_shift_reg_sip();
	
	// Testbench variables
	reg sdi;				
	reg clk = 0;
	reg reset_n;
	wire [3:0] q;


	// Instantiate the DUT 
	shift_reg_sipo SIPO0(
	);

	// Create the clock signal 
	always begin #0.5 clk = ~clk; end 

	// Create stimulus 
	initial begin 
		#1;
		reset_n = 0; sdi = 0;		// set reset_n=0, regardless sdi value, q is reset to 0
		// Including sdi=0 here, is an explicit initialization, setting all inputs to known values (0) during reset
		// making the testbench more readable and predictable 

		// Future-proofing: if the module logic changes later (e.g., someone accidentally removes
		// the reset priority), sdi=0 ensures a clean starting state 

		// Convention: common testbench practice to initialize all signals
		// during reset phases 

		// Documentation: signals intent that the system starts from an all-zero state 
		#1.3;
		reset_n = 1;				// Release reset to allow normal operation 
		repeat(2) @(posedge clk);	// Wait for 2 rising edges of the clock signal clk 
		// Since the clock has a 1us period(rising edges every 1us)
		// repeat(2) @(posedge clk) causes a delay of 2us(2 clock cycles), 
		// as it waits for 2 rising edges 


		// Set sdi for 1 clock 
		@(posedge clk);			// Wait for next rising clock edge (3us) 
		sdi = 1'b1;				// Set sdi=1 (q={q[2:0], 1})
		@(posedge clk);			// Wait for next clock edge (4us)
		sdi = 1'b0;

		// Set sdi for 2 clocks 
		repeat(4) @(posedge clk);		// Wait for 4 clock edges (5us to 8us)
		@(posedge clk); sdi = 1'b1;		// At 9us, set sdi = 1 
		repeat(2) @(posedge clk); sdi = 1'b0;		// At 11us, set sdi = 0

		// Set sdi with '101' during 3 clocks 
		repeat(3) @(posedge clk); sdi = 1'b1;		// At 14us, set sdi = 1
		@(posedge clk); sdi = 1'b0;					// At 15us, set sdi = 0
		@(posedge clk); sdi = 1'b1;					// At 16us, set sdi = 1
		@(posedge clk); sdi = 1'b0;					// At 17us, set sdi = 0
	end 

	// Initial block to control stimulation duration  
	initial begin 
		#40;
		$finish;
	end 

endmodule 

