module ALU
	// Parameters section
	#( parameter BUS_WIDTH = 8)		// Parameter to define the width of input/output data buses, defaulting to 8 bits 
	// Ports section 
	(
	input [BUS_WIDTH-1:0] a,
	input [BUS_WIDTH-1:0] b,
	input carry_in,
	input [3:0] opcode,				// 4bit operation code to select ALU operation 
	output reg [BUS_WIDTH-1: 0] y,
	output reg carry_out,
	output reg borrow,
	output zero,					// Flag indicating if result is zero 
	output parity,					// Flag indicating parity of the result 
	output reg invalid_op
	);

	// Define a list of opcodes
	localparam OP_ADD	= 1;  // A + B
	localparam OP_ADD_CARRY = 2; // A + B + Carry 
	localparam OP_SUB = 3;		// Subtract B from A 
	localparam OP_INC = 4;		// Increment A 
	localparam OP_DEC = 5;		// Decrement A 
	localparam OP_AND = 6;		// Bitwise AND 
	localparam OP_NOT = 7;		// Bitwise NOT 
	localparam OP_ROL = 8;		// Rotate Left 
	localparam OP_ROR = 9;		// Rotate Right 

	// Combinational logic block
	always @(*) begin
		// Initialize outputs to default values to avoid latches 
		y=0; carry_out = 0; borrow = 0; invalid_op = 0;
		// Case statement to select operation based on opcode 
		case (opcode)
			OP_ADD	: begin y = a + b; end 
			// Add a, b, and carry_in, store carry in carry_out 
			OP_ADD_CARRY:	begin {carry_out, y} = a + b + carry_in; end 
			OP_SUB:	begin {borrow, y} = a - b; end 
			// Increment a by 1 bit, store carry in carry_out 
			OP_INC:	begin {carry_out, y} = a + 1'b1; end 
			// Decrement a by 1, store borrow in borrow 
			OP_DEC: begin {borrow, y} = a - 1'b1; end 
			OP_AND: begin y = a & b; end 
			OP_NOT:	begin y = ~a; end 

			// Rotate left: shift a left by 1, move MSB to LSB 
			OP_ROL:	begin 
				y = {a[BUS_WIDTH-2:0], A[BUS_WIDTH-1]}; 
			end 

			// Rotate right: shift a right by 1, move LSB to MSB 
			OP_ROR: begin 
				y = {a[0], a[BUS_WIDTH-1:1]}; 
			end 
			default: begin 
				invalid_op = 1;				// Set invalid_op flag for unrecognized opcode  
				y = 0; carry_out = 0; borrow = 0;		// Reset outputs for invlaid operation 
			end 
		endcase 

	end 

	// Assign parity flag: XOR reduction of y to check if number of 1s is even or odd
	assign parity = ^y;

	// Assign zero flag: true if y is all zeros 
	assign zero = (y == 0);

endmodule 

// Set simulation time scale: 1 microsecond time unit, 1 nanosecond precision 
`timescale 1us/1ns

// Define testbench module for ALU 
module tb_ALU();

	// Testbench variables 
	parameter BUS_WIDTH = 8;		// Match BUS_WIDTH with ALU module 
	reg [3:0] opcode;				// Register for opcode input 
	reg [BUS_WIDTH-1:0] a, b;		// Registers for input operands 
	reg carry_in;
	wire [BUS_WIDTH-1:0] y;			// Wire for ALU output result 
	wire carry_out;
	wire borrow;
	wire zero;
	wire parity;
	wire invalid_op;

	// Instantiate the ALU module (Device Under Test)
	ALU
	// Parameters section, pass BUS_WIDTH parameter to ALU instance  
	#(.BUS_WIDTH(BUS_WIDTH))
	ALU0
	(
	.a(a),					// Connect a input 
	.b(b),
	.carry_in(carry_in),			// Connect carry_in input 
	.opcode(opcode),
	.y(y),							// Connect y outupt 
	.carry_out(carry_out),			// Connect carry_out output 
	.borrow(borrow),
	.zero(zero),
	.parity,
	.invalid_op(invalid_op)
	);

	// Initial block to create stimulus for testing  
	initial begin 
		$monitor($time, "opcode = %d, a = %d, b = %d, y = %d, carry_out = %b, borrow = %b, zero = %b, parity = %b, invalid_op = %b"
				opcode, a, b, y, carry_out, borrow, zero, parity, invalid_op);
		#1; opcode = 0;				// Delay 1us, set invalid opcode to test default case 
		// Test OP_ADD 
		#1 opcode = 1; a = 9; b = 33; carry_in = 0;
		// Test OP_ADD_CARRY	9+33+1
		#1 opcode = 2; a = 9; b = 33; carry_in = 1;
		// Test OP_SUB	65-64
		#1 opcode = 3; a = 65; b = 64; carry_in = 0;
		// Test OP_SUB 65-66 (to check borrow)
		#1 opcode = 3; a = 65; b = 66; carry_in = 0;
		// Test OP_INC
		#1 opcode = 4; a = 233; b = 69; carry_in = 1;
		// Test OP_DEC
		#1 opcode = 5; a = 0; b = 3; carry_in = 0;
		// Test OP_AND 
		#1 opcode = 6; a = 8'b0000_0010; b = 9'b0000_0011;
		// Test OP_NOT 
		#1 opcode = 7; a = 8'b1111_1111;
		// Test OP_ROL
		#1 opcode = 8; a = 8'b0000_0001;
		// Test OP_ROR
		#1 opcode = 9; a = 8'b1000_0000;
		#1 $stop;

	end 

endmodule

