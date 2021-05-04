/* -----------------------------------------------------------------------------
	MODULE wave_capture
	
	Collects the individual samples being outputted by synthesizer, processes 
	them, and reassembles them in a dual-port RAM.
----------------------------------------------------------------------------- */

/* State Enumeration */
`define ARMED		2'b00
`define ACTIVE		2'b01
`define WAIT		2'b10

/* Constants */
`define BIN_WIDTH			1'd1
`define STATE_WIDTH		2'd2
`define SAMPLE_WIDTH		5'd16
`define WRITE_WIDTH		4'd8
`define ADDR_WIDTH		5'd12

module wave_capture (
    input clk,
    input reset,
    input new_sample_ready,
    input [`SAMPLE_WIDTH-1:0] new_sample_in,
    input wave_display_idle,
	 input [55:0] to_display,

    output reg [`ADDR_WIDTH-1:0] write_address,
    output reg write_enable,
    output reg [`WRITE_WIDTH-1:0] write_sample,
    output wire read_index
);

	/* -----------------------------------------------------------------------------
		Input-FSM Interface
	----------------------------------------------------------------------------- */
	
	// hey! we have a positive zero crossing
	wire any_positive_zero_crossing = (new_sample_in[15] < prev_sample[15]);
	
	wire [`SAMPLE_WIDTH-1:0] delayed_new_sample_in;
	dff #(.WIDTH(`SAMPLE_WIDTH)) CUF_FLIPFLOP1 (
		.clk(clk),
		.d(new_sample_in),
		.q(delayed_new_sample_in)
	);
	
	wire [`SAMPLE_WIDTH-1:0] prev_sample;
	dffre #(.WIDTH(`SAMPLE_WIDTH)) SAMPLE_SEQUENCE (
		.clk(clk),
		.r(reset),
		.en(new_sample_ready),
		.d(delayed_new_sample_in),
		.q(prev_sample)
	);
		
	// hey! the notes changed, we should reset the positive zero crossing mechanisms
	wire notes_changed = (to_display != prev_to_display);
	wire [55:0] prev_to_display;
	
	dff #(.WIDTH(56)) PREV_NOTES (
		.clk(clk),
		.d(to_display),
		.q(prev_to_display)
	);

	// logic to hold a pzc different target
	wire [15:0] curr_pzc_count;
	dffre #(.WIDTH(16)) PZC_COUNTER (
		.clk(clk),
		.r(reset | notes_changed),
		.en(any_positive_zero_crossing),
		.d(curr_pzc_count + 16'b1),
		.q(curr_pzc_count)
	);
	
	wire [`SAMPLE_WIDTH-1:0] pzc_diff = new_sample_in - prev_sample;
	wire [`SAMPLE_WIDTH-1:0] pzc_diff_target;
	dffre #(.WIDTH(`SAMPLE_WIDTH)) DIFF_HOLD (
		.clk(clk),
		.r(reset | notes_changed),
		.en(any_positive_zero_crossing & (curr_pzc_count == 16'd0)), 
		.d(pzc_diff),
		.q(pzc_diff_target)
	);
	
	// hey! this is THE positive zero crossing
	wire THE_positive_zero_crossing = any_positive_zero_crossing &
													(pzc_diff_target + 20 > pzc_diff &
													 pzc_diff_target - 20 < pzc_diff);


	/* -----------------------------------------------------------------------------
		FSM
	----------------------------------------------------------------------------- */

	// FFs
	reg [`STATE_WIDTH-1:0] next_state;
	wire [`STATE_WIDTH-1:0] state;
	dffr #(.WIDTH(`STATE_WIDTH)) STATE (
		.clk(clk),
		.r(reset),
		.d(next_state),
		.q(state)
	);
	
	reg [`ADDR_WIDTH-2:0] next_count;
	wire [`ADDR_WIDTH-2:0] count;
	dffre #(.WIDTH(`ADDR_WIDTH-1)) COUNTER (
		.clk(clk),
		.r(reset),
		.en(new_sample_ready),
		.d(next_count),
		.q(count)
	);
	
	reg next_read_index;
	dffr #(.WIDTH(`BIN_WIDTH)) READ_INDEX (
		.clk(clk),
		.r(reset),
		.d(next_read_index),
		.q(read_index)
	);

	// Logic
	always @(*) begin
		write_address = {~read_index, count}; 
		write_sample = prev_sample[15:8] + 8'd128; 
		
		case (state)
			`ARMED: 
				begin
					next_state = (THE_positive_zero_crossing) ? `ACTIVE : `ARMED;
					next_count = 11'd0;
					next_read_index = read_index;
					write_enable = 1'b0;
				end
			
			`ACTIVE:
				begin
					next_state = (count == 11'd639) ? `WAIT : `ACTIVE;
					next_count = (count == 11'd639) ? 11'd0 : count + 11'd1;
					next_read_index = read_index;
					write_enable = 1'b1;
				end
				
			`WAIT:
				begin
					next_state = (wave_display_idle) ? `ARMED : `WAIT;
					next_count = 11'd0;
					next_read_index = (wave_display_idle) ? ~read_index : read_index;
					write_enable = 1'b0;
				end
				
			default:
				begin
					next_state = `ARMED;
					next_count = 11'd0;
					next_read_index = 1'b0;
					write_enable = 1'b0;
				end
		endcase
	end

endmodule
