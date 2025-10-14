// 4: the number of input bits the encoder accepts
// a 4-bit vector: four individual input lines (d[3], d[2], d[1], d[0])
// 2: the number of output bits used to encode the result
// the output q is a 2bit vector q[1:0], represent four possible values (00,01,10,11, or decimal 0 to 3)
// Priority Encoder: specifies this circuit is a priority encoder
//The name signifies: the encoder takes 4 input bits and produces a 2bit output that encodes the position of the highest priority active input 


module prio_enc1_4to2(
	input [3:0] d,		// 4bit input vector representing priority-encoded signals (d[3] is highest priority)
	output reg [1:0] q, // 2bit output encoding the position of the highest-priority set bit (binary value)
	output reg v	// 1bit valid output: asserted 1 if any input bit is set, deasserted 0 otherwise.
);
	// Decode the priority of the set bits using a combinational always block
	// Implements priority encoding: checks bits from highest (d[3]) to lowest (d[0])
	// The first set bit encountered determines the output 'q' 
	always @(*) begin	// sensitive to any change in inputs, combinational logic
		if (d[3])		// check MSB 
			q = 2'd3;	// output binary 11 (decimal 3) for position 3
		else if (d[2])
			q = 2'd2;
		else if (d[1])
			q = 2'd1;
		else 
			q = 2'd0;
	end 

	// Valid is asserted when any bit is set 
	// This block generates the valid signal independently (also combinational)
	always @(*) begin 
		if (!d)		// Check if all bits in 'd' are 0 (logical NOT of the vector)
			v = 0;	// Deassert valid: no input active 
		else 
			v = 1;	// assert valid: at least one input bit is set 
	end 

endmodule 

`timescale 1us/1ns		// time scale for the test bench; sets the time unit to 1 microsecond and time precision to 1 nanosecond for simulating timing 
module tb_prio_enc1_4to2();	// testbench module: no ports, used to verify the DUT 
	
	reg [3: 0] d;		// Input stimulus: 4bit register to drive the DUT's d input
	wire v;	// Output from DUT: connected to valid signal (monitored but not driven)
	wire [1: 0] q;	// Output from DUT: monitored not driven 
	integer i;			// loop variable for generating test patterns in the for-loop

	// Instantiate the DUT
	// Connects testbench signals to the module ports by name
	prio_enc1_4to2 PRENC(	// instance name
		.d(d),	// connect tb d to module input d
		.q(q),	// connect module output q to tb wire q
		.v(v)	// connect module output v to tb wire v
	);

	// Create stimulus: generates input patterns over time to test the priority encoder 
	initial begin	// executes once at simulation start (procedural blockl)
		$monitor($time, "d=%b, q=%d, v=%d", d, q, v);
		#1; d=0;	// delay 1 time unit, then set d = 0000 (test all inputs low: expect q=0, v=0)
		
		// Loop to test single-bit assertions from lowest to highest priority
		// Shifts '1' left by i bits to set one bit at a time
		// e.g., i=0: 0001; 1=1: 0010
		for (i=0; i<4; i=i+1) begin 
			#1; d=(1 << i);
		end 
		// This tests: d=0001 (q=0,v=1), d=0010(q=1,v=1), d=0100(q=2,v=1), d=1000(q=3,v=1)

		// Check the priority behavior with multiple bits set 
		// Higher bits should take precedence over lower ones 
		#1; d=4'b1111;	// all bits set: expect q=3, v=1
		#1; d=4'b1001;
		#1; d=4'b0101;
		#1; d=4'b0000;
		#1; $stop;
	end 

endmodule 

