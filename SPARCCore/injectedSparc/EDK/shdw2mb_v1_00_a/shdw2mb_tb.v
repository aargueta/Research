`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:45:54 03/30/2013
// Design Name:   shdw2mb
// Module Name:   D:/Unrelated Junk/Stanford/Research/SPARCCore/injectedSparc/shdw2mb_tb.v
// Project Name:  injectedSparc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: shdw2mb
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module shdw2mb_tb;

	// Inputs
	reg clk;
	reg rst;
	reg fsl_m_full;
	reg [31:0] fsl_s_data;
	reg fsl_s_ctrl;
	reg fsl_s_exists;
	reg [31:0] sh_out;
	reg [31:0] sh_out_vld;
	reg [31:0] sh_out_done;

	// Outputs
	wire [31:0] fsl_m_data;
	wire fsl_m_ctrl;
	wire fsl_m_write;
	wire fsl_s_read;
	wire err_en;
	wire [11:0] err_ctrl;
	wire sh_rst;
	wire c_en;
	wire [31:0] dump_en;

	// Instantiate the Unit Under Test (UUT)
	shdw2mb uut (
		.clk(clk), 
		.rst(rst), 
		.fsl_m_data(fsl_m_data), 
		.fsl_m_ctrl(fsl_m_ctrl), 
		.fsl_m_write(fsl_m_write), 
		.fsl_m_full(fsl_m_full), 
		.fsl_s_read(fsl_s_read), 
		.fsl_s_data(fsl_s_data), 
		.fsl_s_ctrl(fsl_s_ctrl), 
		.fsl_s_exists(fsl_s_exists), 
		.err_en(err_en), 
		.err_ctrl(err_ctrl), 
		.sh_rst(sh_rst), 
		.c_en(c_en), 
		.dump_en(dump_en), 
		.sh_out(sh_out), 
		.sh_out_vld(sh_out_vld), 
		.sh_out_done(sh_out_done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		fsl_m_full = 0;
		fsl_s_data = 0;
		fsl_s_ctrl = 0;
		fsl_s_exists = 0;
		sh_out = 0;
		sh_out_vld = 0;
		sh_out_done = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

