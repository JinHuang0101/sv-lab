module mux_4x_nbit 
	// Parameters section 
	#( parameter BUS_WIDTH = 8)
	// Ports section 
	(
	input [BUS_WIDTH-1:0] a,
	input [BUS_WIDTH-1:0] b,
	input [BUS_WIDTH-1:0] c,
	input [BUS_WIDTH-1:0] d,
	input [1:0] sel,
	output reg [BUS_WIDTH-1:0] y
	);

	always @(*) begin 
		case (sel)
			2'd0: begin y = a; end 
			2'd1: begin y = b; end 
			2'd2: begin y = c; end 
			2'd3: begin y = d; end 
			default: begin y = a; end 
		endcase 
	end 


endmodule 

`timescale 1us/1ns 
module tb_mux_4x_nbit(
	// no inputs here 
);

	parameter BUS_WIDTH = 8;
	reg [BUS_WIDTH-1:0] a;
	reg [BUS_WIDTH-1:0] b;
	reg [BUS_WIDTH-1:0] d;
	reg [BUS_WIDTH-1:0] d;
	reg [1:0] sel;
	wire [BUS_WIDTH-1:0] y;
	integer i;

	// Instantiate the DUT
	mux_4x_nbit
		MUX0(
		);

	// Create stimulus
	initial begin 
	end 


endmodule 
