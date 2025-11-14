// Electronic door lock controlled by a FSM
// Purpose of the Design:
// 1. Accepts a 4-bit access code (0-15) 
// 2. Opens the door only if the code is between 4 and 11 inclusive 
// 3. Keeps the door open for a fixed time (~15 clock cycles)
// 4. Returns to idle after timeout 

// Finite State Machine:
// a model of computation that can be in exactly one of a finite number of states at any time 
// It changes state based on inputs and current state, and produces outputs

// Two flip-flops:state register and timer register 

module fsm1(
	input clk,
	input rst_n,
	input validate_code,			// pulse to say "check the code now"
	input [3:0] access_code,		// the 4-bit code entered (0-15)
	output reg open_access_door,	// '1' = door unlocked 
	output [1:0] state_out			// current state visible outside 
);
	
	// Declare the state values as parameters 
	// 2-bit encoding 
	parameter [1:0] IDLE		= 2'b0;
	parameter [1:0] CHECK_CODE	= 2'b01;
	parameter [1:0] ACCESS_GRANTED = 2'b10;
						

	// Declare the logic of the state machine 
	reg [1:0] state, next_state;		// classic two-always-block FSM style 
	reg [3:0] timer;					// counts how long door stays open 

	// State transition logic (combinational) 
	// next-state + output logic 

	// The combinational block is automatically re-evaluted because
	// state or timer may have just changed 

	// This affects others immediately 

	always @(*) begin 
		next_state = IDLE;		// default values 
		open_access_door = 0;	// door closed by default 
		
		case (state)
			IDLE: begin 
				if (validate_code) 
					next_state = CHECK_CODE;
				// else stay in IDLE 
			end 

			CHECK_CODE: begin 
				if ((access_code >= 4'd4) && (access_code <= 4'd11))
					next_state = ACCESS_GRANTED;
				// else goes back to IDLE because of default 
			end 

			ACCESS_GRANTED: begin 
				open_access_door = 1;
				if (timer == 4'hF)			// after 15 cycles  
					next_state = IDLE;
				else				
					next_state = ACCESS_GRANTED;	// stay 
			end 

			default: next_state = IDLE;
		endcase 
	end 


	// State register update (sequential)
	// Flip-flop 1: state register
	// update state 

	// non-blocking: schedule these updates to happen 
	// after all combinational logic has settled 
	// Prevents race conditions 

	// Affects next clock cycle 

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;		// non-blocking,  
		else
			state <= next_state;
	end 

	assign state_out = state;		// connect with output port 

	// Timer logic (keeps door open for 15 cycles) 
	// Flip-flop 2: timer register 
	// update timer 

	// non-blocking: schedule the update to happen
	// after all combinational logic has settled 
	// prevents race conditions

	// Affects next clock cycle 

	always @(posedge clk or negedge rst_n) begin 
		if(!rst_n)
			timer <= 0;						// non-blocking 
		else if (state == ACCESS_GRANTED)
			timer <= timer + 1'b1;
		else
			timer <= 0;
	end 

endmodule 

`timescale 1us/1ns 

module tb_fsm1();
	reg clk = 0;
	reg rst_n;
	reg validate_code;
	reg [3:0] access_code;
	wire open_access_door;
	wire [1:0] state_out;

	// Module instantiation 
	fsm1 FSM0(
		.clk			(clk),
		.rst_n			(rst_n),
		.validate_code	(validate_code),
		.access_code	(access_code),
		.open_access_door	(open_access_door),
		.state_out			(state_out)
	);

	initial begin 
		forever begin 
			#1 clk = ~clk;
		end 
	end 

	initial begin 
		$monitor($time, " access_code = %4b, state_out = %2b, open_access_door = %b",
						access_code, state_out, open_access_door);
		
		rst_n = 0; #2.5; rst_n = 1;		// assert reset, then release 
		
		validate_code = 0; access_code = 0;

		@(posedge clk);
		validate_code = 1; access_code = 0;		// invalid

		@(posedge clk);
		validate_code = 1; access_code = 0;		// invalid 

		@(posedge clk);
		validate_code = 1; access_code = 9;		// valid 

		@(posedge clk);
		validate_code = 0; access_code = 9;		// remove validate puls 

		#40 $stop;			// let it run to see timer expire 

	end 
	

endmodule 


