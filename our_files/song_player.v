/* -----------------------------------------------------------------------------
	MODULE: song_player.v
	
	Song player takes in user inputs and outputs notes as required to 
	the note_to_sample module. when doing so, load_new_note will go high. 
	
	Note:
		- This module resets ram before recording.
----------------------------------------------------------------------------- */
module song_player(
    input clk,                    // Standard system clock and reset
    input reset,                  // Standard system clock and reset
	 input beat,
	 
	 // inputs for MCU
    input play_button,            // debounced input for MCU
    input next_button,            // debounced input for MCU
	 input prev_button,				 // debounced input for MCU
	 input [1:0] master_state,
	 
	 // inputs to write to ram
	 input write_enable,
    input [6:0] write_address,
    input [15:0] write_payload,
	 input clear_ram_pulse,
	 
    output [14:0] note_out,
	 output load_new_note,
	 output play,
	 output [1:0] current_song,
	 output reset_note_player
);

	//  ****************************************************************************
	//      WIRE/REG DECLARATION
	//  ****************************************************************************
	
	// RAM RESET WIRES
	wire address_mux_control = curr_reset_addr == 8'd128;  // control MUX reset vs write
	wire [7:0] curr_reset_addr;                            // current address in reset process
	reg [6:0] addr_to_write;                              // controls write address vs reset
	reg [15:0] payload_to_write;                           // controls write payload vs reset
	
	wire song_done;                                        // Output from song Reader alerts mcu to inc
	wire clear_ram_pulse;                                  // One cycle pulse when state ==> composer

	//  ****************************************************************************
	//      Master Control Unit
	//  ****************************************************************************
	//   The reset_player output from the MCU is run only to the song_reader because
	//   we don't need to reset any state in the note_player.
    
	mcu mcu(
		//  system inputs
		.clk(clk),
		.reset(reset),
		
		//  state control inputs
		.master_state(master_state),
		.play_button(play_button),
		.next_button(next_button),
		.prev_button(prev_button),
		.song_done(song_done),
		
		//  outputs
		.play(play),
		.reset_player(reset_note_player),
		.song(current_song)
	);

	//  ****************************************************************************
	//      Song Reader
	//  ****************************************************************************

	song_reader song_reader(
		.clk(clk),
		.beat(beat),
		.reset(reset | reset_note_player),
		.play(play),
		.song(current_song),
			  
		// inputs to write to RAM
		.write_enable(write_enable || ~address_mux_control),
		.write_address(addr_to_write),
		.write_payload(payload_to_write),
				  
		//  outputs
		.note_out(note_out[14:9]),
		.duration_out(note_out[8:0]),
		.song_done(song_done),
		.load_new_note(load_new_note)
    );
	 
	 
	//  ****************************************************************************
	//      RAM RESET LOGIC
	//  ****************************************************************************	 
	
	dffre #(.WIDTH(8)) RAM_RESET (
		.clk(clk),
		.r(clear_ram_pulse),
		.en(~address_mux_control),
		.d(curr_reset_addr + 8'd1),
		.q(curr_reset_addr)
	 );
	 
	 always @(*) begin
		case(address_mux_control)
			1'b1: begin
				addr_to_write = write_address;
				payload_to_write = write_payload;
			end
			
			1'b0: begin
				addr_to_write = curr_reset_addr[6:0];
				payload_to_write = 16'b1000000000111100;
			end
			
			default: begin
				addr_to_write = 7'd0;
				payload_to_write = 16'b1000000000111100;
			end
		endcase
	 end
	 
endmodule
