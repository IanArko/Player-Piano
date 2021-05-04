`timescale 1ns / 1ps
module lip_synth_master_tb();

	/* -----------------------------------------------------------------------------
		Tests
	----------------------------------------------------------------------------- */
	reg clk, reset;     
   reg center_button, down_button, left_button, right_button;
	reg done_recording;		
   wire [1:0] state;
	wire [5:0] root;
	
	lip_synth_master dut(
		.clk(clk),
		.reset(reset),
		.center_but(center_button),
		.down_but(down_button),
		.left_but(left_button),
		.right_but(right_button),
		.done_recording(done_recording),
		.state(state),
		.root(root)
	);	
	
	initial begin
        clk = 1'b1;
        forever #5 clk = ~clk;
    end
	
	/* -----------------------------------------------------------------------------
		Tests
	----------------------------------------------------------------------------- */
	 initial begin
		/* -----------------------------------------------------------------------------
				Test 1: Reset
		----------------------------------------------------------------------------- */
		reset = 1'b1;
		center_button = 1'b0;
		down_button = 1'b0;
		left_button = 1'b0;
		right_button = 1'b0;
		done_recording = 1'b0;
		#10
		reset = 1'b0;
		
		/* -----------------------------------------------------------------------------
				Test 1: Center_Button: COMPOSER ===> JAM_SESH
		----------------------------------------------------------------------------- */
		#10
		center_button = 1'b1;	// switch to composer
		#10
		center_button = 1'b0;
		#20
		
		/* -----------------------------------------------------------------------------
				Test 2: Center_Button: JAM_SESH ===> COMPOSER
		----------------------------------------------------------------------------- */
		center_button = 1'b1;	// switch to jam_sesh
		#10
		center_button = 1'b0;
		#30		
		
		/* -----------------------------------------------------------------------------
				Test 3: DONE_RECORDING TESTS
		----------------------------------------------------------------------------- */
		done_recording = 1'b1;	// stay in jamsesh / do nothing
		#10
		done_recording = 1'b0;
		#10
		center_button = 1'b1;	// switch to composer
		#10
		center_button = 1'b0;
		#10
		done_recording = 1'b1;	// switch to jamsesh
		#10
		done_recording = 1'b0;
		#30
		
		
		/* -----------------------------------------------------------------------------
				Test 4: shifting to song_player from jam_sesh and then composer
		----------------------------------------------------------------------------- */
		down_button = 1'b1;		// switch to song_player
		#10
		down_button = 1'b0;
		#10
		center_button = 1'b1;	// should do nothing
		#10
		center_button = 1'b0;
		#10
		done_recording = 1'b1;	// should do nothing
		#10
		done_recording = 1'b0;
		#10
		down_button = 1'b1;		// switch to jam_sesh
		#10
		down_button = 1'b0;
		#10
		center_button = 1'b1;	// switch to composer
		#10
		center_button = 1'b0;
		#10
		down_button = 1'b1;		// should do nothing.
		#10
		down_button = 1'b0;	
		#10
		center_button = 1'b1;	// return to jam_sesh
		#10
		center_button = 1'b0;
		#10
		
		
		/* -----------------------------------------------------------------------------
				Test 5: incrementing and decrementing root.
		----------------------------------------------------------------------------- */	
		// Decrement. Ensure that the root goes no lower than 1.
		left_button = 1'b1;
		#400
		left_button = 1'b0;
		
		// Increment. Ensure that the root goes no higher than 56.
		right_button = 1'b1;
		#800
		right_button = 1'b0;
		
		//Decrement again
		left_button = 1'b1;
		#800
		left_button = 1'b0;
		
		//Increment again
		right_button = 1'b1;
		#400
		right_button = 1'b0;
		
		// Make sure that we can't change the roots in other states.
		center_button = 1'b1; // switch to composer
		#10
		center_button = 1'b0;
		left_button = 1'b1;
		#40
		left_button = 1'b0;
		
		center_button = 1'b1; // switch back to js
		#10
		center_button = 1'b0;
		#10
		
		down_button = 1'b1;  // switch to song_player
		#10
		down_button = 1'b0;
		
		left_button = 1'b1; // check root doesn't change in song_player
		#100
		left_button = 1'b0;
		end
endmodule
