`timescale 1us/1ns

module compare_nbit_func
	// Parameters section 
	# (parameter CMP_WIDTH = 4)

	// Ports section 
	(
	input [CMP_WIDTH-1:0] a,
	input [CMP_WIDTH-1:0] b,
	output reg greater,			// High if a > b
	output reg equal,			// High if a == b
	output reg smaller			// High if a < b
	);


	// Synthesizable functions area (parameterized)
	// All 3 bits are combined into a single output 
	function [2:0] compare (input [CMP_WIDTH-1:0] a, 
							input [CMP_WIDTH-1:0] b);
		// Function takes two inputs of width CMP_WIDTH, 
		// returns 3-bit result 
		
		// Local variables 
		reg greater_local;
		reg equal_local;
		reg smaller_local;

		begin // The actual computation from the function
			greater_local = (a>b);		// 1 if true, else 0
			equal_local = (a==b);		// 1 if true, else 0
			smaller_local = (a<b);		// 1 if true, else 0

			// Pack 3 bits into return value
			compare = {greater_local, equal_local, smaller_local};

		end 
	endfunction 

	// The RTL description of the combinational comp
	
	always @(*) begin		// sensitivity list: run this block whenever any input signal used inside changes
							// input a and b 
							// always @(a or b)
		
		// Step 1: function call--compare(a, b)
		// The function call on the right
		// returns a 3-bit value [2:0]

		// Step 2: Concatenation (left)
		// The left is a port assginment target 
		// Concatenation of three 1-bit reg variables 

		// Step 3: unpack
		// Right side has a 3-bit result, e.g., 3'b100
		// Left side: unpack into three 1-bit outputs:
		// greater: 1, equal: 0, smaller: 0
		{greater, equal, smaller} = compare(a,b);
	end 


endmodule

`timescale 1us/1ns

module tb_compare_nbit_func();
	
	// Testbench variables 
	parameter CMP_WIDTH = 5;
	reg [CMP_WIDTH-1:0] a, b;
	wire greater, equal, smaller;

	// Instantiate the DUT
	compare_nbit_func
		#(.CMP_WIDTH(CMP_WIDTH))
		
		CMP0
		(
		.a(a),
		.b(b),
		.greater(greater),
		.equal(equal),
		.smaller(smaller)
		);

	initial begin 
		$monitor ($time, "a=%d, b=%d, greater = %b, equal = %b, smaller = %b",
						a, b, greater, equal, smaller);
		#1 a = 3; b = 2;
		#1 b = 3;
		#1 a = 9; b = 11;

	end 
		






endmodule 

