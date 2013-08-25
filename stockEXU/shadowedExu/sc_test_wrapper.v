`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:41:45 10/18/2012 
// Design Name: 
// Module Name:    sc_test_wrapper 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sc_test_wrapper(sh_clk, sh_rst, c_en, din, dump_en, ch_out, ch_out_vld, ch_out_done);
	 
	 
	 
input	sh_clk; // Shadow/data clock
input	sh_rst; // Shadow/data reset
input	c_en; // Capture enable
input [63:0] din;
input	[31:0] dump_en; // Dump enable
output	[31:0]	ch_out; // Chains out
output	[31:0]	ch_out_vld; // Chains out Valid
output	[31:0]	ch_out_done; // Chains done

shadow_capture #(
			.DFF_BITS(64),
			.USE_DCLK(1),
			.CHAINS_IN(0),
			.CHAINS_OUT(32), 
			.DISCRETE_DFFS(4), 
			.INPUT_WIDTHS({32'd8, 32'd16, 32'd32, 32'd8})) 
		shadow_capture_bw_r_irf (
				.clk(sh_clk), 
				.rst(sh_rst), 
				.capture_en(c_en), 
				.dclk({4{clk}}), 
				.din(din),
				.dump_en(dump_en), 
				.chains_in(), 
				.chains_in_vld(), 
				.chains_in_done(), 
				.chain_dump_en(), 
				.chains_out(ch_out), 
				.chains_out_vld(ch_out_vld), 
				.chains_out_done(ch_out_done)
  );


endmodule
