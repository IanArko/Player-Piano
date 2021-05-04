/* -----------------------------------------------------------------------------
	MODULE: MAGNUS_OPUS.v
	
	This module implements the following lower level modules:
		- master_lip_synth: controls master state
		- beat: the beat that controls timing throughout magnum_opus
		- song_player: reads from song_rom or song_ram
		- song_writer: writes to song_ram
		- song_ram: holds notes that are recorded when composer
		- note_to_sample: takes in a note, output a sample
		- codec_conditioner: controls board interfacing
  ----------------------------------------------------------------------------- */

module magnus_opus(
	/* SYSTEM INPUTS */
  	input clk,
   input reset,
	input [7:0] leds,
	 
	/* USER INPUTS */
	input [7:0] switches,
	input center_button,
   input left_button,
	input right_button,
	input down_button,
	input scale_button,

	input new_frame,                       // The raw new_frame signal from the ac97_if codec.
    
	output [1:0] master_state,
   output wire new_sample_generated,      // This output must go high for one cycle when a new sample is generated.
   output wire [15:0] sample_out,         // Our final output sample to the codec. This needs to be synced to new_frame.
	output [1:0] song,                      // Output from Lip_Synth_Master for use with LEDs
	output [55:0] to_display
);

	/* -----------------------------------------------------------------------------
		Interface Connections
	----------------------------------------------------------------------------- */
	wire beat;								// output of beat generator
	wire play;                     	// output of song_player

	wire [5:0] root;						// output of lip_synth_master to keep track of maajor scale

	wire [14:0] song_player_note;  	// output from song_player
	wire load_new_notes;           	// output from song_player
	wire [1:0] song;                 // output from song_player for leds
	wire [47:0] jam_notes;           // output of song_writer

	wire finished_recording;			// output of...
	wire start_recording;            // output of note_writer resets RAM on new recording
	
	wire done_recording;
	
	wire write_en;
	wire [6:0] write_address;
	wire [15:0] write_payload;
	
	wire [6:0] read_address;       	// INPUT TO SONG_RAM FROM SONG_PLAYER
	wire [15:0] ram_note;			   // OUTPUT FROM SONG_RAM TO SONG_PLAYER

	wire generate_next_sample;     	// OUTPUT OF CODEC INPUT TO BEAT AND NOTES_TO_SAMPLE
	wire new_sample_ready;         	// OUTPUT OF NOTE_TO_SAMPLES FOR CODEC TO LATCH IN VALUE
	wire [15:0] final_sample;      	// OUTPUT OF NOTE_TO_SAMPLE FOR CODEC	
		
	
	/* -----------------------------------------------------------------------------
		lip_synth_master
	----------------------------------------------------------------------------- */
	/* lip_synth_master interfaces with the FPGA board buttons and outputs the master 
	   state of our magnum_opus:
	  
	 	jam_sesh: 
	 	    - the user can use the board switches to play notes
	 	    - right and left buttons shift the playable scale up and down chromatically 
	 	composer:
	 	    - the switches being played are recorded and written to song_ram
	 	song_player:
		    - similar to lab4; can play the three loaded songs or the fourth recording
	 */
	lip_synth_master lip_synth_master (
		.clk(clk),
		.reset(reset),
		
		.finished_recording(finished_recording),	// indicates the recording has finished from note_to_rom	
      .center_but(center_button),		
      .left_but(left_button),
	   .right_but(right_button),
	   .down_but(down_button),		        
		
		.done_recording(done_recording),
		.state(master_state),			
	   .root(root)				
	);	
	
	//  ****************************************************************************
	//      Song Player
	//  ****************************************************************************
	
	wire reset_note_player;
	song_player song_player(
		// system inputs
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		// inputs for mcu
		.master_state(master_state),
		.play_button(center_button),
		.next_button(right_button),
		.prev_button(left_button),
		
		// inputs for ram writing
		.write_enable(write_en),
      .write_address(write_address),
      .write_payload(write_payload),	
		.clear_ram_pulse(start_recording),
		
		// outputs
		.note_out(song_player_note),
		.load_new_note(load_new_notes),
		.play(play),
		.current_song(song),
		.reset_note_player(reset_note_player)
	);
	
	//  ****************************************************************************
	//      Song Writer
	//  ****************************************************************************
	
	song_writer song_writer(
		//system inputs
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		//logical inputs
		.root(root),        
		.state(master_state),
		.switches(switches),
		.scale_button(scale_button),
		
		
		// OUTPUTS: //TODO:
		.notes(jam_notes),
      .finished_recording(finished_recording),
		.start_recording(start_recording),
		
		// OUTPUTS: write to ram.
      .write_enable(write_en),
      .write_address(write_address),
      .write_payload(write_payload)		
	);
	
	
	//  ****************************************************************************
	//      note_to_sample
	//  ****************************************************************************
	
	note_to_sample note_to_sample(
		.clk(clk),
		.reset(reset | reset_note_player),
		.play(play),
		.song_note(song_player_note),
		.jam_note(jam_notes),
		.state(master_state),
		.beat(beat),
		.load_new_note(load_new_notes),
		.generate_next_sample(generate_next_sample),
		
		.new_sample_ready(new_sample_ready), 
		.out_sample(final_sample),
		.to_display(to_display)
	);
	
	
	//  ****************************************************************************
	//      Codec Conditioner
	//  ****************************************************************************
   
	codec_conditioner codec_conditioner(
		.clk(clk),
		.reset(reset),
		.new_sample_in(final_sample),
		.latch_new_sample_in(new_sample_ready),
		.generate_next_sample(generate_next_sample),
		.new_frame(new_frame),
		.valid_sample(sample_out)
   );
	
	/* -----------------------------------------------------------------------------
		beat_generator
	----------------------------------------------------------------------------- */
	//  By default this will divide the generate_next_sample signal (48kHz from the
	//  codec's new_frame input) down by 1000, to 48Hz. If you change the BEAT_COUNT
	//  parameter when instantiating this you can change it for simulation.
	// 
	/* ** NOTE **************************************************************** */
	//  FOR SIMULATION USE:
	//  	- .en(1'b1)
	//    - BEAT_COUNT = 4 
	
	parameter BEAT_COUNT = 4;
	//parameter BEAT_COUNT = 1000;
	assign new_sample_generated = generate_next_sample;
	beat_generator #(.WIDTH(10), .STOP(BEAT_COUNT)) beat_generator(
		.clk(clk),
      .reset(reset),
      //.en(generate_next_sample),
		.en(1'b1),
		
		.beat(beat)
  	);
	
endmodule
