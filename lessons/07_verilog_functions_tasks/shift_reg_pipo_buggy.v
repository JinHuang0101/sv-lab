// Module with intentional bug 
module shift_reg_pipo_buggy(
	input reset_n,
	input clk,
	input [7:0] d,
	output reg [7:0] q
);
	// We will intentially insert an error in this circuit
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n)
			q <= 0;			// Async reset: clear q 
		else
			q[7:0] <= d[6:0];	// Bug: size mismatch (MSB not connected)
			// q[7:0] <= d[7:0];	// the correct version 
	end 

endmodule 

`timescale 1us/1ns
module tb_shift_reg_pipo_buggy();
	
	// Testbench signals 
	reg [7:0] d;
	reg clk = 0;
	reg reset_n;
	wire [7:0] q;

	reg [1:0] delay;		// Random delay (0-3 time units)
	integer success_count, error_count, test_count;
	integer i;

	// Instantiate DUT (Device Under Test)
	shift_reg_pipo_buggy PIPO0(
		.reset_n(reset_n),
		.clk(clk),
		.d(d),
		.q(q)
	);

	// Task: load_check_pipo_reg
	task load_check_pipo_reg();
		begin 
			@(posedge clk);		// Wait for clock edge
			d = $random;		// Apply random data 
			@(posedge clk);		// Wait for next edge (load into q)
			#0.1;				// Small delay for non-blocking settle
			compare_data(d, q);	// Compare expected vs actual 
		end 
	endtask 

	// Task: compare_data 
	task compare_data(input [7:0] expected_data, input [7:0] observed_data);
		begin 
			if (expected_data==observed_data) begin 
				$display($time, "SUCCESS expected_data = %8b, observed_data = %8b",
						expected_data, observed_data);
				success_count = success_count + 1;
			end else begin
				$display($time, "ERROR expected_data = %8b, observed_data=%8b",
							expected_data, observed_data);
				error_count = error_count + 1;
			end 
			test_count = test_count + 1;

		end 
	endtask 

	// Clock Generator: 1 MHz
	// Period = 1us, rising edges at 0.5, 1.5, 2.5...
	always begin 
		#0.5 clk = ~clk; 
	end 

	// Main stimulus 
	initial begin 
		#1;								// Initial delay
		success_count = 0;
		error_count = 0;
		test_count = 0;
		
		reset_n = 0;					// Assert reset 
		d = 0;
		#1.3;							// Hold reset for 1.3us
		reset_n = 1;					// Deassert reset 

		// Run 10 load-and-check tests 
		for (i=0; i<10; i=i+1) begin 
			load_check_pipo_reg();			// Load random, check q
			delay = $random;				// Random delay 0-3
			#(delay) d = $random;			// Apply random noise (not loaded)
		end 

		// Print final results 
		$display($time, "TEST RESULTS success_count = %0d, error_count = %0d, test_count = %0d",
		success_count, error_count, test_count);
		#40 $stop;							// Stop simulation 


	end 




endmodule 

