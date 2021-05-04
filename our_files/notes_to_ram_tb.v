`timescale 1ns / 1ps
module notes_to_ram_tb();
	
	reg beat;
	reg clk;
	reg reset;
	
	reg [47:0] notes;
	reg [7:0] switches;
	reg [1:0] master_state;

	wire [15:0] write_payload;
	wire [6:0] write_address;
	wire write_enable, finished_recording, start_recording;


	notes_to_ram DUT (
		.clk(clk),
		.reset(reset),
		.beat(beat),
		
		.notes(notes),
		.switches(switches),
		.master_state(master_state),
		
		//outputs
		.write_payload(write_payload),
		.write_address(write_address),
		.write_enable(write_enable),
		
		.finished_recording(finished_recording),
		.start_recording(start_recording)
	);	
		
	initial begin
		reset = 1'b1;
		#10 reset = 1'b0;
	end

	initial begin
		clk = 1'b1;
		forever begin
			#5 clk = 1'b0;
			#5 clk = 1'b1;
		end
	end

	initial begin
		beat = 1'b1;
		forever begin
			#10 beat = 1'b0;
			#40 beat = 1'b1;
		end
	end

	/* TESTS */
	initial begin
		// reset and initialize values
		notes = 48'hF0F0F0F0F0F0F0F0F0F0F0F0;
	   switches = 8'd0;
		master_state = 2'd0;
		#10
		
		//should see nothing change
		#150
		
		
		//should see addr start counting when we increase switches
		master_state = 2'b01;
		#30
		#2
		switches = 8'b10000000;
		#8
		
		#20
		switches = 8'b00000000;
		
		
		
		/* test hold switch */
		switches = 8'b10000000;
		#100
		switches = 8'b11000000;
		#100
		switches = 8'b10000000;
		#100
		switches = 8'b10100000;
		#100
		switches = 8'b10000000;
		#100
		switches = 8'b00000000;
		#100
		$stop;
	end
			
endmodule
