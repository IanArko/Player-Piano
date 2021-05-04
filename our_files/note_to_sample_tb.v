`timescale 1ns / 1ps
`define JAM_SESH		2'b00
`define COMPOSER		2'b01
`define SONG_PLAYER	2'b10

module note_to_sample_tb();
	 reg clk, reset, play, beat;
    reg [11:0] song_note = 6'd0;
	 reg [47:0] jam_note = 47'd0;
    reg [1:0] state = `SONG_PLAYER;
	 reg load_new_note = 1'd0;
	 reg generate_next_sample;
	 wire new_sample_ready;
	 wire [15:0] out_sample;
	 
	 note_to_sample DUT (
				.clk(clk),
				.reset(reset),
				.play(play),
				.song_note(song_note),
				.jam_note(jam_note),
				.state(state),
				.beat(beat),
				.load_new_note(load_new_note),
				.generate_next_sample(generate_next_sample),
				.new_sample_ready(new_sample_ready),
				.out_sample(out_sample)
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
			  #10 beat = 1'b0; 
			  #40 beat = 1'b1; 
		  end
    end
	 
	
	initial begin
		/***************************************************************
			Test 2: Loading a note player
			
			Expectation: 
				- the note_players all become available
		***************************************************************/
		play = 1'b1;
	   generate_next_sample = 1'b0;
		reset = 1'b1;
		#10
		reset = 1'b0;
		
		/***************************************************************
			Test 2: Loading a note player
			
			Expectation: 
				- we should load a note player
				- see available note players chnage
				- after duration beats we should see the np become available again
		***************************************************************/
		song_note = {6'b111111, 6'd4};
		load_new_note = 1'b1;
		#10
		load_new_note = 1'b0;
		
		/***************************************************************
			Test 3: Loading a chord
			
			Expectation: 
				- we should load 3 note players with a one cycle latency loading 
				- see the first 3 note_players change accordingly
		***************************************************************/
		generate_next_sample = 1'b1;
		
		song_note = {6'b111111, 6'd4};
		load_new_note = 1'b1;
		#10
		load_new_note = 1'b0;
		
		song_note = {6'b100111, 6'd6};
		load_new_note = 1'b1;
		#10
		load_new_note = 1'b0;
		
		song_note = {6'b100001, 6'd8};
		load_new_note = 1'b1;
		#10
		load_new_note = 1'b0;
		
		#1000
		
		/***************************************************************
			Test 4: JAM SESH/ SUPERPOSITION
			
			Expectation: 
				- see signals only for switches that are on ***** TODO: fix cNP? 
				- see the signals add properly from superposition when using modelsim
		***************************************************************/
		state = `JAM_SESH;
		jam_note ={6'd0, 6'd0, 6'd0, 6'd0, 6'd0, 6'd0, 6'd0, 6'd40};
		#1000
		jam_note ={6'd10, 6'd0, 6'd0, 6'd0, 6'd0, 6'd0, 6'd0, 6'd0};
		#1000
		jam_note ={6'd10, 6'd12, 6'd14, 6'd15, 6'd17, 6'd19, 6'd21, 6'd22};
		#1000
		jam_note ={6'd0, 6'd0, 6'd0, 6'd0, 6'd0, 6'd0, 6'd0, 6'd0};
		#1000
		$stop;
	end

endmodule
