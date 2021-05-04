/* -----------------------------------------------------------------------------
	MODULE: song_writer.v
	
	Song Writer takes switches and state and turns them into notes to play. When
	in the Composer state, we will write to ram from our ram buffer.
----------------------------------------------------------------------------- */
module song_writer(
	input clk,
	input reset,
   input [5:0] root,            
	input [7:0] switches,
	input beat,
	input [1:0] state,
	input scale_button,
	
	output [47:0] notes,
	output finished_recording,
	output start_recording,
	output write_enable,
	output [6:0] write_address,
   output [15:0] write_payload
);
	
	/* -----------------------------------------------------------------------------
			MODULE INSTANTIATIONS
	----------------------------------------------------------------------------- */
	
	switch_to_note SWITCH_TO_NOTE(
		// input
		.root(root),
		.clk(clk),
		.reset(reset),
		.scale_button(scale_button),
		
		// output
		.switches(switches),
		.notes(notes)
	);
	
   notes_to_ram NOTES_TO_RAM(
		// inputs
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.notes(notes),
		.switches(switches),
		.master_state(state),
		
		//outputs
		.write_payload(write_payload),
		.write_address(write_address),
		.finished_recording(finished_recording),
		.start_recording(start_recording),
		.write_enable(write_enable)
	);
	

endmodule
