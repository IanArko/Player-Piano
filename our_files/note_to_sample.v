/* -----------------------------------------------------------------------------
	MODULE: note_to_sample.v
	
	Takes in notes and switches, allocates inputs to internally instantiated note_players,
	sends the samples to superpotion, then outputs the current sample.
	
	TODO: duration is fed into all note_players... fix this (maybe fixed in
	composite_note_player by linking duration to load_new_note).. But this seems 
	like a patch, it would be easier to send duration and song note together...
----------------------------------------------------------------------------- */
module note_to_sample(
    input wire clk,
	 input wire reset,
	 input wire beat,
	 input wire play,
    input wire [14:0] song_note,
	 input wire [47:0] jam_note,
    input wire [1:0] state,
	 input wire load_new_note,
	 input wire generate_next_sample,
	 
	 output wire new_sample_ready,
	 output wire [15:0] out_sample,
	 output wire [55:0] to_display
);

	/* -----------------------------------------------------------------------------
		Instantiate wires/regs
	----------------------------------------------------------------------------- */
	wire [127:0] samples;
	wire [7:0] load_np = {8{load_new_note}} & player_to_use; //Whichever np will be used is 1, o/w it is 0.

	/* -----------------------------------------------------------------------------
		Instantiate Note Players
	----------------------------------------------------------------------------- */
	composite_note_player NP0(
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(song_note),
		.jam_note(jam_note[5:0]),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_np[0]),
		.sample_out(samples[15:0]),
		.available(free_np[0]),
		.to_display(to_display[55:49])
	);
	
	composite_note_player NP1(
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(song_note),
		.jam_note(jam_note[11:6]),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_np[1]),
		.sample_out(samples[31:16]),
		.available(free_np[1]),
		.to_display(to_display[48:42])
	);
	
	composite_note_player NP2(
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(song_note),
		.jam_note(jam_note[17:12]),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_np[2]),
		.sample_out(samples[47:32]),
		.available(free_np[2]),
		.to_display(to_display[41:35])
	);
	
	composite_note_player NP3(
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(song_note),
		.jam_note(jam_note[23:18]),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_np[3]),
		.sample_out(samples[63:48]),
		.available(free_np[3]),
		.to_display(to_display[34:28])
	);
	
	composite_note_player NP4(
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(song_note),
		.jam_note(jam_note[29:24]),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_np[4]),
		.sample_out(samples[79:64]),
		.available(free_np[4]),
		.to_display(to_display[27:21])
	);
	
	composite_note_player NP5(
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(song_note),
		.jam_note(jam_note[35:30]),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_np[5]),
		.sample_out(samples[95:80]),
		.available(free_np[5]),
		.to_display(to_display[20:14])
	);
	
	composite_note_player NP6(
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(song_note),
		.jam_note(jam_note[41:36]),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_np[6]),
		.sample_out(samples[111:96]),
		.available(free_np[6]),
		.to_display(to_display[13:7])
	);
	
	composite_note_player NP7(
		.clk(clk),
		.reset(reset),
		.generate_next_sample(generate_next_sample),
		.next_song_note(song_note),
		.jam_note(jam_note[47:42]),
		.state(state),
		.play(play),
		.beat(beat),
		.load_new_note(load_np[7]),
		.sample_out(samples[127:112]),
		.available(free_np[7]),
		.to_display(to_display[6:0])
	);
	
	
	/* -----------------------------------------------------------------------------
		Arbitration Logic
	----------------------------------------------------------------------------- */
	wire [7:0] free_np;
	wire [7:0] player_to_use;
	arbiter #(.n(8)) ARBITER(
		.r(free_np),
		.g(player_to_use)
	);
	
	
	/* -----------------------------------------------------------------------------
		Superposition
	----------------------------------------------------------------------------- */
	superposition SUPER(
		.clk(clk),
		.samples(samples),
		.out_sample(out_sample),
		.generate_new_sample(generate_next_sample),
		.new_sample_ready(new_sample_ready)
	);
	
endmodule