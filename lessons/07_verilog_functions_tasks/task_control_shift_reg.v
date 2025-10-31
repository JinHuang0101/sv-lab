`timescale 1us/1ns

module task_control_shift_reg ();
 
	parameter REG_WIDTH = 8;	// 8-bit shift register 

	// Control signals and data input 
	reg load;						// 1 = load data, 0 = shift 
	reg shift_left_right;			// 1 = shift left, 0 = shift right 	
	reg [REG_WIDTH-1:0] data_in;	// Data to load 
	reg clk = 0;					// Clock signal 


    // TASK: control_shift_reg

	task control_shift_reg (
				input i_load,					// Local copy of load 
				input i_shift_left_right,		// Local copy of direction
				input [REG_WIDTH-1:0] i_data_in	// Local copy of data
				);
		begin
			@(posedge clk);						// Wait for NEXT rising clock edge 
			load = i_load;						// Apply control signals 
			shift_left_right = i_shift_left_right;
			data_in = i_data_in;
		end 
	endtask



    // Clock Generator: 1 MHz (period = 1us)

	always begin 
		#0.5 clk = ~clk; 
	end 
	// #0.5 to 500ns high + 500ns low, period = 1us, f = 1 MHz
    // Rising edges at: 0.5us, 1.5us, 2.5us, ...


    // Stimulus: Call task multiple times

	initial begin 
		$monitor ($time, "load=%0b, shift_left_right=%0b, data_in=%8b",
					load, shift_left_right, data_in);
		// Call the task using the 'position' call for its input parameters
		control_shift_reg(1, 0, 8'd1);		// load with 1
		control_shift_reg(1, 1, 8'b1010_0101);	// load with 8'b1010_0101
		control_shift_reg(1, 1, $random);		// load with $random
		
		control_shift_reg(0, 1, 0);		// shift left 
		control_shift_reg(1, 0, $random);	// load with random 
		control_shift_reg(0, 0, $random);		// shift right 

		// Wait 5 more clock cycles, then finish
		repeat (5) @(posedge clk);
		$finish();
	end 

endmodule 
