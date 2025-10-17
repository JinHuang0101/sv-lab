// n-bit-1-to-4 demultiplexer
// routes an n-bit intput to one of four n-bit outputs 
// based on a 2bit select signal 

module demux_nbit_x4
	// Parameter to define the width of input/output data buses, 
	// defaulting to 8 bits 
	#( parameter BUS_WIDTH = 8)

	// Ports section 
	(
	input [BUS_WIDTH-1: 0] y,		// n-bit input data to be routed
	input [1:0] sel,				// 2-bit select signal to choose output (0 to 3), 00,01,10,11
	output reg [BUS_WIDTH-1: 0] a,	// n-bit output a (selected when sel=0)
	output reg [BUS_WIDTH-1: 0] b,
	output reg [BUS_WIDTH-1: 0] c,
	output reg [BUS_WIDTH-1: 0] d,
	);

	// Combinational always block: executes whenever y or sel changes 
	always @(*) begin 
		// Initialize all outputs to 0 to avoid latches 
		// and esure only one output is active 
		a=0; b=0; c=0; d=0;

		// Case statement to route intput y to one of the outputs 
		// based on sel 
		case(sel)
			2'd0:	begin a = y; end	// sel = 00: route y to output a 
			2'd1:	begin b = y; end 
			2'd2:	begin c = y; end 
			2'd3:	begin d = y; end 
			default: begin a = y; end	// Default: route y to a (redundant since sel is 2 bits) 
		endcase 
	end 

endmodule 


`timescale 1us/1ns 

module tb_demux_nbit_x4(
);
	parameter BUS_WIDTH = 8;
	wire [BUS_WIDTH-1: 0] a;
	wire [BUS_WIDTH-1: 0] b;
	wire [BUS_WIDTH-1: 0] c;
	wire [BUS_WIDTH-1: 0] d;
	reg [1:0] sel;
	reg [BUS_WIDTH-1:0] y;

	integer i;

	// Instantiate the DUT 
	demux_nbit_x4

		// Pass BUS_WIDTH parameter to the demultiplexer 
		#(.BUS_WIDTH(BUS_WIDTH))
		DEMUX0 (
			.y(y),
			.sel(sel),
			.a(a),
			.b(b),
			.c(c),
			.d(d)
		);

	// Create a stimulus 
	initial begin 
		$monitor($time, "sel = %d, y = %d, a = %d, b = %d, c= %d, d = %d",
				sel, y, a, b, c, d);
		#1; sel = 0; y = 0;

		// Loop to test each sel value twice 
		// cycles sel through 0,1,2,3
		// to increase test coverage so that the tb gets two different random inputs for each output selection 
		for (i = 0; i < 8; i = i+1) begin 
			#1;				// Delay 1us per iteration 
			sel = i%4;		// Cycle sel through 0, 1, 2, 3 (i mod 4) 
			y = $urandom;	// Assign random 8bit value to y
		end 

	end 
	

endmodule 
