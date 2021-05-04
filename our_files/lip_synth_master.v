/* -----------------------------------------------------------------------------
	MODULE: lip_synth_master.v
	
	Takes in button inputs and determines which overarching state magnus_opus should be in.
	
	Note: Root can only change in the Jam_sesh state to avoid recording complications.
----------------------------------------------------------------------------- */

module lip_synth_master(
	 input wire clk,
    input wire reset,
	 
    input wire center_but,		    	   // A one-cycle pulse indicating the center button has been pressed
    input wire left_but,
	 input wire right_but,
	 input wire down_but,		      	// A one-cycle pulse indicating the down button has been pressed
	 input wire finished_recording,		// we hit max ram size			
    
	 output wire done_recording, 			// says we hit max ram or hit center or down
	 output wire [1:0] state,
	 output [5:0] root
);

	//state declarations
	`define JAM_SESH 		2'b00
	`define COMPOSER 		2'b01
	`define SONG_PLAYER 	2'b10

	//wire assignments
	reg [1:0] next_state;
	dffr #(.WIDTH(2)) STATE_FF(
		.clk(clk),
		.r(reset),
		.d(next_state),
		.q(state)
	);
	
	reg [5:0] next_root;
	dffr #(.WIDTH(6)) ROOT_FF(
		.clk(clk),
		.r(reset),
		.d(next_root),
		.q(root)
	);
	
	assign done_recording = center_but || down_but || finished_recording;
	always @(*) begin
		case(state)
		//Resets on middle C
			`JAM_SESH: begin
				next_state = down_but ? `SONG_PLAYER : (center_but ? `COMPOSER : `JAM_SESH);
				next_root = (left_but && root > 6'd1) ? (root - 6'd1) : (right_but && root < 6'd51) ? (root + 6'd1) : (root == 6'd0) ? 6'd28 : root;
			end
			
			`COMPOSER: begin
					next_state = (center_but || finished_recording) ? `JAM_SESH : 
										(down_but ? `SONG_PLAYER : `COMPOSER);
					next_root = root;
			end
			
			`SONG_PLAYER: begin
				next_state = down_but ? `JAM_SESH : `SONG_PLAYER;
				next_root = root;
			end
			
			default: begin
				next_state = `JAM_SESH;    // Where we can just play.
				next_root =  6'd28;             // Middle C aka 
			end
		endcase
	end
endmodule
