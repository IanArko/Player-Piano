module composite_note_player (
	input 			clk,
	input				reset,
	input				beat,
	input 			play,
	input [1:0] 	state,
	input [14:0]	next_song_note,
	input [5:0]		jam_note,
	input				load_new_note,
	input				generate_next_sample,
	
	output reg [15:0]	sample_out,
	output reg			available,
	output wire [6:0] to_display
);

	`define JAM_SESH		2'b00
	`define COMPOSER		2'b01
	`define SONG_PLAYER	2'b10
	
	/* ---------------------------------------------------------
		Datapath
	--------------------------------------------------------- */
	
	/* Note: cases on state and grants correct note source) */
	
	// latches in the note and duration when we recieve a load_new_note signal
	wire[5:0] song_note;
	wire[8:0] song_note_duration;
	dffre #(.WIDTH(15)) NOTE_GRANT (
		.clk(clk),
		.r(reset),
		.en(load_new_note),
		.d(next_song_note),
		.q({song_note, song_note_duration})
	);
	
	// chooses which note is getting passed through
	reg [5:0] note_to_translate;
	always @(*) begin
		case (state) 
			`SONG_PLAYER:	note_to_translate = song_note;
			`COMPOSER:	note_to_translate = jam_note;
			`JAM_SESH:	note_to_translate = jam_note;
			default:	note_to_translate = 6'd0;
		endcase
	end
	
	// sent to be displayed on the piano */
	assign to_display = {|sample_out, note_to_translate};
	 
	wire [19:0] step_size_from_note;
	frequency_rom FREQ_ROM (
		.clk(clk),
		.addr(note_to_translate),
		.dout(step_size_from_note)
	);
	
	reg [19:0] step_size_to_reader;
	always @(*) begin
		case (play || state != `SONG_PLAYER) 
			1'b1:			step_size_to_reader = step_size_from_note;
			1'b0: 		step_size_to_reader = 20'd0;
			default: 	step_size_to_reader = 20'd0; 
		endcase
	end
	
	wire [15:0] intermediate_sample;
	sine_reader SINE_READER (
		.clk(clk),
		.reset(reset),
		.step_size(step_size_to_reader),
		.generate_next(generate_next_sample),
		.sample_ready(),
		.sample(intermediate_sample)
	); 
	
	always @(*) begin
		case (available & (state == `SONG_PLAYER))
			1'b0: 		sample_out = intermediate_sample;
			1'b1: 		sample_out = 16'd0;
			default: 	sample_out = 16'd0;
		endcase
	end
	
	/* ---------------------------------------------------------
		Control FSM
	--------------------------------------------------------- */
	
	`define COUNTING	1'b0
	`define AVAILABLE 	1'b1
	
	reg next_control_state;
	wire curr_control_state;
	dffr #(.WIDTH(1)) STATE_CONTROL (
		.clk(clk),
		.r(reset),
		.d(next_control_state),
		.q(curr_control_state)
	);
	
	reg [8:0] next_count;
	wire [8:0] curr_count;
	dffre #(.WIDTH(9)) COUNTER (
		.clk(clk),
		.r(reset || available), // tightens timing just a bit.
		.en(beat),
		.d(next_count),
		.q(curr_count)
	);
	
	always @(*) begin
		case (curr_control_state)
			`COUNTING: begin
				available = (curr_count == song_note_duration) ? 1'b1 : 1'b0;
				next_count = (play) ? curr_count + 9'd1 : curr_count;
				next_control_state = (curr_count == song_note_duration) ? `AVAILABLE : `COUNTING;
			end
			
			`AVAILABLE: begin
				available = 1'b1;
				next_count = 6'd0;
				next_control_state = (load_new_note) ? `COUNTING : `AVAILABLE;
			end 
			
			default: begin
				available = 1'b1;
				next_count = 6'd0;
				next_control_state = `AVAILABLE;
			end

		endcase
	end

endmodule