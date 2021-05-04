
/* -----------------------------------------------------------------------------
	MODULE: song_player_tb.v
	
	Testing our final project. Good luck y'all
----------------------------------------------------------------------------- */
`timescale 1ns / 1ps
module song_player_tb();
	//state declarations
	`define JAM_SESH 		2'b00
	`define COMPOSER 		2'b01
	`define SONG_PLAYER 	2'b10
	
	//inputs
	reg clk, beat, reset;
	reg play_button, next_button, prev_button;
	reg [1:0] master_state;
	
	 reg [6:0] write_address;
    reg [15:0] write_payload;
	 reg done_recording, write_enable;
	//outputs
	wire [11:0] note_out;
	wire load_new_note;
	wire play;
	
	song_player dut(
		.clk(clk),
		.reset(reset),                
		.beat(beat),
		
		.play_button(play_button),  
		.next_button(next_button),            
		.prev_button(prev_button),
		.master_state(master_state),
		
		.write_address(write_address),
		.write_payload(write_payload),
		.done_recording(done_recording),
		.write_enable(write_enable),
		.note_out(note_out),
		.load_new_note(load_new_note),
		.play(play)
	);

	// Test clk
	initial begin
		clk = 1'b1;
      forever #5 clk = ~clk;
   end
	
	// Test Beat
    initial begin
		  beat = 1'b1; 
        forever begin 
			  #10 beat = 1'b0; 
			  #40 beat = 1'b1; 
		  end
    end
	 
	 /* -----------------------------------------------------------------------------
		TESTS
	----------------------------------------------------------------------------- */
	initial begin
		write_enable = 1'b0;
		reset = 1'b1;
		#10 reset = 1'b0;
		#2000
		
		/***************************************************************
			Test 1: Reset
			
			Expectation: 
				- play is 1
				- mcu is in its hold state.
				- song is song 0
		***************************************************************/
		//reset = 1'b1;
		play_button = 1'b0;
		next_button = 1'b0;
		prev_button = 1'b0;
	   master_state = `JAM_SESH;
		#10
		//reset = 1'b0;
		play_button = 1'b0;
		next_button = 1'b0;
		prev_button = 1'b0;
	   master_state = `JAM_SESH;
		
		/***************************************************************
			Test 2: Move master into song_player
			
			Expectation: 
				- play: 1 ==> 0
		***************************************************************/
		master_state = `SONG_PLAYER;
		
		/***************************************************************
			Test 3: PLAY THE SONG
			
			Expectation: 
				- play_button = 1;
		***************************************************************/
		play_button = 1'b1;
		#10
		play_button = 1'b0;
		#50
		/***************************************************************
			Test 2.5: Write to Ram
			
			Expectation: 
				- we should the values of RAM change
				- when done_recording goes high, max_ram_address should gain 
				  value of write_address
		***************************************************************/
	   write_enable = 1'd1;
		
		write_address = 7'd0;
      write_payload = {1'b1, 6'd0, 6'd0, 3'd0};
		#10
		
		write_address = 7'd1;
      write_payload = {1'b0, 6'd23, 6'd5, 3'd0};
		#10
		
		write_address = 7'd2;
      write_payload = {1'b0, 6'd24, 6'd5, 3'd0};
		#10
		
		write_address = 7'd3;
      write_payload = {1'b1, 6'd0, 6'd10, 3'd0};
		#10

		write_address = 7'd4;
      write_payload = {1'b0, 6'd22, 6'd5, 3'd0};
		#10
		
		write_enable = 1'd0;
		
		done_recording = 1'b1;
		#10
		done_recording = 1'b0;
		#20
		/***************************************************************
			Test 3: Thorough test
			
			Expectation: 
			goes to the next song and plays
			then pauses then plays and goes to next song while playing
		***************************************************************/
		master_state = `JAM_SESH;
		#10
		master_state = `SONG_PLAYER;
		#10
		next_button = 1'b1;
		#10
		next_button = 1'b0;
		play_button = 1'b1;
		#10
		play_button = 1'b0;	//playing, supposedly
		#100
		play_button = 1'b1;
		#10
		play_button = 1'b0;	//paused in song 01
		#10
		play_button = 1'b1;
		#10
		play_button = 1'b0;	//playing song 01
		#20
		next_button = 1'b1;	
		#10
		next_button = 1'b0;	//paused in song 10
		#10
		next_button = 1'b1;
		#10
		next_button = 1'b0;	//paused in song 11
		#10
		play_button = 1'b1;
		#10
		play_button = 1'b0;	//playing song 11
		#30
		play_button = 1'b1;
		#10
		play_button = 1'b0;	//paused in song 11
		#10
		next_button = 1'b1;
		#10
		next_button = 1'b0;	//paused in song 00
		#10
		play_button = 1'b1;
		#10
		play_button = 1'b0;	//play song 00
		#50
		play_button = 1'b1;
		#10
		play_button = 1'b0;	//pause song 00
		#10
		//play till song done of ram song
		next_button = 1'b1;
		#10
		next_button = 1'b0;	//pause song 01
		#10
		next_button = 1'b1;
		#10
		next_button = 1'b0;	//pause song 10
		#10
		next_button = 1'b1;
		#10
		next_button = 1'b0; //pause song 11
		#10
		play_button = 1'b1;
		#10
		play_button = 1'b0;	//play song 11
		#500
		$stop;
		
	end
endmodule
