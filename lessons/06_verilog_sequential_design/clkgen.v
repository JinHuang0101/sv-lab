// A testbench module that generates three clock signals 
// with different frequencies and duty cycles 
// It's meant to produce clock waveforms for testing other modules/drive sequential logic (flip-flops, counters) 
// Timing:
// clock1: Period = 2*0.5us = 1us(1 MHz), toggles every 0.5us
// clock2: Period = 2*0.25us = 0.5us(2 MHz), toggles every 0.25us
// clock3: Period = 0.3us + 0.7us = 1us(1 MHz), high for 30%(0.3us), low for 70%(0.7us)
// Simulation runs for 40us, producing 40 cycles of clock1, 80 cycles of clock2, 
// and 40 cycles of clock3
// Duty cycle:
// 50% duty cycle: equal high and low times, achieved by toggling after half the period 
// 30% duty cycle: high for 30% of the period(0.3us), low for 70%(0.7us), explicitly controlled in the initial block 


`timescale 1u/1ns 

// A clock generator testbench, no inputs or outputs 
module clkgen();

	// Testbench parameters that define timing for clock1 and clock2
	parameter HALF_PERIOD_CLK1 = 0.5;		// Half-period for clock1 (0.5us = 500 ns)
	parameter HALF_PERIOD_CLIK2 = 0.25;		// Half-period for clock2 (0.25us = 250 ns)

	// Testbench registers for clock signals 
	reg clock1;				// 1 MHz clock, 1us period, 50% duty cycle (0.5us high, 0.5us low) 
	reg clock2 = 0;			// 2 MHz clock, 0.5us period, 50% duty cycle(0.25us high, 0.25us low), initialized to 0
	reg clock3;				// 1 MHz clock, 1us period, 30% duty cycle(0.3us high, 0.7us low) 


	// Initial block to generate clock1 (1 MHz, 50% duty cycle) 
	initial begin 
		clock1 = 0;				// Initialize clock1 to 0, ensures it starts low
		forever begin				// Run indefinitely 
			#(HALF_PERIOD_CLK1);	// Delay for half-period (0.5 us)
			clock1 = ~clock1;		// Toggle clock1 (0 to 1 or 1 to 0)
		end 

	end 


	// Always block to generate clock2 (2 MHz, 50% duty cycle)
	// Implicitly continuous
	always begin 
		#(HALF_PERIOD_CLK2);		// Delay for half-period (0.25us)
		clock2 = ~clock2;			// Toggle clock2 
	end 

	// Initial block to generate clock3 (1 MHz, 30% duty cycle)
	// clock3 explicitly sets high(0.3us) and low(0.7us) times
	// for a 30% duty cycle 
	initial begin 
		clock3 = 1; 
		forever begin 
			clock3 = 1; #(0.3);		// Set clock3 to 1 for 0.3 us(30% of 1us period)
			clock3 = 0; #(0.7);		// Set clock3 to 0 for 0.7 us(70% of 1us period)
		end 
	end 

	// Initial block to control simulation duration 
	initial begin 
		#40; 
		$stop;			// at 40us, halts the simulator 
		$display("End of CLKGEN");	// Print message, won't be executed due to $stop
	end 

endmodule 
