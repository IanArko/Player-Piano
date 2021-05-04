// arbiter which gives the LSB the highest priority. 
module arbiter #(parameter n=8) (
	input wire [n-1:0] r,
	output wire [n-1:0] g
);

	wire [n-1:0] c = {(~r[n-2:0] & c[n-2:0]), 1'b1};
	assign g = r & c;
endmodule
