// ALU Module (Parametrized 8-bit ALU)
// The actual hardware logic 
// The ALU module is RTL (not behavioral, will be put on the silicon)
// Synthesizable: can be turned into real logic gates, becomes real hardware  
module ALU
	// Parameters  
	#( parameter BUS_WIDTH=8)

	// Ports  
	(
	input [BUS_WIDTH-1:0] a,
	input [BUS_WIDTH-1:0] b,
	input carry_in,					// 1-bit carry
	input [3:0] opcode,				// 4-bit selector 
	output reg [BUS_WIDTH-1:0] y,	// main result (registered, combinational update)
	output reg carry_out,			// registered flags 
	output reg borrow,				// registered flags
	output reg invalid_op,			// registered flags
	output zero,					// combinational wires (assigned later)
	output parity					// combinational wires (assigned later)
	);

	// Define a list of opcodes
	// Named constants 
	localparam OP_ADD = 1;
	localparam OP_ADD_CARRY = 2;
	localparam OP_SUB = 3;       // Subtract B from A
    localparam OP_INC = 4;       // Increment A
    localparam OP_DEC = 5;       // Decrement A
    localparam OP_AND = 6;       // Bitwise AND
    localparam OP_NOT = 7;       // Bitwise NOT
    localparam OP_ROL = 8;       // Rotate Left
    localparam OP_ROR = 9;       // Rotate Right 

	// Combinational logic
	// Recomputes whenever any input changes 
	always @(*) begin 
		y = 0;						// Default assignments prevent latches 
		carry_out = 0;
		borrow = 0;
		invalid_op = 0;

		case (opcode)
			OP_ADD	: begin {y} = a + b; end 
			OP_ADD_CARRY: begin {carry_out, y} = a + b + carry_in; end		// Concatenation, MSB carry_out 
			OP_SUB	: begin {borrow, y} = a - b; end				// Concatenation, MSB is the flag(borrow), lower part is y
			OP_INC	: begin {carry_out, y} = a + 1'b1; end			// Concatenation, MSB carry_out
			OP_DEC	: begin {borrow, y} = a - 1'b1; end				// Concatenation, MSB borrow  
			OP_AND	: begin y = a & b; end 
			OP_NOT	: begin y = ~a; end 
			OP_ROL	: begin y = {a[BUS_WIDTH-2:0], a[BUS_WIDTH-1]}; end
			// take bits [6:0] and append the original MSB a[7]

			OP_ROR	: begin y = {a[0], a[BUS_WIDTH-1:1]}; end 
			// take the LSB(a[0]) and prepend it to bits [7:1]

			default	: begin invalid_op = 1; y = 0; carry_out = 0; borrow = 0; end 

		endcase 

	end 

	// Continuous assignments (combinational)
	// no registers, pure wires 
	assign parity = ^y;			// Reduction XOR, 1 if odd number of 1s 
	assign zero = (y == 0);		// 1 (high) if y (the whole result) is zero 
endmodule 


