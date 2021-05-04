/* -----------------------------------------------------------------------------
	MODULE: song_reader.v
	
	Takes in a song and play from MCU, and reads from rom until a song is finished when
	play is high. When play is low, the module stops all behvavior until play goes high 
	again.
----------------------------------------------------------------------------- */
module song_reader(
   input clk,                           // Standard system clock and reset
   input reset,                  		 // Standard system clock and reset
   input wire play,					       // True if the song reader should be playing (persistent signal)
   input wire beat,                     // Takes in beat to allow us to wait a desired number of beats.
	input wire [1:0] song,			       // song to play ==> used in rom_addr
	 
	// inputs to write to ram
	input write_enable,
   input [6:0] write_address,
   input [15:0] write_payload,
    
	output reg song_done,			       // pulse: true if song has finished 
   output wire [5:0] note_out,          // the note to play
   output wire [8:0] duration_out,      // the duration of the note (in 48ths of second)
   output reg load_new_note			    // one cycle pulse that tells note_player to latch in the values on note and duration and start playing note
);

	// state declarations
	`define OFF 				3'b000 // waiting for play signal to go high
	`define READ         	3'b001 // going line by line through the rom
	`define PAUSE           3'b011 // holds system still until play: 0 --> 1
	`define WAIT_TO_READ    3'b010 // counts down to 0 from duration when we read a pause from rom
	`define WAIT_TO_FINISH  3'b111
   /* -----------------------------------------------------------------------------
		Instantiate wires/regs
	----------------------------------------------------------------------------- */
	
	wire [8:0] rom_addr = {song, cur_ctr[6:0]};	 // address to read from rom
	wire [15:0] rom_note; 						       // output of song_rom. (note value, duration value)
	wire [6:0] ram_addr = cur_ctr[6:0];
	wire [15:0] ram_note;
	
	
	wire [2:0] cur_state;
	reg [2:0] next_state;		
	
	wire [7:0] cur_ctr;							      // counts # of notes played ==> keeps track of address
   reg [7:0] next_ctr;
	
	wire [8:0] cur_rest;							      // counts rests remaining when
   reg [8:0] next_rest;
	
	// mux between ram and rom outputs
	wire top_bit = (song == 2'd3) ? ram_note[15] : rom_note[15];
	assign note_out = (song == 2'd3) ? ram_note[14:9] : rom_note[14:9];
	assign duration_out = (song == 2'd3) ? ram_note[8:0] : rom_note[8:0];
	
	/* -----------------------------------------------------------------------------
		Instantiate modules
	----------------------------------------------------------------------------- */
	song_rom ROM(
		.clk(clk),
		.addr(rom_addr),
		.dout(rom_note)
	);
	
	ram_1w2r #(.WIDTH(16), .DEPTH(7)) RAM(
		// PORT A IS WRITTEN TO BY SONG_WRITER.
		.clka(clk),
		.wea(write_enable),
      .addra(write_address),
      .dina(write_payload),
		.douta(),
      
		// PORT_B INTERFACES WITH OUR SONG_PLAYER
		.clkb(clk),
      .addrb(ram_addr),
      .doutb(ram_note)
   );
	
	dffr #(.WIDTH(3)) state_ff(
		.clk(clk),
		.r(reset),
		.d(next_state),
		.q(cur_state)
	);
	
	dffre #(.WIDTH(9)) wait_ff(
		.clk(clk),
		.r(reset),
		.d(next_rest),
		.q(cur_rest),
		.en(beat || top_bit)
	);
	
	// keeps track of which note we're accessing.
	dffre #(.WIDTH(8)) address_ff(
		.clk(clk),
		.r(reset),
		.en(play),
		.d(next_ctr),
		.q(cur_ctr)
	);
	
	/* -----------------------------------------------------------------------------
		FSM LOGIC
	----------------------------------------------------------------------------- */
	always @(*) begin
		case(cur_state)
			`OFF: 
				begin
					song_done  = 1'b0;
					load_new_note = 1'b0;
					next_ctr   = play ? 8'd1 : 8'd0;
					next_rest  = 9'd0;
					next_state = play ? `READ : `OFF;
				end
			`READ: 
				begin
					song_done  = 1'b0;
					load_new_note = top_bit ? 1'b0 : 1'b1;
					next_ctr   = play ? (top_bit ? cur_ctr : cur_ctr + 8'd1) : cur_ctr;
					next_rest  = duration_out;
					next_state = (cur_ctr == 8'd128) ? `WAIT_TO_FINISH: (top_bit) ? `WAIT_TO_READ : (play ? `READ : `PAUSE);
				end
			`PAUSE:
				begin
					song_done  = 1'b0;
					load_new_note = 1'b0;
					next_ctr   = (play ? cur_ctr + 8'd1 : cur_ctr);
					next_rest  = cur_rest;
					next_state = (play ? `READ : `PAUSE);
				end
			`WAIT_TO_READ:
				begin
					song_done  = 1'b0;
					load_new_note = 1'b0;
					next_ctr   = (play ? (cur_rest == 9'd0) ? cur_ctr + 8'd1: cur_ctr : cur_ctr);
					next_rest  = (cur_rest - 9'd1);
					next_state = (cur_rest == 9'd0) ? `READ : `WAIT_TO_READ;
				end
			`WAIT_TO_FINISH:
				begin
					song_done  = (cur_rest == 9'd0) ? 1'b1 : 1'b0;
					load_new_note = 1'b0;
					next_ctr   = cur_ctr;
					next_rest  = (cur_rest - 9'd1);
					next_state = `WAIT_TO_FINISH;
				end
	
			default: 
				begin
					song_done  = 1'b0;
					load_new_note = 1'b0;
					next_ctr   = 8'b0;
					next_rest  = 9'b0;
					next_state = `OFF;
				end
		endcase
   end
	
endmodule
