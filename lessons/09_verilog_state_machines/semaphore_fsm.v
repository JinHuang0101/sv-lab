// Semaphore FSM: a Finite State Machine that controls access to a share resource in digital hardware 
// It gaurantees that only one user (or a fixed number of users) can access the resource at a time
// all others must wait 
// Traffic light controller FSM: controls colored lights in sequence  

module semaphore_fsm(
	input clk,
	input rst_n,			// active-low async reset 
	input enable,			// master enable - when 0, all lights OFF 
							// enable is an input port, meaning only the testbench
							// or the higher-level system that instantiates this traffic-light controller
							// can change it
							// No line inside the FSM module can change enable 
							// Critical safety override 
	output reg red,
	output reg yellow,
	output reg green,
	output [3:0] state_out			// current state visible for debug/testbench 
);
	
	// State decoding (one-hot)
	// Declare the state values as parameters using ONE-HOT encoding 
	// One-hot: exactly one bit is 1 at a time, glitch-resistant  
	// If glitch, two bits high, then illegal, easy to detect in assertion and safety logic 

	parameter [3:0]	OFF	= 4'b0001,		// All lights off (safe default)
					RED	= 4'b0010,
					YELLOW	= 4'b0100,
					GREEN = 4'b1000;

	// Internal registers 
	reg [3:0] state;			// Current state (sequential - updated on clock)
	reg [3:0] next_state;		// Next state (combinational - computed instantly)
	reg [5:0] timer;			// Counts clock cycles in each light phase 
	reg timer_clear;			// Pulse to reset timer when entering new phase 

	// Next state and output logic (combinational) 
	always @(*) begin 
		// Default assignments - prevent latches 
		next_state = OFF;			// If nothing else matches, go to safe OFF state 
		red = 0;
		yellow = 0;
		green = 0;
		timer_clear = 0;			// Timer normally runs - clear only on purpose 

		case (state)
			OFF	: begin 
				  // Only leave OFF when system is enabled 
				  if (enable) 
					next_state = RED;		// Start with RED when enabled 
			end 

			RED	: begin
						red = 1;			// Red light ON 

						// if timer has reached exactly 50
						// go to YELLOW 
						// and reset the timer 
						if (timer == 6'd50) begin			// Stay in RED for 50 clock cycles 
							next_state = YELLOW;
							timer_clear = 1;				// Reset timer for yellow phase 

						// meaning: if timer is 0, 1, 2, ... , 49 
						// then wait, stay in RED state 
						end else begin 
							next_state = RED;				// Stay in RED 
						end 
				  end 

			YELLOW: begin 
						yellow = 1;					// Yellow light ON 

						// Short yellow: 10 cycles 
						if (timer == 6'd10) begin 
							next_state = GREEN;
							timer_clear = 1;		// Reset timer for green phase 

						end else begin 
							next_state = YELLOW;
						end 
					end 

		    GREEN:	begin 
						green = 1;					// Green light ON

						// Green for 30 cycles 
						if (timer == 6'd30) begin 
							next_state = RED;			// back to RED (full cycle)
							timer_clear = 1;
						end else begin 
							next_state = GREEN;
						end 
					end 

		    default: begin 
				next_state = OFF;		// Any unknown state, safe OFF 
			end 

		endcase 

		// Critical Safety Override 
		// This has highest priority 
		// Return from any state to OFF if enable == 0

		// If the enable signal is NOT active (i.e., 0)
		// then IMMEDIATELY force the next state to OFF
		// no matter what state we are currently in
		if (!enable) begin					// Logical NOT enable: 
											// enable is 0 or enable is low 
			next_state = OFF;

		end 

	end 


	// State sequencer logic 
	always @(posedge clk or negedge rst_n) begin 
		if(!rst_n)
			state <= OFF;
		else 
			state <= next_state;
	end 

	assign state_out = state;


	// Timer logic 
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) 
			timer <= 6'd0;
		else if ((timer_clear) == 1 || (!enable))
			timer <= 6'd0;
		else if (state != OFF)
			timer <= timer + 1'b1;
	end 

endmodule 

`timescale 1us/1ns 

module tb_semaphore_fsm();

	reg clk = 0;
	reg rst_n;
	reg enable;
	wire red;
	wire yellow;
	wire green;
	wire [3:0] state_out;

	// Parameters used for testbench flow 
	parameter [3:0] OFF = 4'b0001,
					RED = 4'b0010,
					YELLOW = 4'b0100,
					GREEN = 4'b1000;

	// Module instantiation 
	semaphore_fsm SEM0(
		.clk (clk),
		.rst_n	(rst_n),
		.enable (enable),
		.red	(red),
		.yellow	(yellow),
		.green	(green),
		.state_out	(state_out)
	);


	// Clock signal 
	initial begin
		forever begin 
			#1 clk = ~clk;
		end 
	end 

	// Stimulus 
	initial begin 
		$monitor($time, "	enable = %b, red = %b, yellow = %b, green = %b",
							enable, red, yellow, green);
		rst_n = 0; #2.5; rst_n = 1;

		enable = 0;					// starts disabled (all lights OFF)

		repeat (10) @ (posedge clk);

		enable = 1;					// USER turns the traffic light ON here 

		// Let the semaphore cycle 2 times 
		repeat (2) begin 
			wait (state_out === GREEN);
			@(state_out);		// wait for GREEN to be over 
		end 

		// Disable the semaphore during Yellow state 
		wait (state_out === YELLOW);
		@(posedge clk); 
		enable = 0;						// USER forcibly turns it OFF in the middle of YEELOW 

		// Enable the semaphore again 
		repeat(10) @(posedge clk);
		@(posedge clk); 
		enable = 1;					// USER turns it back ON again 

		#40 $stop;

	end 



endmodule 


