`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:13:36 02/01/2013
// Design Name:   fpu_add
// Module Name:   D:/Unrelated Junk/Stanford/Research/scanInjectTest/scanInjectTest/fpu_add_tb.v
// Project Name:  scanInjectTest
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fpu_add
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fpu_add_tb;

	// Inputs
	reg [7:0] inq_op;
	reg [1:0] inq_rnd_mode;
	reg [4:0] inq_id;
	reg [1:0] inq_fcc;
	reg [63:0] inq_in1;
	reg inq_in1_50_0_neq_0;
	reg inq_in1_53_32_neq_0;
	reg inq_in1_exp_eq_0;
	reg inq_in1_exp_neq_ffs;
	reg [63:0] inq_in2;
	reg inq_in2_50_0_neq_0;
	reg inq_in2_53_32_neq_0;
	reg inq_in2_exp_eq_0;
	reg inq_in2_exp_neq_ffs;
	reg inq_add;
	reg add_dest_rdy;
	reg fadd_clken_l;
	reg arst_l;
	reg grst_l;
	reg rclk;
	reg se_add_exp;
	reg se_add_frac;
	reg si;
	reg err_en;
	reg [6:0] err_ctrl;
	reg sh_clk;
	reg sh_rst;
	reg c_en;
	reg [7:0] dump_en;

	// Outputs
	wire add_pipe_active;
	wire a1stg_step;
	wire a6stg_fadd_in;
	wire [9:0] add_id_out_in;
	wire a6stg_fcmpop;
	wire [4:0] add_exc_out;
	wire a6stg_dbl_dst;
	wire a6stg_sng_dst;
	wire a6stg_long_dst;
	wire a6stg_int_dst;
	wire add_sign_out;
	wire [10:0] add_exp_out;
	wire [63:0] add_frac_out;
	wire [1:0] add_cc_out;
	wire [1:0] add_fcc_out;
	wire so;
	wire [7:0] ch_out;
	wire [7:0] ch_out_vld;
	wire [7:0] ch_out_done;

	// Instantiate the Unit Under Test (UUT)
	fpu_add uut (
		.inq_op(inq_op), 
		.inq_rnd_mode(inq_rnd_mode), 
		.inq_id(inq_id), 
		.inq_fcc(inq_fcc), 
		.inq_in1(inq_in1), 
		.inq_in1_50_0_neq_0(inq_in1_50_0_neq_0), 
		.inq_in1_53_32_neq_0(inq_in1_53_32_neq_0), 
		.inq_in1_exp_eq_0(inq_in1_exp_eq_0), 
		.inq_in1_exp_neq_ffs(inq_in1_exp_neq_ffs), 
		.inq_in2(inq_in2), 
		.inq_in2_50_0_neq_0(inq_in2_50_0_neq_0), 
		.inq_in2_53_32_neq_0(inq_in2_53_32_neq_0), 
		.inq_in2_exp_eq_0(inq_in2_exp_eq_0), 
		.inq_in2_exp_neq_ffs(inq_in2_exp_neq_ffs), 
		.inq_add(inq_add), 
		.add_dest_rdy(add_dest_rdy), 
		.fadd_clken_l(fadd_clken_l), 
		.arst_l(arst_l), 
		.grst_l(grst_l), 
		.rclk(rclk), 
		.add_pipe_active(add_pipe_active), 
		.a1stg_step(a1stg_step), 
		.a6stg_fadd_in(a6stg_fadd_in), 
		.add_id_out_in(add_id_out_in), 
		.a6stg_fcmpop(a6stg_fcmpop), 
		.add_exc_out(add_exc_out), 
		.a6stg_dbl_dst(a6stg_dbl_dst), 
		.a6stg_sng_dst(a6stg_sng_dst), 
		.a6stg_long_dst(a6stg_long_dst), 
		.a6stg_int_dst(a6stg_int_dst), 
		.add_sign_out(add_sign_out), 
		.add_exp_out(add_exp_out), 
		.add_frac_out(add_frac_out), 
		.add_cc_out(add_cc_out), 
		.add_fcc_out(add_fcc_out), 
		.se_add_exp(se_add_exp), 
		.se_add_frac(se_add_frac), 
		.si(si), 
		.so(so), 
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
		inq_op = 0;
		inq_rnd_mode = 0;
		inq_id = 0;
		inq_fcc = 0;
		inq_in1 = 0;
		inq_in1_50_0_neq_0 = 0;
		inq_in1_53_32_neq_0 = 0;
		inq_in1_exp_eq_0 = 0;
		inq_in1_exp_neq_ffs = 0;
		inq_in2 = 0;
		inq_in2_50_0_neq_0 = 0;
		inq_in2_53_32_neq_0 = 0;
		inq_in2_exp_eq_0 = 0;
		inq_in2_exp_neq_ffs = 0;
		inq_add = 0;
		add_dest_rdy = 0;
		fadd_clken_l = 0;
		arst_l = 0;
		grst_l = 0;
		rclk = 0;
		se_add_exp = 0;
		se_add_frac = 0;
		si = 0;
		err_en = 0;
		err_ctrl = 0;
		sh_clk = 0;
		sh_rst = 0;
		c_en = 0;
		dump_en = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

