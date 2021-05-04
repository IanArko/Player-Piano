/* -----------------------------------------------------------------------------
	MODULE: note_to_sample.v
	
	Takes in switches and the root of the scale and outputs notes. This module assumes
	that the lowest note is the LSB.
----------------------------------------------------------------------------- */
module switch_to_note(
	input clk,
	input reset,
	input scale_button,
	
	input [5:0] root,
	input [7:0] switches,
	
	output reg [47:0] notes
);

	wire [1:0] scale_counter;
	dffre #(.WIDTH(2)) scale_controller(
		.clk(clk),
		.r(reset),
		.en(scale_button || (scale_counter == 2'd3)),
		.d(scale_counter + 2'd1),
		.q(scale_counter)
	);
	 
	//NOTE: THE MAPAPING OF SWITCHES MAY NEED TO CHANGE BASED ON THE INPUT ORIENTATION.
	always @(*) begin
		
		if (scale_counter == 2'd0) begin
			notes[5:0] = switches[0] ? root + 6'd12 : 6'b0;
			notes[11:6] = switches[1] ? root + 6'd11 : 6'b0;
			notes[17:12] = switches[2] ? root + 6'd9 : 6'b0;
			notes[23:18] = switches[3] ? root + 6'd7 : 6'b0;
			notes[29:24] = switches[4] ? root + 6'd5 : 6'b0;
			notes[35:30] = switches[5] ? root + 6'd4 : 6'b0;
			notes[41:36]  = switches[6] ? root + 6'd2 : 6'b0;
			notes[47:42]   = switches[7] ? root + 6'd0 : 6'b0;
		end else if (scale_counter == 2'd1) begin
			notes[5:0] = switches[0] ? root + 6'd12 : 6'b0;
			notes[11:6] = switches[1] ? root + 6'd10 : 6'b0;
			notes[17:12] = switches[2] ? root + 6'd8 : 6'b0;
			notes[23:18] = switches[3] ? root + 6'd7 : 6'b0;
			notes[29:24] = switches[4] ? root + 6'd5 : 6'b0;
			notes[35:30] = switches[5] ? root + 6'd3 : 6'b0;
			notes[41:36]  = switches[6] ? root + 6'd2 : 6'b0;
			notes[47:42]   = switches[7] ? root + 6'd0 : 6'b0;
		end else begin
			notes[5:0] = switches[0] ? 6'd0 : 6'b0;
			notes[11:6] = switches[1] ? root + 6'd12 : 6'b0;
			notes[17:12] = switches[2] ? root + 6'd10 : 6'b0;
			notes[23:18] = switches[3] ? root + 6'd7 : 6'b0;
			notes[29:24] = switches[4] ? root + 6'd6 : 6'b0;
			notes[35:30] = switches[5] ? root + 6'd5 : 6'b0;
			notes[41:36]  = switches[6] ? root + 6'd3 : 6'b0;
			notes[47:42]   = switches[7] ? root + 6'd0 : 6'b0;
		end
		
	end
	
endmodule
