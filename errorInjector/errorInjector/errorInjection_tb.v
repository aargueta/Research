`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   05:59:22 11/27/2012
// Design Name:   first_level
// Module Name:   D:/Unrelated Junk/Stanford/Research/errorInjector/errorInjector/errorInjection_tb.v
// Project Name:  errorInjector
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: first_level
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module errorInjection_tb;

	// Inputs
	reg clk;
	reg [5:0] one;
	reg err_en;
	reg [1:0] err_ctrl;
	reg sh_clk;
	reg sh_rst;
	reg c_en;
	reg [63:0] dump_en;

	// Outputs
	wire [5:0] two;
	wire [63:0] ch_out;
	wire [63:0] ch_out_vld;
	wire [63:0] ch_out_done;

	// Instantiate the Unit Under Test (UUT)
	first_level uut (
		.clk(clk), 
		.one(one), 
		.two(two), 
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
		one = 0;
		err_en = 0;
		err_ctrl = 0;
		sh_clk = 0;
		sh_rst = 0;
		c_en = 0;
		dump_en = 0;

		repeat(4)begin
			clk = ~clk;
			#5;
			err_ctrl = err_ctrl + 1;
			clk = ~clk;
			#5;
		end
		
		err_en = 1;
		err_ctrl = 0;
		#10;
		
		repeat(4)begin
			clk = ~clk;
			#5;
			err_ctrl = err_ctrl + 1;
			clk = ~clk;
			#5;
		end
		
		$finish;
	end
      
endmodule

