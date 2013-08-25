// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: fpu_add_ctl.v
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
//	Add pipeline synthesizable logic
//		- special input cases
//		- opcode pipeline
//		- sign logic
//		- exception logic
//		- datapath control- select lines and control logic
//
///////////////////////////////////////////////////////////////////////////////

module fpu_add_ctl_DUMMY (
	inq_in1_51,
	inq_in1_54,
	inq_in1_63,
	inq_in1_50_0_neq_0,
	inq_in1_53_32_neq_0,
	inq_in1_exp_eq_0,
	inq_in1_exp_neq_ffs,
	inq_in2_51,
	inq_in2_54,
	inq_in2_63,
	inq_in2_50_0_neq_0,
	inq_in2_53_32_neq_0,
	inq_in2_exp_eq_0,
	inq_in2_exp_neq_ffs,
	inq_op,
	inq_rnd_mode,
	inq_id,
	inq_fcc,
	inq_add,
	add_dest_rdy,
	a1stg_in2_neq_in1_frac,
	a1stg_in2_gt_in1_frac,
	a1stg_in2_eq_in1_exp,
	a1stg_expadd1,
	a2stg_expadd,
	a2stg_frac2hi_neq_0,
	a2stg_frac2lo_neq_0,
	a2stg_exp,
	a3stg_fsdtoix_nx,
	a3stg_fsdtoi_nx,
	a2stg_frac2_63,
	a4stg_exp,
	add_of_out_cout,
	a4stg_frac_neq_0,
	a4stg_shl_data_neq_0,
	a4stg_frac_dbl_nx,
	a4stg_frac_sng_nx,
	a1stg_expadd2,
	a1stg_expadd4_inv,
	a3stg_denorm,
	a3stg_denorm_inv,
	a4stg_denorm_inv,
	a3stg_exp,
	a4stg_round,
	a3stg_lead0,
	a4stg_rnd_frac_40,
	a4stg_rnd_frac_39,
	a4stg_rnd_frac_11,
	a4stg_rnd_frac_10,
	a4stg_frac_38_0_nx,
	a4stg_frac_9_0_nx,
	arst_l,
	grst_l,
	rclk,
	
	add_pipe_active,
	a1stg_denorm_sng_in1,
	a1stg_denorm_dbl_in1,
	a1stg_denorm_sng_in2,
	a1stg_denorm_dbl_in2,
	a1stg_norm_sng_in1,
	a1stg_norm_dbl_in1,
	a1stg_norm_sng_in2,
	a1stg_norm_dbl_in2,
	a1stg_step,
	a1stg_stepa,
	a1stg_sngop,
	a1stg_intlngop,
	a1stg_fsdtoix,
	a1stg_fstod,
	a1stg_fstoi,
	a1stg_fstox,
	a1stg_fdtoi,
	a1stg_fdtox,
	a1stg_faddsubs,
	a1stg_faddsubd,
	a1stg_fdtos,
	a2stg_faddsubop,
	a2stg_fsdtoix_fdtos,
	a2stg_fitos,
	a2stg_fitod,
	a2stg_fxtos,
	a2stg_fxtod,
	a3stg_faddsubop,
	a3stg_faddsubopa,
	a4stg_dblop,
	a6stg_fadd_in,
	add_id_out_in,
	add_fcc_out,
	a6stg_dbl_dst,
	a6stg_sng_dst,
	a6stg_long_dst,
	a6stg_int_dst,
	a6stg_fcmpop,
	a6stg_step,
	a3stg_sub_in,
	add_sign_out,
	add_cc_out,
	a4stg_in_of,
	add_exc_out,
	a2stg_frac1_in_frac1,
	a2stg_frac1_in_frac2,
	a1stg_2nan_in_inv,
	a1stg_faddsubop_inv,
	a2stg_frac1_in_qnan,
	a2stg_frac1_in_nv,
	a2stg_frac1_in_nv_dbl,
	a2stg_frac2_in_frac1,
	a2stg_frac2_in_qnan,
	a2stg_shr_cnt_in,
	a2stg_shr_cnt_5_inv_in,
	a2stg_shr_frac2_shr_int,
	a2stg_shr_frac2_shr_dbl,
	a2stg_shr_frac2_shr_sng,
	a2stg_shr_frac2_max,
	a2stg_sub_step,
	a2stg_fracadd_frac2_inv_in,
	a2stg_fracadd_frac2_inv_shr1_in,
	a2stg_fracadd_frac2,
	a2stg_fracadd_cin_in,
	a3stg_exp_7ff,
	a3stg_exp_ff,
	a3stg_exp_add,
	a2stg_expdec_neq_0,
	a3stg_exp10_0_eq0,
	a3stg_exp10_1_eq0,
	a3stg_fdtos_inv,
	a4stg_fixtos_fxtod_inv,
	a4stg_rnd_frac_add_inv,
	a4stg_shl_cnt_in,
	a4stg_rnd_sng,
	a4stg_rnd_dbl,
	add_frac_out_rndadd,
	add_frac_out_rnd_frac,
	add_frac_out_shl,
	a4stg_to_0,
	add_exp_out_expinc,
	add_exp_out_exp,
	add_exp_out_exp1,
	add_exp_out_expadd,
	a4stg_to_0_inv,

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
	input	[6:0] err_ctrl; // Error injection control

	//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****
	input	sh_clk; // Shadow/data clock
	input	sh_rst; // Shadow/data reset
	input	c_en; // Capture enable
	input	[1:0]	dump_en; // Dump enable
	output	[1:0]	ch_out; // Chains out
	output	[1:0]	ch_out_vld; // Chains out Valid
	output	[1:0]	ch_out_done; // Chains done

	//*****[ERROR WIRE INSTANTIATIONS]******
	wire [84:0] lcl_err;


parameter
		FADDS=	8'h41,
		FADDD=	8'h42,
		FSUBS=	8'h45,
		FSUBD=	8'h46,
		FCMPS=	8'h51,
		FCMPD=	8'h52,
		FCMPES=	8'h55,
		FCMPED=	8'h56,
		FSTOX=	8'h81,
		FDTOX=	8'h82,
		FSTOI=	8'hd1,
		FDTOI=	8'hd2,
		FSTOD=	8'hc9,
		FDTOS=	8'hc6,
		FXTOS=	8'h84,
		FXTOD=	8'h88,
		FITOS=	8'hc4,
		FITOD=	8'hc8;


input		inq_in1_51;		// request operand 1[51]
input		inq_in1_54;		// request operand 1[54]
input		inq_in1_63;		// request operand 1[63]
input		inq_in1_50_0_neq_0;	// request operand 1[50:0]!=0
input		inq_in1_53_32_neq_0;	// request operand 1[53:32]!=0
input		inq_in1_exp_eq_0;	// request operand 1[62:52]==0
input		inq_in1_exp_neq_ffs;	// request operand 1[62:52]!=0x7ff
input		inq_in2_51;		// request operand 2[51]
input		inq_in2_54;		// request operand 2[54]
input		inq_in2_63;		// request operand 2[63]
input		inq_in2_50_0_neq_0;	// request operand 2[50:0]!=0
input		inq_in2_53_32_neq_0;	// request operand 2[53:32]!=0
input		inq_in2_exp_eq_0;	// request operand 2[62:52]==0
input		inq_in2_exp_neq_ffs;	// request operand 2[62:52]!=0x7ff
input [7:0]	inq_op;			// request opcode to op pipes
input [1:0]	inq_rnd_mode;		// request rounding mode to op pipes
input [4:0]	inq_id;			// request ID to the operation pipes
input [1:0]	inq_fcc;		// request cc ID to op pipes
input		inq_add;		// add pipe request
input		add_dest_rdy;		// add result req accepted for CPX
input		a1stg_in2_neq_in1_frac;	// operand 2 fraction != oprnd 1 frac
input		a1stg_in2_gt_in1_frac;	// operand 2 fraction > oprnd 1 frac
input		a1stg_in2_eq_in1_exp;	// operand 2 exponent == oprnd 1 exp
input [11:0]	a1stg_expadd1;		// exponent adder 1 output- add 1 stage
input [11:0]	a2stg_expadd;		// exponent adder- add 2 stage
input		a2stg_frac2hi_neq_0;	// fraction 2[62:32]in add 2 stage != 0
input		a2stg_frac2lo_neq_0;	// fraction 2[31:11] in add 2 stage != 0
input [11:0]	a2stg_exp;		// exponent- add 2 stage
input		a3stg_fsdtoix_nx;	// inexact result for flt -> ints
input		a3stg_fsdtoi_nx;	// inexact result for flt -> 32b ints
input		a2stg_frac2_63;		// fraction 2 bit[63]- add 2 stage
input [11:0]	a4stg_exp;		// exponent- add 4 stage
input		add_of_out_cout;	// fraction rounding adder carry out
input		a4stg_frac_neq_0;	// fraction != 0- add 4 stage
input		a4stg_shl_data_neq_0;	// left shift result != 0- add 4 stage
input		a4stg_frac_dbl_nx;	// inexact double precision result
input		a4stg_frac_sng_nx;	// inexact single precision result
input [5:0]	a1stg_expadd2;		// exponent adder 2 output- add 1 stage
input [10:0]	a1stg_expadd4_inv;	// exponent adder 4 output- add 1 stage
input		a3stg_denorm;		// denorm output- add 3 stage
input		a3stg_denorm_inv;	// result is not a denorm- add 3 stage
input		a4stg_denorm_inv;	// 0 the exponent
input [10:0]	a3stg_exp;		// exponent- add 3 stage
input		a4stg_round;		// round the result- add 4 stage
input [5:0]	a3stg_lead0;		// leading 0's count- add 3 stage
input		a4stg_rnd_frac_40;	// rounded fraction[40]- add 4 stage
input		a4stg_rnd_frac_39;	// rounded fraction[39]- add 4 stage
input		a4stg_rnd_frac_11;	// rounded fraction[11]- add 4 stage
input		a4stg_rnd_frac_10;	// rounded fraction[10]- add 4 stage
input		a4stg_frac_38_0_nx;	// inexact single precision result
input		a4stg_frac_9_0_nx;	// inexact double precision result
input		arst_l;			// global asynchronous reset- asserted low
input		grst_l;			// global synchronous reset- asserted low
input		rclk;		// global clock

output		add_pipe_active;        // add pipe is executing a valid instr
output		a1stg_denorm_sng_in1;	// select line to normalized fraction 1
output		a1stg_denorm_dbl_in1;	// select line to normalized fraction 1
output		a1stg_denorm_sng_in2;	// select line to normalized fraction 2
output		a1stg_denorm_dbl_in2;	// select line to normalized fraction 2
output		a1stg_norm_sng_in1;	// select line to normalized fraction 1
output		a1stg_norm_dbl_in1;	// select line to normalized fraction 1
output		a1stg_norm_sng_in2;	// select line to normalized fraction 2
output		a1stg_norm_dbl_in2;	// select line to normalized fraction 2
output		a1stg_step;		// add pipe load
output		a1stg_stepa;		// add pipe load- copy
output		a1stg_sngop;		// single precision operation- add 1 stg
output		a1stg_intlngop;		// integer/long input- add 1 stage
output		a1stg_fsdtoix;		// float to integer convert- add 1 stg
output		a1stg_fstod;		// fstod- add 1 stage
output		a1stg_fstoi;		// fstoi- add 1 stage
output		a1stg_fstox;		// fstox- add 1 stage
output		a1stg_fdtoi;		// fdtoi- add 1 stage
output		a1stg_fdtox;		// fdtox- add 1 stage
output		a1stg_faddsubs;		// add/subtract single- add 1 stg
output		a1stg_faddsubd;		// add/subtract double- add 1 stg
output		a1stg_fdtos;		// fdtos- add 1 stage
output		a2stg_faddsubop;	// float add or subtract- add 2 stage
output		a2stg_fsdtoix_fdtos;	// float to integer convert- add 2 stg
output		a2stg_fitos;		// fitos- add 2 stage
output		a2stg_fitod;		// fitod- add 2 stage
output		a2stg_fxtos;		// fxtos- add 2 stage
output		a2stg_fxtod;		// fxtod- add 2 stage
output		a3stg_faddsubop;	// denorm compare lead0[10] input select
output [1:0]	a3stg_faddsubopa;	// denorm compare lead0[10] input select
output		a4stg_dblop;		// double precision operation- add 4 stg
output		a6stg_fadd_in;		// add pipe output request next cycle
output [9:0]	add_id_out_in;		// add pipe output ID next cycle
output [1:0]	add_fcc_out;		// add pipe input fcc passed through
output		a6stg_dbl_dst;		// float double result- add 6 stage
output		a6stg_sng_dst;		// float single result- add 6 stage
output		a6stg_long_dst;		// 64bit integer result- add 6 stage
output		a6stg_int_dst;		// 32bit integer result- add 6 stage
output		a6stg_fcmpop;		// compare- add 6 stage
output		a6stg_step;		// advance the add pipe
output		a3stg_sub_in;		// subtract in main adder- add 3 stage
output		add_sign_out;		// add sign output
output [1:0]	add_cc_out;		// add pipe result- condition
output		a4stg_in_of;		// add overflow- select exp out
output [4:0]	add_exc_out;		// add pipe result- exception flags
output		a2stg_frac1_in_frac1;	// select line to a2stg_frac1
output		a2stg_frac1_in_frac2;	// select line to a2stg_frac1
output		a1stg_2nan_in_inv;	// 2 NaN inputs- a1 stage
output		a1stg_faddsubop_inv;	// add/subtract- a1 stage
output		a2stg_frac1_in_qnan;	// make fraction 1 a QNaN
output		a2stg_frac1_in_nv;	// NV- make a new QNaN
output		a2stg_frac1_in_nv_dbl;	// NV- make a new double prec QNaN
output		a2stg_frac2_in_frac1;	// select line to a2stg_frac2
output		a2stg_frac2_in_qnan;	// make fraction 2 a QNaN
output [5:0]	a2stg_shr_cnt_in;	// right shift count input- add 1 stage
output    a2stg_shr_cnt_5_inv_in; // right shift count input[5]- add 1 stg
output		a2stg_shr_frac2_shr_int; // select line to a3stg_frac2
output		a2stg_shr_frac2_shr_dbl; // select line to a3stg_frac2
output		a2stg_shr_frac2_shr_sng; // select line to a3stg_frac2
output		a2stg_shr_frac2_max;	// select line to a3stg_frac2
output		a2stg_sub_step;		// select line to a3stg_frac2
output		a2stg_fracadd_frac2_inv_in; // sel line to main adder input 2
output		a2stg_fracadd_frac2_inv_shr1_in; // sel line to main adder in 2
output		a2stg_fracadd_frac2;	// select line to main adder input 2
output		a2stg_fracadd_cin_in;	// carry in to main adder- add 1 stage
output		a3stg_exp_7ff;		// select line to a3stg_exp
output		a3stg_exp_ff;		// select line to a3stg_exp
output		a3stg_exp_add;		// select line to a3stg_exp
output		a2stg_expdec_neq_0;	// exponent will be < 54
output		a3stg_exp10_0_eq0;	// exponent[10:0]==0- add 3 stage
output		a3stg_exp10_1_eq0;	// exponent[10:1]==0- add 3 stage
output		a3stg_fdtos_inv;	// double to single convert- add 3 stg
output		a4stg_fixtos_fxtod_inv;	// int to single/double cvt- add 4 stg
output		a4stg_rnd_frac_add_inv; // select line to a4stg_rnd_frac
output [9:0]	a4stg_shl_cnt_in;	// postnorm shift left count- add 3 stg
output		a4stg_rnd_sng;		// round to single precision- add 4 stg
output		a4stg_rnd_dbl;		// round to double precision- add 4 stg
output		add_frac_out_rndadd;	// select line to add_frac_out
output		add_frac_out_rnd_frac;	// select line to add_frac_out
output		add_frac_out_shl;	// select line to add_frac_out
output		a4stg_to_0;		// result to max finite on overflow
output		add_exp_out_expinc;	// select line to add_exp_out
output		add_exp_out_exp;	// select line to add_exp_out
output		add_exp_out_exp1;	// select line to add_exp_out
output		add_exp_out_expadd;	// select line to add_exp_out
output		a4stg_to_0_inv;		// result to infinity on overflow

input		se;			// scan_enable
input		si;			// scan in
output		so;			// scan ou

	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(229), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(2), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd229})) shadow_capture_fpu_add_ctl (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({rclk}), 
		.din(229'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789),
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


