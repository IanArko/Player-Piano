
module superposition(
    input wire clk,
	 input wire [127:0] samples, 
	 output wire [15:0] out_sample,
	 input wire generate_new_sample,
	 output wire new_sample_ready
);

	wire signed [15:0] sample_1 = samples[15:0];
	wire signed [15:0] sample_2 = samples[31:16];
	wire signed [15:0] sample_3 = samples[47:32];
	wire signed [15:0] sample_4 = samples[63:48];
	wire signed [15:0] sample_5 = samples[79:64];
	wire signed [15:0] sample_6 = samples[95:80];
	wire signed [15:0] sample_7 = samples[111:96];
	wire signed [15:0] sample_8 = samples[127:112];
	
	wire signed [15:0] sample_1_shifted = sample_1 >>> 3;
	wire signed [15:0] sample_2_shifted = sample_2 >>> 3;
	wire signed [15:0] sample_3_shifted = sample_3 >>> 3;
	wire signed [15:0] sample_4_shifted = sample_4 >>> 3;
	wire signed [15:0] sample_5_shifted = sample_5 >>> 3;
	wire signed [15:0] sample_6_shifted = sample_6 >>> 3;
	wire signed [15:0] sample_7_shifted = sample_7 >>> 3;
	wire signed [15:0] sample_8_shifted = sample_8 >>> 3;

	
	// Sum samples
	assign out_sample = sample_1_shifted + sample_2_shifted + 
	                    sample_3_shifted + sample_4_shifted + 
							  sample_5_shifted + sample_6_shifted + 
							  sample_7_shifted + sample_8_shifted;

	// Timing Flip-Flops	
	wire almost_ready;
   	dff #(.WIDTH(1)) ready_1 (
		.clk(clk),
      		.d(generate_new_sample),
      		.q(almost_ready)
   	);
	
   	dff #(.WIDTH(1)) ready_2 (
		.clk(clk),
      		.d(almost_ready),
      		.q(new_sample_ready)
	);
	
endmodule
