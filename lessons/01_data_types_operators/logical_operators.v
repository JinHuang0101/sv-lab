module logical_operators();
	
	reg [2:0] my_val1 = 3'b111;
	reg [3:0] my_val2 = 4'b0000;
	reg result;

	initial begin 
		$monitor("MON my_val1=%b, my_val2=%b, result=%b", my_val1, my_val2, result);
	end

	initial begin 
		result = !my_val1;
		#1;
		result = !my_val2;
		#1;
		result = my_val1 && my_val2;
		#1;
		result = my_val1 || my_val2;
		#1;
		my_val1 = 3'bz0X;		// add some unknown bits 
		result = !my_val1;

		#1; 
		result = my_val1 || my_val2;

		#1;
		result = my_val1 && my_val2;


	end 

endmodule