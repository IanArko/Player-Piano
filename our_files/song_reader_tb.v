module song_reader_tb();

    reg clk, reset, play, beat;
    reg [1:0] song;
	 
	 reg [6:0] write_address;
    reg [15:0] write_payload;
	 reg done_recording, write_enable;
	 
	 // outputs
    wire [5:0] note;
    wire [5:0] duration;
    wire song_done, new_note;

    song_reader DUT(
        .clk(clk),
        .reset(reset),
		  .beat(beat),
        .play(play),
        .song(song),
		  
		  // ram inputs
		  .write_enable(write_enable),
        .write_address(write_address),
		  .write_payload(write_payload),
		  
        .song_done(song_done),
        .note_out(note),
        .duration_out(duration),
        .load_new_note(new_note)
    );

    // Clock
    initial begin
        clk = 1'b1;
        forever #5 clk = ~clk;
    end
	 
	 // Beat
    initial begin
		  beat = 1'b1; 
        forever begin 
			  #5
			  beat = 1'b0; 
			  #15
			  beat = 1'b1; 
		  end
    end

    // Tests
   initial begin
		/***************************************************************
			Test 1: Reset and initialize regs
		***************************************************************/
		reset = 1'b1;
		play = 1'b0;
      song = 2'd3;
	   write_address = 7'd0;
      write_payload = 16'd0;
	   done_recording = 1'b0;
		write_enable = 1'd0;
		#10
		reset = 1'b0;
		#10
				

		
		/***************************************************************
			Test 2: Write to Ram
			
			Expectation: 
				- we should the values of RAM change
				- when done_recording goes high, max_ram_address should gain 
				  value of write_address
		***************************************************************/
	   write_enable = 1'd1;
		
		write_address = 7'd0;
      write_payload = {1'b1, 6'd0, 6'd0, 3'd0};
		#10
		
		write_address = 7'd1;
      write_payload = {1'b0, 6'd23, 6'd5, 3'd0};
		#10
		
		write_address = 7'd2;
      write_payload = {1'b0, 6'd24, 6'd5, 3'd0};
		#10
		
		write_address = 7'd3;
      write_payload = {1'b1, 6'd0, 6'd10, 3'd0};
		#10

		write_address = 7'd4;
      write_payload = {1'b0, 6'd22, 6'd5, 3'd0};
		#10
		
		write_enable = 1'd0;
		
		done_recording = 1'b1;
		#10
		done_recording = 1'b0;
		#20
		
		/***************************************************************
			Test 3: Play from Ram
			
			Expectation: 
				- we should the values of RAM change
				- when done_recording goes high, max_ram_address should gain 
				  value of write_address
		***************************************************************/
		play = 1'b1;
		#400		
		play = 1'b0;
		
		/***************************************************************
			Test 3: Play from ROM
			
			Expectation: 
				- Just play from rom
		***************************************************************/
		reset = 1'b1;
		#20
		reset = 1'b0;
		
		song = 2'd1;
		play = 1'b1;
		#1000
		
		$stop;
   end

endmodule


