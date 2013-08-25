// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: fpu_add_exp_dp.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
///////////////////////////////////////////////////////////////////////////////
//
//	Add pipeline exponent datapath.
//
///////////////////////////////////////////////////////////////////////////////


module fpu_add_exp_dp_DUMMY (
	inq_in1,
	inq_in2,
	inq_op,
	inq_op_7,
	a1stg_step,
	a1stg_faddsubd,
	a1stg_faddsubs,
	a1stg_fsdtoix,
	a6stg_step,
	a1stg_fstod,
	a1stg_fdtos,
	a1stg_fstoi,
	a1stg_fstox,
	a1stg_fdtoi,
	a1stg_fdtox,
	a2stg_fsdtoix_fdtos,
	a2stg_faddsubop,
	a2stg_fitos,
	a2stg_fitod,
	a2stg_fxtos,
	a2stg_fxtod,
	a3stg_exp_7ff,
	a3stg_exp_ff,
	a3stg_exp_add,
	a3stg_inc_exp_inv,
	a3stg_same_exp_inv,
	a3stg_dec_exp_inv,
	a3stg_faddsubop,
	a3stg_fdtos_inv,
	a4stg_fixtos_fxtod_inv,
	a4stg_shl_cnt,
	a4stg_denorm_inv,
	a4stg_rndadd_cout,
	add_exp_out_expinc,
	add_exp_out_exp,
	add_exp_out_exp1,
	a4stg_in_of,
	add_exp_out_expadd,
	a4stg_dblop,
	a4stg_to_0_inv,
	fadd_clken_l,
	rclk,
	
	a1stg_expadd3_11,
	a1stg_expadd1_11_0,
	a1stg_expadd4_inv,
	a1stg_expadd2_5_0,
	a2stg_exp,
	a2stg_expadd,
	a3stg_exp_10_0,
	a4stg_exp_11_0,
	add_exp_out,

	se,
	si,
	so

,
//*****[ERROR CAPTURE MODULE INOUTS]*****
	err_en, // Error injection enable
	err_ctrl // Error injection control
,
//*****[SHADOW CAPTURE MODULE INOUTS]*****
	sh_clk, // Shadow/data clock
	sh_rst, // Shadow/data reset
	c_en, // Capture enable
	dump_en, // Dump enable
	ch_out, // Chains out
	ch_out_vld, // Chains out valid
	ch_out_done // Chains done
);

	//*****[ERROR CAPTURE MODULE INOUTS INSTANTIATIONS]*****
	input	err_en; // Error injection enable
	input	[4:0] err_ctrl; // Error injection control

	//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****
	input	sh_clk; // Shadow/data clock
	input	sh_rst; // Shadow/data reset
	input	c_en; // Capture enable
	input	[1:0]	dump_en; // Dump enable
	output	[1:0]	ch_out; // Chains out
	output	[1:0]	ch_out_vld; // Chains out Valid
	output	[1:0]	ch_out_done; // Chains done

	//*****[ERROR WIRE INSTANTIATIONS]******
	wire [23:0] lcl_err;


input [62:52]	inq_in1;		// request operand 1 to op pipes
input [62:52]	inq_in2;		// request operand 2 to op pipes
input [1:0]	inq_op;			// request opcode[1:0]
input		inq_op_7;		// request opcode[7]
input		a1stg_step;		// add pipe load
input		a1stg_faddsubd;		// add/subtract double- add 1 stg
input		a1stg_faddsubs;		// add/subtract single- add 1 stg
input		a1stg_fsdtoix;		// float to integer convert- add 1 stg
input		a6stg_step;		// advance the add pipe
input		a1stg_fstod;		// fstod- add 1 stage
input		a1stg_fdtos;		// fdtos- add 1 stage
input		a1stg_fstoi;		// fstoi- add 1 stage
input		a1stg_fstox;		// fstox- add 1 stage
input		a1stg_fdtoi;		// fdtoi- add 1 stage
input		a1stg_fdtox;		// fdtox- add 1 stage
input		a2stg_fsdtoix_fdtos;	// float to integer convert- add 2 stg
input		a2stg_faddsubop;	// float add or subtract- add 2 stage
input		a2stg_fitos;		// fitos- add 2 stage
input		a2stg_fitod;		// fitod- add 2 stage
input		a2stg_fxtos;		// fxtos- add 2 stage
input		a2stg_fxtod;		// fxtod- add 2 stage
input		a3stg_exp_7ff;		// select line to a3stg_exp
input		a3stg_exp_ff;		// select line to a3stg_exp
input		a3stg_exp_add;		// select line to a3stg_exp
input		a3stg_inc_exp_inv;	// increment the exponent- add 3 stg
input		a3stg_same_exp_inv;	// keep the exponent- add 3 stg
input		a3stg_dec_exp_inv;	// decrement the exponent- add 3 stg
input		a3stg_faddsubop;	// add/subtract- add 3 stage
input		a3stg_fdtos_inv;	// double to single convert- add 3 stg
input		a4stg_fixtos_fxtod_inv;	// int to single/double cvt- add 4 stg
input [5:0]	a4stg_shl_cnt;		// postnorm shift left count- add 4 stg
input		a4stg_denorm_inv;	// 0 the exponent
input		a4stg_rndadd_cout;	// fraction rounding adder carry out
input		add_exp_out_expinc;	// select line to add_exp_out
input		add_exp_out_exp;	// select line to add_exp_out
input		add_exp_out_exp1;	// select line to add_exp_out
input		a4stg_in_of;		// add overflow- select exp out
input		add_exp_out_expadd;	// select line to add_exp_out
input		a4stg_dblop;		// double precision operation- add 4 stg
input		a4stg_to_0_inv;		// result to infinity on overflow
input		fadd_clken_l;           // add pipe clk enable - asserted low
input		rclk;		// global clock

output        	a1stg_expadd3_11;	// exponent adder 3 output- add 1 stage
output [11:0]	a1stg_expadd1_11_0;	// exponent adder 1 output- add 1 stage
output [10:0]	a1stg_expadd4_inv;	// exponent adder 4 output- add 1 stage
output [5:0]	a1stg_expadd2_5_0;	// exponent adder 2 output- add 1 stage
output [11:0]	a2stg_exp;		// exponent- add 2 stage
output [12:0]	a2stg_expadd;		// exponent adder- add 2 stage
output [10:0]	a3stg_exp_10_0;		// exponent adder- add 3 stage
output [11:0]	a4stg_exp_11_0;		// exponent adder- add 4 stage
output [10:0]	add_exp_out;		// add exponent output

input           se;                     // scan_enable
input           si;                     // scan in
output          so;                     // scan out


	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(282), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(2), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd282})) shadow_capture_fpu_add_exp_dp (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({sh_clk}), 
		.din(288'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567),
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


