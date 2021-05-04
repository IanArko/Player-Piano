`timescale 1ns / 1ps
/* -----------------------------------------------------------------------------
	MODULE: magnus_opus.v
	
	Testing our final project. Good luck y'all
----------------------------------------------------------------------------- */
module magnus_opus_tb();
	wire new_sample_generated;
	wire [15:0] sample_out;
	reg clk, reset;
	reg [7:0] switches;
	reg center_button, left_button, right_button, down_button;
	reg new_frame;
	
	magnus_opus dut(
	   .clk(clk),
		.reset(reset),
		.switches(switches),
		.center_button(center_button),
		.left_button(left_button),
		.right_button(right_button),
		.down_button(down_button),
		.new_frame(new_frame),          
		.new_sample_generated(new_sample_generated),
		.sample_out(sample_out)
	);
	
	// Test clk
	initial begin
		clk = 1'b1;
      forever #5 clk = ~clk;
   end
	
	/* -----------------------------------------------------------------------------
		TESTS
	----------------------------------------------------------------------------- */
	initial begin
		/***************************************************************
			Test 1: Reset
			
			Expectation: 
				- root goes to middle c
				- state starts in jam_sesh
		***************************************************************/
		reset = 1'b1;
		switches = 8'd0;
		center_button = 1'b0;
	   left_button = 1'b0;
		right_button = 1'b0;
		down_button = 1'b0;
		new_frame = 1'b0;
		#20
		reset = 1'b0;
		
		/* 
			TEST 6: WRITE SOME DAMN NOTES
			... we need to see the notes in the ram
		*/
		
		center_button = 1'b1;
		#10 center_button = 1'b0;
		

		#500
		switches = 8'd0;
		#500
		switches = 8'b100000000;
		#500
		switches = 8'd0;
		#500
		switches = 8'b010000000;
		#500
		switches = 8'd0;
		#500
		switches = 8'b001000000;
		#500
		switches = 8'd0;
		#500
		switches = 8'b000100000;
		#500
		switches = 8'd0;
		#500
		switches = 8'b000010000;
		#500
		switches = 8'd0;
		#500
		switches = 8'b000001000;
		#500
		switches = 8'd0;
		#500
		switches = 8'b000000100;
		#500
		switches = 8'd0;
		#500
		switches = 8'b000000010;
		#500
		switches = 8'd0;
		#500
		switches = 8'b000000001;
		#500
		switches = 8'd0;

		center_button = 1'b1;
		#10 center_button = 1'b0;
		
		#1000
		
		// move to sp
		down_button = 1'b1;
		#10 down_button = 1'b0;
		
		// press play	
		left_button = 1'b1;
		#20 left_button = 1'b0;
		
		#120 // just give it a sec for values to normalize
		
		center_button = 1'b1;
		#10 center_button = 1'b0;
		
		//song 2'd2 test;
		/*#100
		new_frame = 1'b1;
		#10 new_frame = 1'b0;
				
		#16170
		
		right_button = 1'b1;
		#20 right_button = 1'b0;
		
		center_button = 1'b1;
		#10 center_button = 1'b0;
		
		#16170*/
		$stop;
	end
	
endmodule