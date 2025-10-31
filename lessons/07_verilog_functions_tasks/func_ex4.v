`timescale 1us/1ns

module func_ex4();
	
	// Recursive function example
	// 'automatic' is required - allows multiple independent calls (stack-like behavior)
	// Without it: all recursive calls share 'result', so wrong output 
	// Returns 32-bit signed integer (Fibonacci grows fast, but 10th term fits)
	function automatic integer fibonacci (input integer N);
		// Internal variable for intermediary results 
		// Have to be declared before "begin/end"
		integer result = 0;

		begin 
			if (N==0)
				result = 0;		// Base case 1

			else if (N==1)		// Base case 2
				result = 1;
			else 
				result = fibonacci(N-1) + fibonacci(N-2);

			// Return value by assigning to function name 
			fibonacci = result;
		end 


	endfunction 

	initial begin 
		#1 $display ($time, "fibonacci(2) = %d", fibonacci(2));
		#1 $display ($time, "fibonacci(5) = %d", fibonacci(5));
		#1 $display ($time, "fibonacci(10) = %d", fibonacci(10));
	end 

endmodule 
