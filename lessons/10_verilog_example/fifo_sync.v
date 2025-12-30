// Synchronous FIFO (First-In-First-Out) Buffer Module
// A circular buffer that stores data in the order it arrives 
// Uses a single clock domain (synchronous design)

module fifo_sync
	// Parameters section - Configurable values set during instantiation 
	#( parameter FIFO_DEPTH = 8,	// Number of storage locations in FIFO
	   parameter DATA_WIDTH = 32)	// Width of each data word in bits 

	// Ports section - module interface signals 
	(input clk,
	 input rst_n,
	 input cs,	// chip select - enables FIFO operations 
	 input wr_en,		// write enable - request to write data in FIFO 
	 input rd_en,		// read enable - request to read data from the FIFO 
	 input [DATA_WIDTH-1:0] data_in,		// data to be written into FIFO 
	 output reg [DATA_WIDTH-1:0] data_out,	// data read from FIFO 
	 output empty,							// Status flag: 1 when FIFO is empty 
	 output full							// Status flag: 1 when FIFO is full 
	);

	// Local parameter - Calculated pointer width 
	// $clog2 calculates ceiling of log base 2
	// eg, $clog2(8) = 3 (need 3 bits to address 8 locations)
	localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);

	// Internal storage and pointers 
	// Two-dimensional array: FIFO storage memory 
	// [DATA_WIDTH-1:0] = each location stores DATA_WIDTH bits 
	// [0:FIFO_DEPTH-1] = array has FIFO_DEPTH locations 
	// e.g., if DATA_WIDTH = 32, FIFO_DEPTH = 8, 8 locations by 32 bits each 

	reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];

	// Write pointer: tracks where next data will be written 
	// Has 1 extra MSB bit for full/empty detection 
	// e.g., FIFO_DEPTH=8, FIFO_DEPTH_LOG=3, then pointer is 4 bits [3:0]
	
	reg [FIFO_DEPTH_LOG:0] write_pointer;

	// Read pointer: tracks where next data will be read from 
	// Also has 1 extra MSB bit for full/empty detection 
	reg [FIFO_DEPTH_LOG:0] read_pointer;

	// Write pointer control logic 
	// This block manages the write pointer increment 
	always @(posedge clk or negedge rst_n) begin 
		if(!rst_n)		// Async reset (active low)
			write_pointer <= 0;			// reset write pointer to start of FIFO
		else if (cs && wr_en && !full)			// write conditions met
				// cs=1: chip is selected (FIFO is enabled)
				// wr_en = 1: write is requested 
				// !full: FIFO has space available 
			write_pointer <= write_pointer + 1'b1;		// increment to next location 
			// Note: Pointer will wrap around automatically due to fixed bit width 
	end 

	// Read pointer control logic 
	always @(posedge clk or negedge rst_n) begin 
		if(!rst_n)
			read_pointer <= 0;
		else if (cs && rd_en && !empty)
			read_pointer <= read_pointer + 1'b1;
	end 

	// Empty and full flag generation (combinational logic)
	// Empty condition: read pointer catches up to write pointer 
	// When both pointers are equal (including MSB), no data to read
	assign empty = (read_pointer == write_pointer);

	// FULL condition: write pointer catches up to read pointer (one full cycle ahead)
	// Uses clever trick with extra MSB bit:
	// - lower bits [FIFO_DEPTH_LOG-1:0] are equal (same position in circular buffer)
	// - MSB bits are opposite (write pointer is one full cycle ahead)

	assign full = (read_pointer == {~write_pointer[FIFO_DEPTH_LOG], write_pointer[FIFO_DEPTH_LOG-1:0]});

	// Write data logic 
	always @(posedge clk) begin 
		if (cs && wr_en && !full)
			// Write data to FIFO at current write pointer location
			// Use only lower bits [FIFO_DEPTH_LOG-1:0] for array indexing
			// MSB is only for full/empty detection, not addressing 
			fifo[write_pointer[FIFO_DEPTH_LOG-1:0]] <= data_in;
	end 

	// Read data logic 
	always @(posedge clk or negedge rst_n) begin 
		if (!rst_n)
			data_out <= 0;		// clear output on reset 
		else if (cs && rd_en && !empty)
			// Read data from FIFO at current read pointer location
			// Use only loewr bits [FIFO_DEPTH_LOG-1:0] for array indexing 
			data_out <= fifo[read_pointer[FIFO_DEPTH_LOG-1:0]];
			// Data appears on data_out on next clock cycle (registered output)
	end


endmodule 

