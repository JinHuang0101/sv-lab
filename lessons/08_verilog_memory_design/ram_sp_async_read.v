// Data bus: a bidirectional bundle of signals (inout) that carries data into or out of a module 
// Single port RAM with asynchronous read
// RAM--Random Access Memory
// Read from or write to any memory location (address) directly 
// RAM-- read and write 
// Single port: only one set of address/data lines; 
//				can do either read or write at a time
//				cannot read and write simultaneously 
// Async read: 
//		no clock required, no need to wait for clock edge, data appear when address change 
//		But only see new data after the write completes on clock edge 
// The size of the RAM is 16 x 8 bit words 

// same data bus (but direction changes)
// in this code, data_in + data_out act as a bidirectional data bus 
module ram_sp_async_read(
	input clk,
	input [7:0] data_in,
	input [3:0] address,		// 4-bit address, 16 locations
								// same address used for both operations 
	input write_en,				// active high
								// Direction change of the same data bus
								// controlled by write_en 
	output [7:0] data_out		// 8-bit output word 
);
	// Memory declaration 
	// Declare a bidimentional array for the RAM 
	// 2D array: 16 locations, each holding an 8-bit value 
	// total size: 128 bits (16*8)
	reg [7:0] ram [0:15];		// 16 words * 8 bits each 

	// RAM doesn't have reset 
	// The default value from each location is X.
	// The write is synchronous 
	always @(posedge clk) begin				// only occurs on the rising edge  
		if (write_en) begin					// write_en == 1 
			ram[address] <= data_in;		// non-blocking, data from data_in written to ram[address] 
		end 
	end 

	// Asynchronous read: read data at any time, even mid-clock cycle   
	// Combinational, no clock required, no flip-flops  
	// Output data_out immediately reflects the content of ram[address] whenever address changes
	// Async read: no @(posedge clk) needed 
	assign data_out = ram[address];

endmodule 

// Testbench 
`timescale 1us/1ns
module tb_ram_sp_async_read();

	// Testbench variables 
	reg clk = 0;
	reg [7:0] data_in;
	reg [3:0] address;
	reg write_en;
	wire [7:0] data_out;
	reg [1:0] delay;
	reg [7:0] wr_data;
	integer success_count, error_count, test_count;
	integer i;



	// DUT instantiation 
	ram_sp_async_read RAM0(
		.clk	(clk),
		.data_in	(data_in),
		.address	(address),
		.write_en	(write_en),
		.data_out	(data_out)
	);



	// Tasks for clean stimulus 

	// We will use no outputs as we will use the global variables
	// connected to the module's ports 

	// write happens on the same clock edge 
	task write_data(input [3:0] address_in, input [7:0] d_in);
		begin 
			@(posedge clk);			// Waits for next clock edge 
			write_en = 1;				// enables write
			address = address_in;		// sets up address 
			data_in	= d_in;				// sets up data 
		end 
	endtask 

	// Disables write 
	// Async read 
	task read_data(input [3:0] address_in);
		begin 
			@(posedge clk);
			write_en = 0;
			address = address_in;		// changes address, triggers immediate read 
		end 

	endtask 


	// Task self-checking 
	// Compare write data with read data 
	task compare_data(
					input [3:0] address, 
					input[7:0]	expected_data,
					input[7:0]	observed_data
					);
		begin 
			if (expected_data === observed_data) begin 
				$display($time, "SUCCESS address = %0d, expected_data = %2x, observed_data = %2x",
									address, expected_data, observed_data);
				success_count = success_count + 1;
			end else begin 
				$display($time, "ERROR address = %0d, expected_data = %2x, observed_data = %2x",
									address, expected_data, observed_data);
				error_count = error_count + 1;

			end 
			test_count = test_count + 1;
		end 
	endtask 

	// Clock generation  
	always begin #0.5 clk = ~clk; end		// Clock period = 1 time unit (1 MHz) 

	// Create stimulus 
	initial begin 
		#1;
		success_count = 0; error_count = 0; test_count = 0;

		#1.3;
		for (i=0; i<16; i=i+1) begin		// loop runs 16 times, because ram[16]: 16 locations  
			wr_data = $random;
			write_data(i, wr_data);			// Write
			read_data(i);					// Read same location 
			#0.1;							// Small delay to sample stable data_out 
			compare_data(i, wr_data, data_out);
			delay = $random;
			#(delay);						// Random delay between tests 
		end 

		
		read_data(7);			// Reads locations 7 and 8 again after the loop 
		read_data(8);

		// Print statistics 
		$display($time, " TEST RESULTS success_count = %0d, error_count = %0d, test_count = %0d",
						success_count, error_count, test_count);

		#40 $stop;

	end 

endmodule 

