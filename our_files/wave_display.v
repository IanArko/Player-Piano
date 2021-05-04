module wave_display(
   input clk,
	input reset,
	input [7:0] read_value,
	input read_index,
	input [10:0] x,
	input [9:0] y,
		
	output [9:0] read_address,
	output display_wave
);

	wire display_wave_x = x > 30 & x < 1239; // block a little extra to hide mess 
	reg display_wave_y;
	assign display_wave = display_wave_x & display_wave_y;
	
	assign read_address = {read_index, x[10:1]};
	wire [9:0] previous_read_address;
	dffr #(.WIDTH(10)) READ_ADDRESS_CHANGE (
		.clk(clk),
		.r(reset),
		.d(read_address),
		.q(previous_read_address)
	);
	
	wire [7:0] prev_read_value;
	dffre #(.WIDTH(8)) READ_VALUE (
		.r(reset),
		.clk(clk),
		.en(~(previous_read_address == read_address)),
		.d(read_value),
		.q(prev_read_value)
	);
	
	always @(*) begin
		if(read_value < prev_read_value) begin
			display_wave_y = ((read_value <= y[8:1] && y[8:1] <= prev_read_value)) & ~y[9];
		end else if (read_value > prev_read_value) begin
			display_wave_y = ((prev_read_value <= y[8:1] && y[8:1] <= read_value)) & ~y[9];
		end else begin 
			display_wave_y = (read_value == y[8:1]) & ~y[9];
		end
	end
endmodule
