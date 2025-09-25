module math_operators();

	integer a=2;		32bit signed value 
	integer b=3;
	integer result;

	initial begin
		// monitor code 
	end 

	// Procedure used to generate stimulus
	initial begin 
		result = a ** b;		// exponentiation
		#1;
		result = b ** a;

		#1; a = 177; b = 12;
		result = a * b;

		#1; a = 199; b = 19;
		result = a/b;
		#1;
		result = a % b;			// remainder 

		#1; a = 199; b = -19;
		result = a % b;		// remainder negative, use with caution in critycal systems operations

		#1; a = 4199; b = -2319;
		result = a + b;

		#1; a = 19234; b= -16;
		result = a - b;

		#1; a = 919234; b = 13;
		result = a - (b*(2**15));


	end 

endmodule