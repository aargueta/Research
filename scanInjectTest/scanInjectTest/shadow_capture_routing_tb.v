`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:34:26 02/04/2013
// Design Name:   shadow_capture
// Module Name:   D:/Unrelated Junk/Stanford/Research/scanInjectTest/scanInjectTest/shadow_capture_routing_tb.v
// Project Name:  scanInjectTest
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

module shadow_capture_routing_tb;

	// Inputs
	reg clk;
	reg rst;
	reg capture_en;
	reg [1180:0] din;
	reg [5:0] dump_en;
//	reg [0:0] chains_in;
//	reg [0:0] chains_in_vld;
//	reg [0:0] chains_in_done;

	// Outputs
	wire [5:0] chains_out;
	wire [5:0] chains_out_vld;
	wire [5:0] chains_out_done;

	// Instantiate the Unit Under Test (UUT)
	shadow_capture #(.DFF_BITS(1181), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(6), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd1181})) uut (
		.clk(clk), 
		.rst(rst), 
		.capture_en(capture_en), 
		.dclk(clk), 
		.din(din), 
		.dump_en(dump_en), 
		.chains_in(), 
		.chains_in_vld(), 
		.chains_in_done(), 
		.chain_dump_en(), 
		.chains_out(chains_out), 
		.chains_out_vld(chains_out_vld), 
		.chains_out_done(chains_out_done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		capture_en = 0;
		din = 0;
		dump_en = 0;
//		chains_in = 0;
//		chains_in_vld = 0;
//		chains_in_done = 0;

		repeat(4)
			#10 clk = ~clk;
			
		rst = 0;
		forever
			#10 clk = ~clk;
	end
	
	initial begin
		#40;
		din = {29'h1EADBEEF,{36{32'hDEADBEEF}}};
		capture_en = 1'b1;
		#20 capture_en = 1'b0;
		dump_en = 6'b111111;
		#2000;	
	end
      
endmodule