`timescale 1us/1ns

// Testbench: tb_ALU
module tb_ALU();

	// Testbench variables 
	parameter BUS_WIDTH = 8;			// Re-declares the same width for the testbench

	reg [3:0] opcode;					// reg (stimulus registers) drive the DUT 
	reg [BUS_WIDTH-1:0] a, b;
	reg carry_in;

	wire [BUS_WIDTH-1:0] y;				// response wires capture the DUT outputs 
	wire carry_out;
	wire borrow;
	wire zero;
	wire parity;
	wire invalid_op;


	// Define a list of opcodes (same as DUT)
	// same list as DUT 
	localparam OP_ADD	= 1;
	localparam OP_ADD_CARRY	= 2;
	localparam	OP_SUB	= 3;
	localparam	OP_INC	= 4;
	localparam	OP_DEC  = 5;
	localparam  OP_AND  = 6;
	localparam  OP_NOT  = 7;
	localparam  OP_ROL  = 8;
	localparam  OP_ROR  = 9;

	// Counters for reporting pass/fail statistics  
	integer success_count = 0, error_count = 0, test_count = 0, i = 0;


	// DUT Instantiation 
	// Instantiate the ALU with the same width
	// connects every port 
	// to produce the observed ALU

	// ALU instantiated in testbench 
	// Produces real outputs 
	// This is the design being tested 

	// Put a real ALU block here and wire it up 

	// Instantiate: plug in a hardware block 

	// ALU is instantiated, so it becomes a block 
	// Only the instantiated ALU is synthesized, then it becomes gates 
	ALU #(.BUS_WIDTH(BUS_WIDTH)) ALU0 (		// ALU0 is an instance of the ALU module 
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

	// GOLDEN MODEL: model_ALU (Behavioral Reference)
	// Lives in testbench, never becomes silicon 
	// Defined inside tb_ALU
	// A function - pure behavioral code 
	// Never instantiated in the ALU module 
	// Never synthesized 
	// Computes expected result based on inputs 
	// This is the reference, the truth 

	// Not connected to any DUT signal 
	// Runs independently in the testbench 
	// Runs in simulation 

	// Exactly the same arithmetic/logic as the DUT
	// Written as a function so the testbench can call it with the same stimulus
	// and obtain the expected packed result 
	// to produce the expected 


	function [BUS_WIDTH+4:0] model_ALU(
			input [3:0] opcode,
			input [BUS_WIDTH-1:0] a,
			input [BUS_WIDTH-1:0] b,
			input carry_in
		);
			// Local variables used to model the ALU behavior 
			reg [BUS_WIDTH-1:0] y;
			reg carry_out;
			reg borrow;
			reg zero;
			reg parity;
			reg invalid_op;

			begin 
				y = 0; carry_out = 0; borrow = 0; invalid_op = 0;
				case (opcode)
					OP_ADD	:	begin {carry_out, y} = a + b; end 
					OP_ADD_CARRY : begin {carry_out, y} = a + b + carry_in; end 
					OP_SUB	:	begin {borrow, y} = a - b; end 
					OP_INC  :	begin {carry_out, y} = a + 1'b1; end 
					OP_DEC	:	begin {borrow, y} = a - 1'b1;  end 
					OP_AND	:	begin y = a & b; end 
					OP_NOT	:	begin y = ~a; end 
					OP_ROL	:	begin y = {a[BUS_WIDTH-2:0], a[BUS_WIDTH-1]}; end 
					OP_ROR	:	begin y = {a[0], a[BUS_WIDTH-1:1]}; end 
					default: begin invalid_op = 1; y = 0; carry_out = 0; borrow = 0; end 
				endcase 

				parity = ^y;
				zero = (y == 0);
				model_ALU = {invalid_op, parity, zero, borrow, carry_out, y};
			end 
	endfunction 

	// Self-Checking Task 
	// Compare the outputs of the ALU with the outputs of the model_ALU


	task compare_data(input [BUS_WIDTH+4:0] expected_ALU, 
					  input [BUS_WIDTH+4:0] observed_ALU);
		begin 

			if (expected_ALU === observed_ALU) begin		// === bit-exact comparison 
				$display($time, "SUCCESS \t EXPECTED invalid_op=%0d, parity=%b, zero=%b, carry_out=%b, y=%b",
								expected_ALU[BUS_WIDTH+4], expected_ALU[BUS_WIDTH+3], expected_ALU[BUS_WIDTH+2],
								expected_ALU[BUS_WIDTH+1], expected_ALU[BUS_WIDTH], expected_ALU[BUS_WIDTH-1:0]
								);
				$display($time, "\t OBSERVED invalid_op=%0d, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b",
								observed_ALU[BUS_WIDTH+4], observed_ALU[BUS_WIDTH+3], observed_ALU[BUS_WIDTH+2],
								observed_ALU[BUS_WIDTH+1], observed_ALU[BUS_WIDTH], observed_AL[BUS_WIDTH-1:0]);
				success_count = success_count + 1;
			end else begin 
				$display($time, " ERROR \t EXPECTED invalid_op=%0d, parity=%b, zero=%b, carry_out=%b, y=%b",
								expected_ALU[BUS_WIDTH+4], expected_ALU[BUS_WIDTH+3], expected_ALU[BUS_WIDTH+2],
								expected_ALU[BUS_WIDTH+1], expected_ALU[BUS_WIDTH], expected_ALU[BUS_WIDTH-1:0]);
				$display($time, " \t OBSERVED invalid_op=%0d, parity=%b, zero=%b borrow=%b, carry_out=%b, y=%b",
								observed_ALU[BUS_WIDTH+4], observed_ALU[BUS_WIDTH+3], observed_ALU[BUS_WIDTH+2],
								observed_ALU[BUS_WIDTH+1], observed_ALU[BUS_WIDTH], observed_ALU[BUS_WIDTH-1:0]);
				error_count = error_count + 1;
			end 
			test_count = test_count + 1;

		end 
	endtask 

	// STIMULUS generation: 1000 Random Tests 
	initial begin 
		for(i=0; i<1000; i=i+1) begin 
			opcode = $random % 10'd11;		// 0... 10 (covers 0-9 + default)
			a = $random;
			b = $random;
			carry_in = $random;

			#1;	// give some time to the combinational circuit to compute (propagation delay)
			
			$display($time, " TEST%0d opcode = %0d, a = %0d, b = %0d, carry_in = %0b",
					i, opcode, a, b, carry_in);

			compare_data(
						model_ALU(opcode, a, b, carry_in),	// expected (from the Golden-model as a testbench function)
						{invalid_op, parity, zero, borrow, carry_out, y}	// observed (from DUT instance), DUT output ports, actual output wires from the instantiated ALU0
						);

			#2;		// wait some time before the next test 
		end 

		// Print statistics 
		$display($time, " TEST RESULTS success_count = %0d, error_count = %0d, test_count = %0d",
						success_count, error_count, test_count);
		#40 $stop;
	end 

endmodule