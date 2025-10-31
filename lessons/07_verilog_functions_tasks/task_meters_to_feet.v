// task (but function cannot):
// have dealys
// use $display, $write
// modify external variables via output ports 

`timescale 1us/1ns

module task_meters_to_feet ();
	
	// Testbench variables 
	real meters, feet;		// 'real' type: 64-bit floating-point 
	reg clk = 0;

	// =============================================================
    // TASK: meters_to_feet
    // =============================================================
    // Tasks can have input/output/inout ports of ANY type, including 'real' 
	task meters_to_feet(input real meters, output real feet);
		begin 
			feet = meters * 3.2808;
			$display($time, "meters = %0.4f, feet = %0.4f", meters, feet);

		end 
	endtask 

	// Create a clock signal 
	always begin #1 clk = ~clk; end		// wait 1 time unit (1us), then toggle
										// clk period = 2us (1us high, 1us low)
										// Frequency = 500 kHz

	// =============================================================
    // Main Stimulus: Call the task on clock edges
    // =============================================================
	initial begin 
		@(posedge clk) meters = 1; meters_to_feet(meters, feet);
		@(posedge clk) meters = 3; meters_to_feet(meters, feet);
		@(posedge clk) meters = 10; meters_to_feet(meters, feet);

	end 

	// =============================================================
    // Stop simulation after 10 clock cycles
    // =============================================================
	// Print the value of the internal variable
	initial begin 
		repeat(10) @(posedge clk);
		$stop();
	end 

endmodule 
