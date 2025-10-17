// 7-segment display decoder module: 
// decodes a 4bit binary input (representing hex values 0-15)
// into a 7bit pattern suitable for driving a common 7-segment LED display
// segments labeled a through g, with an additional decimal point (dot) output
module hex_7seg_decoder(
	input [3:0]in,			// 4bit input representing hex value 0-15
	output reg a,			// output for segment a of 7segment display
	output reg b,
	output reg c,
	output reg d,
	output reg e,
	output reg f,
	output reg g,
	output dot				// output for decimal point (dot) on the display
);

	// Combinational always block: executes whenever "in" changes 
	// Use concatenation to assign values to all segment outputs simultaneously
	always @(*) begin 
		// Case statement to select 7bit pattern based on input value (0-15)
		// Each pattern is a binary code where 1 means segment is ON, 0 means OFF 
		case (in)
		4'd0:	{a,b,c,d,e,f,g} = 7'b1111110;	// Pattern for '0': segments a,b,c,d,e,f ON (g OFF)
		4'd1 : {a,b,c,d,e,f,g} = 7'b0110000;
		4'd2 : {a,b,c,d,e,f,g} = 7'b1101101; 
		4'd3 : {a,b,c,d,e,f,g} = 7'b1111001;
		4'd4 : {a,b,c,d,e,f,g} = 7'b0110011;
		4'd5 : {a,b,c,d,e,f,g} = 7'b1011011;  
		4'd6 : {a,b,c,d,e,f,g} = 7'b1011111;
		4'd7 : {a,b,c,d,e,f,g} = 7'b1110000;
		4'd8 : {a,b,c,d,e,f,g} = 7'b1111111;
		4'd9 : {a,b,c,d,e,f,g} = 7'b1111011;
		4'd10: {a,b,c,d,e,f,g} = 7'b1110111;	// Pattern for 'A' (hex 10) 
		4'd11: {a,b,c,d,e,f,g} = 7'b0011111;
		4'd12: {a,b,c,d,e,f,g} = 7'b1001110;
		4'd13: {a,b,c,d,e,f,g} = 7'b0111101;
		4'd14: {a,b,c,d,e,f,g} = 7'b1001111;
		4'd15: {a,b,c,d,e,f,g} = 7'b1000111;
		endcase 
	end 

	// Continuous assignment: always set the decimal point (dot) to ON(1)
	assign dot = 1'b1;

endmodule 


`timescale 1us/1ns 

module tb_hex_7seg_decoder();
	
	// testbench variables 
	reg [3:0]in;				// Register for 4bit input to the decoder 
	wire a, b, c, d, e, f, g;	// Wires for 7segment outputs 
	wire dot;
	integer i;					// Integer for loop counter 

	// Instantiate the DUT: the hex_7seg_decoder module   
	hex_7seg_decoder DEC_7SEG(
		.in(in),		// Connect input 
		.a(a),			// Connect segment a output 
		.b(b),
		.c(c),
		.d(d),
		.e(e),
		.f(f),
		.g(g),
		.dot(dot)
	);

	// Initial block to generate stimulus and monitor outputs   
	initial begin 
		// Monitor statement: display time, input value, concatenated 7segment code (as binary)
		// and dot at each change 
		$monitor($time, "in=%d, seven_seg_code=%7b dot=%1b",
				in, {a,b,c,d,e,f,g}, dot);
		#1; in=0;		// Delay 1us, then set input to 0 (start with '0' pattern)

		// For loop to test all inputs from 0 to 15(covers hex 0-F)
		for (i=0; i<16; i=i+1) begin 
			#1; in=i;		// Delay 1us, then set input to current loop value 
		end 
	end 

endmodule 

