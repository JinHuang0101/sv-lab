module bitwise_operators();
	
	reg [5:0] x = 0;
	reg [5:0] y = 0;
	reg [5:0] result = 0;

	// continuous monitor
	initial begin
		$monitor("MON x=%b, y=%b, result=%b", x,y,result);
	end 

	// Procedure used to generate stimulus
	initial begin 
		#1;
		x = 6'b00_0101;
		y = 6'b11_0001;
		result = x & y;

		#1;
		x = 6'b10_0101;
		y = 6'b01_1011;
		result = x | y;

		#1;
		result = ~(x | y);	//NOR, try x ~| y 

		#1;
		x = 6'b01_0110;
		y = 6'b01_1011;
		result = x ^ y;		// XOR

		#1;
		result = x ~^ y;		//XNOR used to check if x = y

		#1;
		x = y;				// make all bits 1 
		result = ~(x ^ y);			// NXOR 
	end

endmodule 
