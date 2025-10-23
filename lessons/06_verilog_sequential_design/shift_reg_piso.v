// The module load a 4bit parallel input or shift a serial input
// into a 4bit register, outputting the most significant bit serially,
// with an async active-low reset 


module shift_reg_piso(
	input clk,
	input reset_n,
	input sdi,		// Serial data input (1 bit)
	input pl,		// Preload control (1=load parallel data, 0=shift serial data)
	input [3:0] d,	// 4bit parallel data input 
	output sdo		// Serial data output (1 bit from MSB)
);

	// Internal 4-bit wide register to store data  
	reg [3:0] piso;

	// Wire to hold the data source (parallel d or shifted {piso[2:0], sdi})
	wire [3:0] data_src;		// nets after the mux'es 

	// If pl == 1, use parallel input d;
	// If pl == 0, use shifted data {piso[2:0], sdi}
	// ?: conditional operator, 2-to-1 multiplexer 
	// condition ? expression_if_true : expression_if_false
	//if pl = 1 (true), data_src = d, selecting the parallel input 
	// if pl = 0 (false), data_src = {piso[2:0], sdi} , selecting the shifted data
	assign data_src = pl ? d : {piso[2:0], sid};	// Mux: selects parallel load or serial shift

	// Async negative reset is used 
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			piso <= 4'b0;
		else		// If reset_n=1, update piso with data_src on clock edge 
			piso[3:0] <= data_src;		// Load d(if pl=1) or shift {piso[2:0], sdi} (if pl=0)
	end 

	// Connect the sdo net to the register MSB 
	assign sdo = piso[3];	// Output sdo is the MSB of piso 

endmodule 


`timescale 1us/1ns 

module tb_shift_reg_piso();

	// Testbench variables 
	reg sdi;
	reg [3:0] d;
	reg preload;		// Register for preload control (pl)
	reg clk = 0;
	reg reset_n;
	wire sdo;			// Wire for serial data output 
	reg [1:0] delay;
	integer i;


	// Instantiate the DUT
	shift_reg_piso PISO0(
		.clk(clk),
		.reset_n(reset_n),
		.sdi(sdi),
		.pl(preload),
		.d(d),
		.sdo(sdo)
	);

	// Create the clock signal (1 MHz, 50% duty cycle)
	always begin 
		#0.5 clk = ~clk;	// Toggle clk every 0.5us (1us period, 1MHz)
	end 


	// Create stimulus 
	initial begin 
		#1;
		reset_n = 0; sdi = 0; preload = 0; d = 0;	// clear inputs 
		#1.3;
		reset_n = 1;		// Release reset to allow normal operation 

		// Set sdi for 1 clock 
		@(posedge clk);
		d = 4'b0101;		// Set parallel input to 0101
		preload = 1;		// Enable preload to load d 
		@(posedge clk);		// Wait for next rising clock edge (3.5us)
		preload = 0;		// Disable preload to resume serial shifting
							// data_src = {piso[2:0], sdi}
							// sdi = 0 (set at 1us, unchanged)
							// So on the next rising edge (4.5us),
							// piso <= {piso[2:0], sdi} = {010, 0} = 4'b0100
							// sdo = piso[3]=0 (MSB of 0100)

		// Wait for the bits to shift 
		repeat(5) @(posedge clk);	// 4.5us to 9.5us
									// preload remains 0
									// each cycle shifts piso left, inserting sdi into piso[0]
									// The serial shift mode is active, but because sdi=0 is constant
									// only 0s are shifted into piso[0]
	end 


	// Simulation duration control 
	initial begin 
		#40 $finish;
	end 

endmodule 

