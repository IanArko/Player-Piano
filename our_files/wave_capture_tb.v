module wave_capture_tb();

	/* Constants */
	`define BIN_WIDTH			1'd1
	`define STATE_WIDTH		2'd2
	`define WRITE_WIDTH		4'd8
	`define ADDR_WIDTH		5'd9
	`define SAMPLE_WIDTH		5'd16
	
	/* Values */
   reg clk;
   reg reset;
   reg new_sample_ready;
   reg[`SAMPLE_WIDTH-1:0] new_sample_in;
   reg wave_display_idle;

   wire [`ADDR_WIDTH-1:0] write_address;
   wire write_enable;
   wire [`WRITE_WIDTH-1:0] write_sample;
   wire read_index;
	
	reg [47:0] notes_to_display;
	
	wave_capture DUT (
		.clk(clk),
		.reset(reset),
		.new_sample_ready(new_sample_ready),
		.new_sample_in(new_sample_in),
		.wave_display_idle(wave_display_idle),
		.write_address(write_address),
		.write_enable(write_enable),
		.write_sample(write_sample),
		.read_index(read_index),
		.notes_to_display(notes_to_display)
	);
	
	/* Init, Clock, and Reset */
	initial begin
		clk = 1;
		new_sample_ready = 0;
		new_sample_in = 0;
		wave_display_idle = 0;
		notes_to_display = 48'd24;
		#1000
		notes_to_display = 48'd2467;
	end
	
	initial begin
		forever begin
			#5 clk = 0;
			#5 clk = 1;
		end
	end

	/* Tests */
	initial begin
	
		/* Test Input-FSM Interface */
		reset = 1;
		#30 reset = 0;
		
		new_sample_in = 16'b1111000011110000;
		new_sample_ready = 1;
		#10 new_sample_ready = 0;
		#40
		new_sample_in = 16'b0011000011110011;
		new_sample_ready = 1;
		#10 new_sample_ready = 0;
		#40
		new_sample_in = 16'b1111000011110000;
		new_sample_ready = 1;
		#10 new_sample_ready = 0;
		#40
		new_sample_in = 16'b1111111111111100;
		// Check: previous_sample reflects these new samples
		// Check: PZC goes high for a cycle after the second sample comes

		repeat (275) begin
			#40
			new_sample_in = new_sample_in + 1;
			new_sample_ready = 1;
			#10 new_sample_ready = 0;
		end
		
		wave_display_idle = 1;
		#10 wave_display_idle = 0;
		#1000
		
		
		
		
		
		$stop;
		
	
	end

endmodule