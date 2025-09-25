module easy_verilog_example(
);
	reg x = 1'b0;	// 1bit variable with the value 0
	reg y = 1'b1;	// 1it variable with the value 1
	reg z;			// used to store the result of operations between x and y

	// a procedure example
	always @(*) begin 
		$display("x = %b, y = %b, z = %b", x,y,z)
	end 

	// another procedure example
	initial begin 
		#2;		// wait 2 time units
		z = x ^ y;		// bitwise XOR between the 1 bit variables x and y
		#10;
		y = 0;
		z = x | y;		// bitwise OR 
		#10;
		z = z & 1;		// bitwise AND 
		#10;
	end 

endmodule
