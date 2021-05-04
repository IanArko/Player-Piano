/* -----------------------------------------------------------------------------
	MODULE display
----------------------------------------------------------------------------- */

module display (
    input clk,
    input reset,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]
    input valid,
    input [7:0] read_value,
    input read_index,
	 input [55:0] to_display,
	 
    output wire [9:0] read_address,
    output wire valid_pixel,
    output reg [7:0] r,
    output reg [7:0] g,
    output reg [7:0] b
);

	/* -----------------------------------------------------------------------------
			Waveform Display Control
	----------------------------------------------------------------------------- */

	wire display_wave;
	wave_display wave_display (
		.clk(clk),
		.reset(reset),
		.read_value(read_value),
		.read_index(read_index),
		.x(x),
		.y(y),
		
		.read_address(read_address),
		.display_wave(display_wave)
	);
	
	/* -----------------------------------------------------------------------------
			Piano Display Control
	----------------------------------------------------------------------------- */
	
	wire play;
	wire white_key;
	wire black_key;
	piano_display piano_display (
		.x(x),
		.y(y),
		.to_display(to_display),
		
		.white_key(white_key),
		.black_key(black_key),
		.play(play)
	);
	
	/* -----------------------------------------------------------------------------
		Master Display and Color Control
	----------------------------------------------------------------------------- */
		
	assign valid_pixel = valid; // ????? 
	always @(*) begin
		if (play) begin
			r = 8'h76;
			g = 8'h97;
			b = 8'hC7;
		end else if (white_key) begin
			r = 8'hFF;
			g = 8'hFF;
			b = 8'hFF;
		end else if (black_key) begin
			r = 8'h00;
			g = 8'h00;
			b = 8'h00;
		end else if (display_wave) begin
			r = 8'h76;
			g = 8'h97;
			b = 8'hC7;
		end else begin
			r = 8'h20;
			g = 8'h20;
			b = 8'h20;
		end
	end
	
endmodule
