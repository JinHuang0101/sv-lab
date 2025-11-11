module ram_dp_async_read
		#(
		parameter WIDTH = 8;				// data width 
		parameter DEPTH = 16;				// number of words 
		parameter DEPTH_LOG = $clog2(DEPTH)		// log2(DEPTH), that's the address width 
		)
		(
		input clk,
		input we_n,								// write-enable, active-low 
		input [DEPTH_LOG-1:0] addr_wr
		input [DEPTH_LOG-1:0] addr_rd,
		input [WIDTH-1:0] data_wr,
		output [WIDTH-1:0] data_rd
		);

		// Declare the RAM array (RAM storage) 
		reg [WIDTH-1:0] ram [0:DEPTH-1];

		// Synchronous write: sync on rising clock edge 
		// On every rising clock edge, 
		// if we_n is high, the value on data_wr is stored into 
		// the memory location selected by addr_wr 

		always @(posedge clk) begin 
			if (we_n)						// we_n == 1, then write 
				ram[addr_wr] <= data_wr;
		end 

		// Asynchrnous read  
		// Combinational read port 
		// No clock required
		// The output data_rd is the current content of the addressed word 
		assign data_rd = ram[addr_rd]

endmodule 

`timescale 1us/1ns 

module tb_ram_dp_async_read();
	localparam WIDTH = 8;
	localparam DEPTH = 64;
	localparam DEPTH_LOG = $clog2(DEPTH);

	// DUT signals 
	reg clk;
	reg we_n;
	reg [DEPTH_LOG-1:0] addr_wr;
	reg [DEPTH_LOG-1:0] addr_rd;
	reg [WIDTH-1:0] data_wr;
	wire [WIDTH-1:0] data_rd;

	// Counters for pass/fail statistics 
	integer i;
	integer num_tests = 0;
	integer test_count = 0;
	integer success_count = 0;
	integer error_count = 0;
	reg [DEPTH_LOG-1:0] rand_addr_wr;

	// DUT instantiation 
	ram_dp_async_read
		#(
		.WIDTH(WIDTH),
		.DEPTH(DEPTH)
		) 
		ram_dual_port0
		(
		.clk(clk),
		.we_n(we_n),
		.addr_wr(addr_wr),
		.addr_rd(addr_rd),
		.data_wr(data_wr),
		.data_rd(data_rd)
		);

	// Clock generation : 2ns period  
	initial begin 
		clk = 0;
		forever begin 
			#1 clk = ~clk;
		end 
	end 

	// Test scenario 
	initial begin 
		#1;
		success_count = 0;
		error_count = 0;
		test_count = 0;
		num_tests = DEPTH;
		#1.3;

		// Test 1: write random data at a specific address, read it back and
		//			compare it with the written data.
		// Write random data to sequential addresses
		// read back immediately 
		$display($time, " Test 1 Start");
		for (i=0; i<num_tests; i=i+1) begin 
			data_wr = $random;				// 32-bit random, lower 8 bits used 
			write_data(data_wr, i);			// sync write 
			read_data(i);					// set read address (async)
			#0.1;
			compare_data(i, data_wr, data_rd);	// check 
		end

		// Test 2: write at a random address data with a known pattern, read it back
		//			and compare it with the written data.
		// Write a deterministic pattern to random addresses 
		$display($time, " Test2 Start");
		for (i=0; i<num_tests; i=i+1) begin 
			rand_addr_wr = $random % DEPTH;
			data_wr = (rand_addr_wr << 4) | ((rand_addr_wr%2) ? 4'hA : 4'h5);

			write_data(data_wr, rand_addr_wr);
			read_data(rand_addr_wr);
			#0.1;
			compare_data(rand_addr_wr, data_wr, data_rd);
		end 

		// Print statistics 
		$display($time, " TEST RESULTS success_count = %0d, error_count = %0d, test_count = %0d",
						success_count, error_count, test_count);
		#40;
		$stop;
	end 

	// sync write data task 
	// two clock cycles are used 
	task write_data(input[WIDTH-1:0] data_in,
					input[DEPTH_LOG-1:0] address_in);
		begin 
			@(posedge clk);			
			we_n = 1;				// enable write 
			data_wr = data_in; 
			addr_wr = address_in;

			@(posedge clk);		// next edge latches the data 
			we_n = 0;			// de-assert write enable 
		end 
	endtask 


	// Read the data asynchronously 
	task read_data(input[DEPTH_LOG-1:0] address_in);
		begin 
			addr_rd = address_in;
			$display($time, " data_rd = %d", data_rd);	// for debugging 

		end 

	endtask 


	// Compare write data with read data 
	task compare_data(
					input [DEPTH_LOG-1:0] address,
					input [WIDTH-1:0] expected_data;
					input [WIDTH-1:0] observed_data
					);
		begin 
			if (expected_data === observed_data) begin  
				$display($time, " SUCCESS address = %0d, expected_data = %0x, observed_data = %0x",
											address, expected_data, observed_data);
				success_count = success_count + 1;
			end else begin 
				$display($time, " ERROR address = %0d, expected_data = %0x, observed_data = %0x",
										address, expected_data, observed_data);
				error_count = error_count + 1;
			end 
			test_count = test_count + 1;

		end 

	endtask 

endmodule 

