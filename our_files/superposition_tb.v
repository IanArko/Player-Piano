`timescale 1ns / 1ps

module superposition_tb();

	 reg clk;
	 reg [127:0] samples; 
	 wire [15:0] out_sample;
	 wire generate_new_sample;
	 reg new_sample_ready;
	 
	 superposition DUT (
			.clk(clk),
			.samples(samples),
			.out_sample(out_sample),
			.generate_new_sample(generate_new_sample),
			.new_sample_ready(new_sample_ready)
			);
			
	// Clock
    initial begin
        clk = 1'b1;
        forever #5 clk = ~clk;
    end
	 
	//Test
	initial begin
		samples = 128'd128;
		#10
		samples = 128'd100;
		#10
		samples = 128'b11110111000000011010011101001101110011011010100011111101000011011000110001000101010010110011101011100101111101101001001011001111;
		#10
		//should output 8 0's followed 8 1's
		samples = 128'b 00000000000010000000000000010000000000000010000000000000010000000000000010000000000000010000000000000010000000000000010000000000 ;
	   #10
		//should output 0000000111111110 7 0(s) 8 1(s) 1 0(s)
		samples = 128'h 00100020004000800100020004000800;
	end
endmodule
