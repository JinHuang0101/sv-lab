// All # delays are in 1us steps; fractional times rounded to nearest 1ns
`timescale 1us/1ns

// Module has no ports - this is a self-contained testbench
// to demonstrate recursion 
module func_ex3();

	// Recursive function example 
	// 'automatic' keyword is Required for recursive functions in Verilog
	// Without it, the function uses static storage, then only one copy exists, then recursion fails
	// 'integer' is 32-bit signed type; return type is also 'integer'
	// 'N' is the input argument (non-negative integer expected)
	function automatic integer factorial (input integer N);

		// Internal variable for intermediary results 
		// Have to be declared before "begin/end"
		integer result = 0;
			// Local variable 'result' holds intermediate computation 
			// Initialized to 0 (though will be overwritten)

		begin
			if (N==0)
				result = 1;	// Base case: factorial of 0 = 1
			else
				result = N * factorial(N-1);	// Calls itself with N-1, will recurse until N==0
			
			// Assigns the computed value back to the function name 
			// This is how functions return values in Verilog
			factorial = result;
		end 

	endfunction 

	initial begin 
		// Initial block runs once at simulation start (time=0)
		#1 $display ($time, "factorial(2) = %d", factorial(2));
		#1 $display ($time, "factorial(5) = %d", factorial(5));
		#1 $display ($time, "factorial(10) = %d", factorial(10));
	end 


endmodule 
