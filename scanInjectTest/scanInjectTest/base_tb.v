`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:58:12 01/25/2013
// Design Name:   base
// Module Name:   D:/Unrelated Junk/Stanford/Research/scanInjectTest/scanInjectTest/base_tb.v
// Project Name:  scanInjectTest
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: base
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module base_tb;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire out;
	wire err_en;
	wire err_ctrl;
	wire sh_clk;
	wire sh_rst;
	wire c_en;
	wire dump_en;
	wire ch_out;
	wire ch_out_vld;
	wire ch_out_done;

	// Instantiate the Unit Under Test (UUT)
	base uut (
		.clk(clk), 
		.rst(rst), 
		.out(out), 
		.err_en(err_en), 
		.err_ctrl(err_ctrl), 
		.sh_clk(sh_clk), 
		.sh_rst(sh_rst), 
		.c_en(c_en), 
		.dump_en(dump_en), 
		.ch_out(ch_out), 
		.ch_out_vld(ch_out_vld), 
		.ch_out_done(ch_out_done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

