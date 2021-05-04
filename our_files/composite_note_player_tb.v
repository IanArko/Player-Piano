`timescale 1ns / 1ps
module composite_note_player_tb();
	`define JAM_SESH		2'b00
	`define COMPOSER		2'b01
	`define SONG_PLAYER	2'b11

	reg clk;
	reg reset;
	reg generate_next_sample;
	reg [5:0] song_note;
	reg [5:0] duration;
	wire [11:0] next_song_note = {song_note, duration};
	reg [5:0] jam_note;
	reg [1:0] state;
	reg play;
	reg beat;
	reg load_new_note;
	wire [15:0] sample_out;
	wire available;
	wire sample_ready;

	composite_note_player DUT (
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(next_song_note),
		.jam_note(jam_note),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_new_note),
		.sample_out(sample_out),
		.available(available)
	);

	// Initial Reset
	initial begin
		reset = 1;
		#10 reset = 0;
	end

	// Clock
	initial begin
		clk = 1;
		forever begin
			#5 clk = 0;
			#5 clk = 1;
		end
	end

	// Fake Beat Generator
	initial begin
		beat = 1'b0;
		forever begin
			#50 beat = 1'b1;
			#10 beat = 1'b0;
		end
	end

	// Initialize and Test
	initial begin
		song_note = 6'd0;
		duration = 6'd0;
		jam_note = 6'd0;
		state = 1'b00;
		play = 1'b0;
		load_new_note = 1'b0;
		generate_next_sample = 1'b0;
		
		#10 
		play = 1'b1;
		song_note = 6'b111000;
		jam_note  = 6'b000111;
		
		/* ----------------------------------------------------------------------------------- */
		/* Test that we are granting the correct note to note_to_translate given state and LNN */
		/* ----------------------------------------------------------------------------------- */
		
		state = `JAM_SESH;
		load_new_note = 1'b1;
		#10 load_new_note = 1'b0; 
		#30
		/* note_to_translate should be 000111 GOOD */
		
		state = `COMPOSER;
		load_new_note = 1'b1;
		#10 load_new_note = 1'b0; 
		#30
		/* note_to_translate should be 000111 GOOD */
		
		state = `SONG_PLAYER;
		load_new_note = 1'b1;
		#10 load_new_note = 1'b0; 
		#30
		/* note_to_translate should be 111000 GOOD */
		
		/* ----------------------------------------------------------------------------------- */
		/* Test that frequency ROM is working																	*/
		/* ----------------------------------------------------------------------------------- */
		
		state = `JAM_SESH;
		#100
		/* step_size_from_note should become {10'd013, 10'd275} after one cycle GOOD */
		 
		/* ----------------------------------------------------------------------------------- */
		/* Test Counter																								*/
		/* ----------------------------------------------------------------------------------- */
		state = `SONG_PLAYER;
		
		duration = 6'd8;
		generate_next_sample = 1'b1;
		repeat (16) begin
			#600
			load_new_note = 1'b1;
			#10 load_new_note = 1'b0;
			
		end
		/* available should go low, then go high after 4 beats until next_load_new_note (x16) */
		
		#1000
		
		/***************************************************************
			Test 4: JAM SESH
				
			Expectation: 
				- when jam_note == 0 ---> sample_out should be signed 0
				- when jam_note != 0 ---> sample_out should be some sample
		***************************************************************/
		state = `JAM_SESH;
		jam_note = 6'b101010;
		#500
		jam_note = 6'd0;
		
		
		#10000
		$stop;
	end

endmodule