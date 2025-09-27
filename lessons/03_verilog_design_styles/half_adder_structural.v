module half_adder_structural(
	input a,
	input b,
	output sum, 
	output carry
);

	// Instantiate verilog built-in primitives and connect them with nets
	xor XOR1 (sum, a, b);		// instantiate a XOR gate 
	and AND1 (carry, a, b);
endmodule

module testbench();

	// Declare variables and nets for module ports 
	reg a;
	reg b;
	wire sum;
	wire carry;


	// Instantiate the module 
	half_adder_structural HALF_ADD(
		.a(a),
		.b(b),
		.sum(sum),
		.carry(carry)
	);


	// Generate stimulus and monitor module ports 
	initial begin 
		
	end 

	initial begin 
	end


endmodule

