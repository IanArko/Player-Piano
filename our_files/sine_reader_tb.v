module sine_reader_tb();

    reg clk, reset, generate_next;
    reg [19:0] step_size;
    wire sample_ready;
    wire [15:0] sample;
    sine_reader reader(
        .clk(clk),
        .reset(reset),
        .step_size(step_size),
        .generate_next(generate_next),
        .sample_ready(sample_ready),
        .sample(sample)
    );

    // Clock and reset
	initial begin
		clk = 1'b1;
		reset = 1'b1;
		repeat (4) #5 clk = ~clk;
		reset = 1'b0;
		forever #5 clk = ~clk;
   end

	// Testing
	initial begin
		generate_next = 0;
		forever begin
			#100 
			generate_next = 1;
			#10 
			generate_next = 0;
			#100
			generate_next = 1;
			#10
			generate_next = 0;
		end
	end
	
	// Note Switching
	initial begin
		step_size = {10'd011, 10'd182};
		#100000
		step_size = {10'd089, 10'd439};
		#100000
		step_size = {10'd011, 10'd182};
		#100000
		step_size = {10'd089, 10'd439};
		#100000
		step_size = {10'd050, 10'd180};
	end

endmodule
