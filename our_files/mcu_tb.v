module mcu_tb();
	// MASTER STATES
	`define JAM_SESH 		2'b00
	`define COMPOSER 		2'b01
	`define SONG_PLAYER 	2'b10
	
	//inputs
   reg clk, reset, play_button, next_button, song_done, prev_button;
	reg [1:0] master_state;
	 
	//outputs
   wire [1:0] song;
	wire play, reset_player;
	 

   mcu dut(
		.clk(clk),
		.reset(reset),
		.song_done(song_done),
			  
		.play_button(play_button),
		.next_button(next_button),
		.prev_button(prev_button),
			  
		.master_state(master_state),
			  
		.play(play),
		.reset_player(reset_player),
		.song(song)
	);

    // Clock and reset
	initial begin
		clk = 1'b1;
      reset = 1'b1;
      repeat (4) #1 clk = ~clk;
			reset = 1'b0;
      forever #1 clk = ~clk;
   end

    // Tests
    initial begin
		/***************************************************************
			Test 1: Reset
			
			Expectation: 
				- play should be 1
		***************************************************************/
		play_button = 1'b0;
		next_button = 1'b0;
		song_done = 1'b0;
		prev_button = 1'b0;
	   master_state = `JAM_SESH;
		#10
		
		/***************************************************************
			Test 1: MOVE INTO SP
			
			Expectation: 
				- play should be 0
		***************************************************************/
		master_state = `SONG_PLAYER;
		#10
		
		/***************************************************************
			Test 3: MOVE INTO LOCAL PLAY
			
			Expectation: 
				- play should be 1
		***************************************************************/
		play_button = 1'b1;
		#2
		play_button = 1'b0;
		#10
		
		/***************************************************************
			Test 4: MOVE to wait by hitting next
			
			Expectation: 
				- play should go to 0
				- increment song
				- move into wait
				- reset player should go high
		***************************************************************/
		next_button = 1'b1;
		#2
		next_button = 1'b0;
		
		/***************************************************************
			Test 5: large increment
			
			Expectation: 
				- song should overflow up
		***************************************************************/
		next_button = 1'b1;
		#12
		next_button = 1'b0;
		
		/***************************************************************
			Test 6: large decrement
			
			Expectation: 
				- song should overflow down
		***************************************************************/
		prev_button = 1'b1;
		#12
		prev_button = 1'b0;
		
		/***************************************************************
			Test 7: WAIT ==> PLAY ==> WAIT with PREV_BUTTON
			
			Expectation: 
				- decrement song
		***************************************************************/
		play_button = 1'b1;
		#2
		play_button = 1'b0;
		#10
		prev_button = 1'b1;
		#2
		prev_button = 1'b0;
		
		/***************************************************************
			Test 8: WAIT ==> PLAY ==> WAIT with SONG_DONE
			
			Expectation: 
				- increment song
		***************************************************************/
		play_button = 1'b1;
		#2
		play_button = 1'b0;
		#10
		song_done = 1'b1;
		#2
		song_done = 1'b0;
		
		/***************************************************************
			Test 9: WAIT ==> PLAY ==> PAUSE
			
			Expectation: 
				- increment song
		***************************************************************/
		play_button = 1'b1;
		#4
		play_button = 1'b0;
		
		/***************************************************************
			Test 10: PAUSE ==> WAIT on next_button
			
			Expectation: 
				- move to wait
				- incremnet counter
		***************************************************************/
		next_button = 1'b1;
		#2
		next_button = 1'b0;
		
		
    end
endmodule
