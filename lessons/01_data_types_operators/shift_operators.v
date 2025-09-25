module shift_operators();

	reg [11:0] a = 12'b0101_1010_1101;		//12bit value unsigned 
	reg [11:0] b;

	// procedure to continuously monitor registers
	initial begin 
		// monitor code
	end 

	// procedure to generate stimulus 
	initial begin 
		b = a << 1;			// b = a*2
		#1;
		b = 0;

		#1; b = a * 2;	

		#1; b = a << 5;
		#1; b = b >> 2;
		#1; b = b >> 7;
		#1; b = b << 1;
		#1; b = (a << 1) >> 6;


	end 

endmodule
