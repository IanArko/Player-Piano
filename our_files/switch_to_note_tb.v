`timescale 1ns / 1ps

module switch_to_note_tb();
	reg [5:0] root = 6'b0;
	reg [7:0] switches = 8'b00000000;
	wire [47:0] notes;
	
	switch_to_note SWITCH_TO_NOTE(
		.root(root),
		.switches(switches),
		.notes(notes)
	);
	
	//TODO: Just print parsed versions of the notes output to make the tests more legible.
	initial begin
		#5
		switches = 8'b10100010;
		#5
		switches = 8'b10000000;
		#5
		switches = 8'b00000001;
		#5
		switches = 8'b00110000;
		#5
		switches = 8'b11111111;
		#40
		root = 6'd23;
		switches = 8'b10100010;
		#5
		switches = 8'b10000000;
		#5
		switches = 8'b00000001;
		#5
		switches = 8'b00110000;
		#5
		switches = 8'b11111111;
	end
	
endmodule
