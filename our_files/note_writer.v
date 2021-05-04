/* -----------------------------------------------------------------------------
	MODULE: note_writer.v
	
	This module stores the information needed to write a note to ram when the switch
   goes from high to low. Namely, this module latches in the note and the ram location
	that will be written to when the switch goes low.
----------------------------------------------------------------------------- */
module note_writer (
	input clk,
	input reset,
	input beat, 
	
	input [6:0] cur_ram,          // Ram address to write to. Latch in on rising edge of switch
	input switch,                 // User input.
	input [5:0] note,      		   // Note from a major scale corresponding to the switch
	input is_hold_writer,             // Parameter --> 0 = this is note_writer, 1 = this is hold writer
	
	output [22:0] payload,        // payload ==> {addr, {write_hold, note, duration}}
	output switch_high_pulse, // 1 Cycle pulse on rising edge of switch
	output switch_low_pulse   // 1 Cycle pulse on falling edge of switch
);

	assign payload[15] = is_hold_writer;
	assign switch_low_pulse = ~switch_delay & switch_super_delay;
	assign switch_high_pulse = switch_delay & ~switch_super_delay;
	
	wire switch_delay;
	wire switch_super_delay;
	dff #(.WIDTH(1)) delayer(
		.clk(clk),
		.d(switch),
		.q(switch_delay)
	);
	
	dff #(.WIDTH(1)) super_delayer(
		.clk(clk),
		.d(switch_delay),
		.q(switch_super_delay)
	);
	
	dffre #(.WIDTH(6)) note_ff (
		.clk(clk),
		.r(reset),
		.en(switch_high_pulse),
		.d(note),
		.q(payload[14:9])
	);
	
	dffre #(.WIDTH(7)) ram_addr_ff (
		.clk(clk),
		.r(reset),
		.en(switch_high_pulse),
		.d(cur_ram),
		.q(payload[22:16])
	);
	
	dffre #(.WIDTH(9)) duration_counter (
		.clk(clk),
		.r(reset | switch_high_pulse),
		.en(beat & switch),
		.d(payload[8:0] + 9'd1),
		.q(payload[8:0])
	);
	
endmodule
