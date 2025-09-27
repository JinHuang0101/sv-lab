module ripple_adder_4bit_structural(
	input [3:0] a,
	input [3:0] b,
	input carry_in,
	output [3:0] sum,
	output carry_out
);
	
	// Internal nets used to connect all 4 modules 
	full_adder_structural FA_STRUCT_0(
		.a(a[0]),
		.b(b[0]),
		.carry_in(carry_in),
		.sum(sum[0]),
		.carry_out(c[0])
	);

	full_adder_structural FA_STRUCT_1(
		.a(a[1]),
		.b(b[1]),
		.carry_in(c[0]),
		.sum(sum[1]),
		.carry_out(c[1])
	);

	full_adder_structural FA_STRUCT_2(
	);

	full_adder_structural FA_STRUCT_3(
	);

endmodule


module full_adder_structural(
	input a,
	input b,
	input carry_in,
	output sum,
	output carry_out
);
	
	// Declare nets to connect the half adders
	wire sum1;
	wire carry1;
	wire carry2;

	// Instantiate two half_adder_structural modules 
	half_adder_structural HA1(
		.a(a),
		.b(b),
		.sum(sum1),
		.carry(carry1)
	);

	half_adder_structural HA2(
		.a(sum1),
		.b(carry_in),
		.sum(sum),
		.carry(carry2)
	);

	// Use Verilog primitive
	or (carry_out, carry1, carry2);

endmodule 


module half_adder_structural(
	input a,
	input b,
	output sum,
	output carry
);
	// Instantiate Verilog built-in primitives and connect them with nets
	xor XOR1 (sum, a,b);	
	and AND1 (carry, a,b);

endmodule 

module testbench();

endmodule 
