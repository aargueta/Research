`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:00:42 08/10/2013
// Design Name:   shadow_capture
// Module Name:   D:/Unrelated Junk/Stanford/Research/SPARCCore/shadowedSparc/sc_tb.v
// Project Name:  shadowedSPARC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: shadow_capture
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sc_tb;

	// Inputs
	reg clk;
	reg rst;
	reg capture_en;
	//reg [0:0] dclk;
	reg [95:0] din;
	reg [31:0] dump_en;
	//reg [0:0] chains_in;
	//reg [0:0] chains_in_vld;
	//reg [0:0] chains_in_done;

	// Outputs
	//wire [0:0] chain_dump_en;
	wire [31:0] chains_out;
	wire [31:0] chains_out_vld;
	wire [31:0] chains_out_done;

	// Instantiate the Unit Under Test (UUT)
	shadow_capture #(.DFF_BITS(96), .USE_DCLK(0), .CHAINS_IN(0), .CHAINS_OUT(32), .DISCRETE_DFFS(1), .DFF_WIDTHS(32'h96)) uut (
		.clk(clk), 
		.rst(rst), 
		.capture_en(capture_en), 
      	.dclk(), 
		.din(din),
		.dump_en(dump_en), 
		.chains_in_vld(),//chains_in_vld), 
		.chains_in_done(),//chains_in_done), 
		.chain_dump_en(),//chain_dump_en), 
		.chains_out(chains_out), 
		.chains_out_vld(chains_out_vld), 
		.chains_out_done(chains_out_done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		capture_en = 0;
		dclk = 0;
		din = 0;
		dump_en = 0;
		//chains_in = 0;
		//chains_in_vld = 0;
		//chains_in_done = 0;

		rst = 1;
		repeat(4)
			#5 clk = ~clk;

		rst = 0;
		forever
			#5 clk = ~clk;
	end

	initial begin
		#30 capture_en = 1;
		#10 capture_en = 0;
		dump_en = {32{1'b1}};
		#40;
		$finish;
	end
      
endmodule

