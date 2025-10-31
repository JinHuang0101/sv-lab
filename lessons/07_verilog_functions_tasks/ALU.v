module ALU
	// Parameters section 
	#( parameter BUS_WIDTH=8)
	// Ports section 
	(
	input [BUS_WIDTH-1:0] a,
	input [BUS_WIDTH-1:0] b,
	input carry_in,
	input [3:0] opcode,
	output reg [BUS_WIDTH-1:0] y,
	output reg carry_out,
	output reg borrow,
	output zero,
	output parity,
	output reg invalid_op
	);

	// Define a list of opcodes 
	localparam OP_ADD = 1
	localparam OP_ADD_CARRY = 2;
	localparam OP_SUB = 3;       // Subtract B from A
    localparam OP_INC = 4;       // Increment A
    localparam OP_DEC = 5;       // Decrement A
    localparam OP_AND = 6;       // Bitwise AND
    localparam OP_NOT = 7;       // Bitwise NOT
    localparam OP_ROL = 8;       // Rotate Left
    localparam OP_ROR = 9;       // Rotate Right 

	always @(*) begin 
		y = 0;
		carry_out = 0;
		borrow = 0;
		invalid_op = 0;

		case (opcode)
			OP_ADD	: begin y = a + b; end 
			OP_ADD_CARRY: begin {carry_out, y} = a + b + carry_in; end 
			OP_SUB	: begin {borrow, y} = a - b; end 
			OP_INC	: begin {carry_out, y} = a + 1'b1; end 
			OP_DEC	: begin {borrow, y} = a - 1'b1; end 
			OP_AND	: begin y = a & b; end 
			OP_NOT	: begin y = ~a; end 
			OP_ROL	: begin y = {a[BUS_WIDTH-2:0], a[BUS_WIDTH-1]}; end 
			OP_ROR	: begin y = {a[0], a[BUS_WIDTH-1:1]}; end 
			default	: begin invalid_op = 1; y = 0; carry_out = 0; borrow = 0; end 

		endcase 

	end 

	assign parity = ^y;
	assign zero = (y == 0);
endmodule 


`timescale 1us/1ns

module tb_ALU();

	// Testbench variables 
	parameter BUS_WIDTH = 8;
	reg [3:0] opcode;
	reg [BUS_WIDTH-1:0] a, b;
	reg carry_in;
	wire [BUS_WIDTH-1:0] y;
	wire carry_out;
	wire borrow;
	wire zero;
	wire parity;
	wire invalid_op;


	// Define a list of opcodes 
	localparam OP_ADD	= 1;
	localpapram OP_ADD_CARRY	= 2;
	localparam	OP_SUB	= 3;
	localparam	OP_INC	= 4;
	localparam	OP_DEC  = 5;
	localparam  OP_AND  = 6;
	localparam  OP_NOT  = 7;
	localparam  OP_ROL  = 8;
	localparam  OP_ROR  = 9;
	integer success_count = 0, error_count = 0, test_count = 0, i = 0;


	// Instantiate the DUT
	ALU
	#(.BUS_WIDTH(BUS_WIDTH))
	ALU0
	(
	.a (a),
	.b (b),
	.carry_in (carry_in),
	.opcode (opcode),
	.y (y),
	.carry_out (carry_out),
	.borrow (borrow),
	.zero (zero),
	.parity (parity),
	.invalid_op (invalid_op)
	);

	// This is used to model the ALU behavior at testbench level 
	// for creating the expected data.
	// model_ALU = {invalid_op, parity, zero, borrow, carry_out, [BUS_WIDTH-1:0] y}
	// The size of model_ALU is BUS_WIDTH-1+5 = BUS_WIDTH+4
	



	// Compare the outputs of the ALU with the outputs of the model_ALU


	// Create stimulus 



endmodule