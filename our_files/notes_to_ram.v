/* -----------------------------------------------------------------------------
	MODULE: notes_to_ram.v
	
	When recording, this module will take in notes and switches and will determine
	the correct timing, then output the correct notes to ram as needed.
	
	NOTES:
		-	This module assumes that switches will be 0 when recording stops.
----------------------------------------------------------------------------- */
module notes_to_ram(
	input beat,
	input clk,
	input reset,
   input [47:0] notes,
	input [7:0] switches,
	input [1:0] master_state,
	
	// output to lip_synth_master
	output finished_recording,
	output start_recording,
	
	// output to ram
	output wire [15:0] write_payload,
	output wire [6:0] write_address,
	output write_enable
);
	
	/* -----------------------------------------------------------------------------
		LOGIC
	----------------------------------------------------------------------------- */

	wire [8:0] high_pulses;                 	// One hot signal saying which switch had a rising edge
	wire [8:0] low_pulses;                    // One hot signal saying which payload to write (controls payload mux)
	assign write_enable = (master_state == 2'b01);
	wire hold_switch = ~(|high_pulses[7:0]);  // 1 ==> no switch[7:0] change. 0 ==> switch[7:0] changes.
	assign finished_recording = (cur_ram_addr == 8'd128);
	
	one_pulse start_recording_pulse(
		.clk(clk),
		.reset(reset),
		.in(master_state == 2'b01),
		.out(start_recording)
	);
	
	wire [7:0] cur_ram_addr;
	dffre #(.WIDTH(8)) ram_addr_counter (
		.clk(clk),
		.r(reset || start_recording),
		.en((|high_pulses) & (master_state == 2'b01)),
		.d(cur_ram_addr + 7'd1),
		.q(cur_ram_addr)
	);
	
	/* -----------------------------------------------------------------------------
		INSTANTIATE NOTE WRITERS
	----------------------------------------------------------------------------- */
	wire [22:0] payload_0, payload_1, payload_2, payload_3, payload_4, payload_5, payload_6, payload_7, payload_8;
	
	// todo: write_hold parameter
	note_writer note_writer_0(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(switches[0]),
		.note(notes[5:0]),
		.is_hold_writer(1'b0),
		
		.switch_high_pulse(high_pulses[0]),
		.switch_low_pulse(low_pulses[0]),
		.payload(payload_0)
	);
	
	note_writer note_writer_1(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(switches[1]),
		.note(notes[11:6]),
		.is_hold_writer(1'b0),
		
		.switch_high_pulse(high_pulses[1]),
		.switch_low_pulse(low_pulses[1]),
		.payload(payload_1)
	);
	
	note_writer note_writer_2(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(switches[2]),
		.note(notes[17:12]),
		.is_hold_writer(1'b0),
		
		.switch_high_pulse(high_pulses[2]),
		.switch_low_pulse(low_pulses[2]),
		.payload(payload_2)
	);
	
	note_writer note_writer_3(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(switches[3]),
		.note(notes[23:18]),
		.is_hold_writer(1'b0),
		
		.switch_high_pulse(high_pulses[3]),
		.switch_low_pulse(low_pulses[3]),
		.payload(payload_3)
	);
	
	note_writer note_writer_4(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(switches[4]),
		.note(notes[29:24]),
		.is_hold_writer(1'b0),
		
		.switch_high_pulse(high_pulses[4]),
		.switch_low_pulse(low_pulses[4]),
		.payload(payload_4)
	);
	
	note_writer note_writer_5(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(switches[5]),
		.note(notes[35:30]),
		.is_hold_writer(1'b0),
		
		.switch_high_pulse(high_pulses[5]),
		.switch_low_pulse(low_pulses[5]),
		.payload(payload_5)
	);
	
	note_writer note_writer_6(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(switches[6]),
		.note(notes[41:36]),
		.is_hold_writer(1'b0),
		
		.switch_high_pulse(high_pulses[6]),
		.switch_low_pulse(low_pulses[6]),
		.payload(payload_6)
	);
	
	note_writer note_writer_7(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(switches[7]),
		.note(notes[47:42]),
		.is_hold_writer(1'b0),
		
		.switch_high_pulse(high_pulses[7]),
		.switch_low_pulse(low_pulses[7]),
		.payload(payload_7)
	);
	
	// THIS NOTE PLAYER TAKES IN OUR "HOLD SWITCH"
	note_writer hold_writer(
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.cur_ram(cur_ram_addr[6:0]),
		.switch(hold_switch),
		.note(6'd0),
		.is_hold_writer(1'b1),
		
		.switch_high_pulse(high_pulses[8]),
		.switch_low_pulse(low_pulses[8]),
		.payload(payload_8)
	);
	
	
	/* -----------------------------------------------------------------------------
		OUTPUT PAYLOAD MUX & FF
	----------------------------------------------------------------------------- */
	reg [22:0] inter_payload;
	wire [22:0] out_payload;
	always @(*) begin
		case(low_pulses)
			9'b000000001: inter_payload = payload_0;
			9'b000000010: inter_payload = payload_1;
			9'b000000100: inter_payload = payload_2;
			9'b000001000: inter_payload = payload_3;
			9'b000010000: inter_payload = payload_4;
			9'b000100000: inter_payload = payload_5;
			9'b001000000: inter_payload = payload_6;
			9'b010000000: inter_payload = payload_7;
			9'b100000000: inter_payload = payload_8;
			default: inter_payload = 23'd0;
		endcase
	end
	
	dffre #(.WIDTH(23)) output_hold(
		.clk(clk),
		.r(reset),
		.en(|low_pulses),
		.d(inter_payload),
		.q(out_payload)
	);
	
	assign write_address = out_payload[22:16];
	assign write_payload = out_payload[15:0];

endmodule
