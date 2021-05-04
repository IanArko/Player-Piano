`timescale 1ns / 1ps

module wave_display_tb();

	/* -----------------------------------------------------------------------------
			Declarations
		----------------------------------------------------------------------------- */
		
	// inputs
	reg clk = 0;
   reg reset = 1;
   reg[10:0] x;  // [0..1279]
   reg[9:0]  y;  // [0..1023]
   reg read_index = 0;
	
	// inputs we don't control
	wire [7:0] read_value;
	wire valid = ((x <= 1279) && (0 <= x)) && ((y <= 1023) && (0 <= y));
	
	// outputs
   wire [8:0] read_address;
   wire valid_pixel;
   wire [7:0] r;
   wire [7:0] g;
   wire [7:0] b;

	wave_display DUT(
		.clk(clk),
		.reset(reset),
		.x(x),
		.y(y),
		.valid(valid),
		.read_value(read_value),
		.read_index(read_index),
		.read_address(read_address),
		.valid_pixel(valid_pixel),
		.r(r),
		.g(g),
		.b(b)
	);
	
	fake_sample_ram RAM(
		.clk(clk),
		.addr(read_address),
		.dout(read_value)
	);
	
	// setup our fake clock.
	initial forever begin
		#1
		clk = 1;
		#1
		clk = 0;
	end
	
	/* -----------------------------------------------------------------------------
			Tests
		----------------------------------------------------------------------------- */
	initial begin 
		// TEST 1: MAKE SURE WE CAN RESET
		reset = 1;
		#2
		reset = 0;
		
		// TEST 2: MAKE SURE WE'RE ONLY OUTPUTING VALID FOR VALID PIXELS
		x = 11'd23;
		y = 10'd300;
		#2 // should see invalid
		
		x = 11'd490;
		y = 10'd200;
		#2 // should be valid
		
		// TEST 3: CHANGE READ INDEX AND ENSURE THAT THE READ_ADDRESS CHANGES AS NEEDED.
		read_index = 1;
		
		x = 11'd23;
		y = 10'd300;
		#2
		
		x = 11'd490;
		y = 10'd200;
		#2
		read_index = 0;
		
		// TEST 4: CHECK THAT READ VALUES ARE WHAT THEY NEED TO BE.
		// x = 256 ===> addr = 0
		x = 11'd256;
		y = 10'd300;
		#2
		
		// x = 511 ===> addr = 255
		x = 11'd511;
		y = 10'd300;
		#2
		
		// x = 600 ===> addr = 344
		x = 11'd600;
		y = 10'd300;
		#2
		
		// TEST 5: SEE IF WE'RE PROPERLY DOING Y-LOGIC
		read_index = 0;
		x = 11'd258;
		y = 10'd128;
		#12 // should see valid_pixel = 1;
		x = 11'd258;
		y = 10'd30;
		#12 // should see valid_pixel = 0;
		x = 11'd0;
		y = 10'd0;
		end
endmodule
