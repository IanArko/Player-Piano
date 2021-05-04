/* -----------------------------------------------------------------------------
	MODULE: mcu.v
	
	MCU takes in user input and controls which song song_reader is reading and 
	controls pause/play (play = 0/1 respectively)
----------------------------------------------------------------------------- */

module mcu(
    input wire clk,                // Standard system clk inuput
    input wire reset,              // Standard system reset inuput
	 
	 input wire [1:0] master_state, // used to keep states in mcu stationary when not in song player
    input wire play_button,		  // A one-cycle pulse indicating the play button has been pressed
    input wire next_button,		  // A one-cycle pulse indicating the next button has been pressed
	 input wire prev_button,		  // A one-cycle pulse indicating the PREV button has been pressed
    input wire song_done,			  // From the song_reader, indicating that the current song has finished (pulse, shifts state)
	 
	 output wire play,				  // True if system should be playing, false if no audio-output should be generated (false if paused or end of song... persistent signal)
    output reg reset_player,	     // High when the player is moving to the next song... resets the other parts of the of the system so they arent blah blah blah (high if next_button? song ends?)
    output wire [1:0] song		     // the song to play (0, 1, 2, 3)
);
	
	/* -----------------------------------------------------------------------------
		DECLARATIONS AND ASSIGNMENTS
	----------------------------------------------------------------------------- */
	//  LOCAL STATES
	`define AWAIT 	   2'd0
   `define PLAY   	2'd1
	`define PAUSED 	2'd2
		
	//  wire assignments
	reg [1:0] next_state;			// the next state in our FSM
	wire [1:0] state;					// output of flip-flop. Conatins the current state.
	assign play = (master_state == 2'b10) && (state == `PLAY);
	reg [1:0] next_song;
	wire not_song_player = (master_state != 2'b10);
	wire leave_song = song_done || next_button || prev_button;
	
	/* -----------------------------------------------------------------------------
		FLIP FLOPS AND FSM
	----------------------------------------------------------------------------- */
	dffr #(.WIDTH(2)) mcu_state_ff(
		.clk(clk),
		.r(reset),
		.d(next_state),
		.q(state)
	);
	
	dffr #(.WIDTH(2)) song_counter(
		.clk(clk),
		.r(reset),
		.d(next_song),
		.q(song)
	);
	
	always @(*) begin
			case(state)
				`AWAIT: begin
					next_state = play_button ? `PLAY : `AWAIT;
					next_song = (not_song_player) ? song : ((next_button) ? (song + 2'd1) : (prev_button) ? (song - 2'd1) : song);
					reset_player = 1'b0;
				end
				
				`PLAY: begin
					next_state = (leave_song) ? `AWAIT : (play_button ? `PAUSED : `PLAY);
					next_song = (not_song_player) ? song : ((next_button || song_done)? (song + 2'd1) : (prev_button) ? (song - 2'd1) : song);
					reset_player = leave_song ? 1'b1 : 1'b0;
				end
				
				`PAUSED: begin
					next_state = (leave_song) ? `AWAIT : (play_button ? `PLAY : `PAUSED);
					next_song = (not_song_player) ? song : ((next_button || song_done)? (song + 2'd1) : (prev_button) ? (song - 2'd1) : song);
					reset_player = leave_song ? 1'b1 : 1'b0;
				end
				
				default: begin
					next_state = `AWAIT;
					next_song = 2'd0;
					reset_player = 1'b1;
				end
			endcase
		end

endmodule
