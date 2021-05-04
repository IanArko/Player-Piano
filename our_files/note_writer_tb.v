/* -----------------------------------------------------------------------------
	MODULE: note_writer_tb.v
	
	This module tests note_writer
----------------------------------------------------------------------------- */

`timescale 1ns / 1ps

module note_writer_tb();
	reg clk, beat;
	reg reset, switch;
	reg [6:0] cur_ram;
	reg [5:0] note;
	wire [22:0] payload;
	wire write_enable;
	wire switch_high_pulse;
	wire switch_low_pulse;
	
	note_writer dut(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		.cur_ram(cur_ram),
		.switch(switch), 
		.note(note),
		.is_hold_writer(1'b1),
		 
		.payload(payload),
		.switch_high_pulse(switch_high_pulse),
		.switch_low_pulse(switch_low_pulse),
		.write_enable(write_enable)
	);
	
	/* -----------------------------------------------------------------------------
			Tests
		----------------------------------------------------------------------------- */
	// Test clk
    initial begin
        clk = 1'b1;
        forever #5 clk = ~clk;
    end
	 
	 // Test Beat
    initial begin
		  beat = 1'b1; 
        forever begin 
			  #5 beat = 1'b0; 
			  #15 beat = 1'b1; 
		  end
    end
	 
	
	initial begin
		/***************************************************************
			Test 1: RESET
			
			Expectation: 
				- state ==> WAIT
				- 
		***************************************************************/
	   note = 6'd0;
		reset = 1'b1;
		switch = 1'b0;
		cur_ram = 7'd25;
		#15 
		reset = 1'b0;
		
		
		/***************************************************************
			Test 2: FLIP A SWITCH
			
			Expectation: 
				- switch should go high.
				- when switch goes high: STATE ==> COUNT
				- we should start counting each time there is a beat
				- when: switch 1 --> 0, then duration should be 10
				- payload shouldn't change until switch goes low.
		***************************************************************/
	   note = 6'b101010;
		switch = 1'b1;
		cur_ram = 7'b1111111;
		//cur_ram = 7'b0000000;
		#10
		//cur_ram = 7'b1111111;
		cur_ram = 7'b0000000;
		#190
		switch = 1'b0;
		
		#100
		switch = 1'b1;
	end
endmodule
