
module second_level (clk, three, four
,
//*****[ERROR CAPTURE MODULE INOUTS]*****
	err_en, // Error injection enable
	err_ctrl // Error injection control
);

	//*****[ERROR CAPTURE MODULE INOUTS INSTANTIATIONS]*****
	input	err_en; // Error injection enable
	input	[0:0] err_ctrl; // Error injection control


	//*****[ERROR WIRE INSTANTIATIONS]******
	wire [0:0] lcl_err;
	input clk;
	input [2:0] three;
	output [2:0] four;
	
	wire [2:0] threePointFive;
	dffr_ns #(3) dffThree (     .err_en(lcl_err[0]),
.clk(clk),
		.rst(three[0]),
		.din(three),
		.q(threePointFive)
	);
	assign four = {threePointFive[0], threePointFive[1], threePointFive[2]};

	//[Local Error Control Splitter Instantiation here]
	lclErrCtrlSplitter #(.INW(1), .LCL(1)) local_err_router_second_level(
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.lcl_err(lcl_err)
	);


endmodule

module first_level (clk, one, two
,
//*****[ERROR CAPTURE MODULE INOUTS]*****
	err_en, // Error injection enable
	err_ctrl // Error injection control
);

	//*****[ERROR CAPTURE MODULE INOUTS INSTANTIATIONS]*****
	input	err_en; // Error injection enable
	input	[1:0] err_ctrl; // Error injection control


	//*****[ERROR WIRE INSTANTIATIONS]******
	wire [1:0] lcl_err;
	wire moduleTwo_err_en;
	wire [0:0] moduleTwo_err_ctrl;
	input clk;
	input [5:0] one;
	output [5:0] two;

	wire [5:0] onePointFive;
	dff_ns #(6) dffOne (     .err_en(lcl_err[0]),
.clk(clk),
		.din(one),
		.q(onePointFive)
	);

	wire [2:0] twoPartOne;
	dff_ns #(3) dffTwo (     .err_en(lcl_err[1]),
.clk(clk),
		.din(onePointFive[5:3]),
		.q(twoPartOne)
	);
	
	wire [2:0] twoPartTwo;
	second_level moduleTwo (.clk(clk),
		.three(onePointFive[2:0]),
		.four(twoPartTwo)
,
		.err_en(moduleTwo_err_en), // [ERROR]
		.err_ctrl(moduleTwo_err_ctrl) // [ERROR]
	);

	assign two = {twoPartOne, twoPartTwo};


	//[Local Error Control Splitter Instantiation here]
	lclErrCtrlSplitter #(.INW(2), .LCL(2)) local_err_router_first_level(
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.lcl_err(lcl_err)
	);



	//[Sub Error Control Splitter Instantiations here]
	subErrCtrlSplitter #(.INW(2), .OUTW(1), .LOW(2), .HIGH(2)) sub_err_splitter_moduleTwo(
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.sub_err_en(moduleTwo_err_en),
		.sub_err_ctrl(moduleTwo_err_ctrl)
	);


endmodule
