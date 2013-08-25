
module second_level (clk, three, four);
	input clk;
	input [2:0] three;
	output [2:0] four;
	
	wire [2:0] threePointFive;
	dffr_ns #(3) dffThree (.clk(clk),
		.rst(three[0]),
		.din(three),
		.q(threePointFive)
	);
	assign four = {threePointFive[0], threePointFive[1], threePointFive[2]};
endmodule

module first_level (clk, one, two);
	input clk;
	input [5:0] one;
	output [5:0] two;

	wire [5:0] onePointFive;
	dff_ns #(6) dffOne (.clk(clk),
		.din(one),
		.q(onePointFive)
	);

	wire [2:0] twoPartOne;
	dff_ns #(3) dffTwo (.clk(clk),
		.din(onePointFive[5:3]),
		.q(twoPartOne)
	);
	
	wire [2:0] twoPartTwo;
	second_level moduleTwo (.clk(clk),
		.three(onePointFive[2:0]),
		.four(twoPartTwo)
	);

	assign two = {twoPartOne, twoPartTwo};

endmodule
