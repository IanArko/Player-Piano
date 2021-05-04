`timescale 1ns / 1ps
//Testing the arbiter module used in note_to_sample
module arbiter_tb();
	reg [7:0] request;
	wire [7:0] grant;

	arbiter #(.n(8)) DUT(
		.r(request),
		.g(grant)
	);

	initial begin
		request = 8'b00000001;
		#5 // Grant = 8'b00000001
		request = 8'b10001001;
		#5 // Grant = 8'b00000001
		request = 8'b00101101;
		#5 // Grant = 8'b00000001
		request = 8'b01001000;
		#5 // Grant = 8'b00001000
		request = 8'b00100001;
		#5 // Grant = 8'b00000001
		request = 8'b01110001;
		#5 // Grant = 8'b00000001
		request = 8'b10000000;
		#5 // Grant = 8'b10000000;
	   request = 8'b10000000;	
	end
endmodule
