// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: fpu_add_frac_dp.v
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
//	Add pipeline fraction datapath.
//
///////////////////////////////////////////////////////////////////////////////

module fpu_add_frac_dp_DUMMY (
	inq_in1,
	inq_in2,
	a1stg_step,
	a1stg_sngop,
	a1stg_expadd3_11,
	a1stg_norm_dbl_in1,
	a1stg_denorm_dbl_in1,
	a1stg_norm_sng_in1,
	a1stg_denorm_sng_in1,
	a1stg_norm_dbl_in2,
	a1stg_denorm_dbl_in2,
	a1stg_norm_sng_in2,
	a1stg_denorm_sng_in2,
	a1stg_intlngop,
	a2stg_frac1_in_frac1,
	a2stg_frac1_in_frac2,
	a1stg_2nan_in_inv,
	a1stg_faddsubop_inv,
	a2stg_frac1_in_qnan,
	a2stg_frac1_in_nv,
	a2stg_frac1_in_nv_dbl,
	a6stg_step,
	a2stg_frac2_in_frac1,
	a2stg_frac2_in_qnan,
	a2stg_shr_cnt_in,
	a2stg_shr_cnt_5_inv_in,
	a2stg_shr_frac2_shr_int,
	a2stg_shr_frac2_shr_dbl,
	a2stg_shr_frac2_shr_sng,
	a2stg_shr_frac2_max,
	a2stg_expadd_11,
	a2stg_sub_step,
	a2stg_fracadd_frac2_inv_in,
	a2stg_fracadd_frac2_inv_shr1_in,
	a2stg_fracadd_frac2,
	a2stg_fracadd_cin_in,
	a2stg_exp,
	a2stg_expdec_neq_0,
	a3stg_faddsubopa,
	a3stg_sub_in,
	a3stg_exp10_0_eq0,
	a3stg_exp10_1_eq0,
	a3stg_exp_0,
	a4stg_rnd_frac_add_inv,
	a3stg_fdtos_inv,
	a4stg_fixtos_fxtod_inv,
	a4stg_rnd_sng,
	a4stg_rnd_dbl,
	a4stg_shl_cnt_in,
	add_frac_out_rndadd,
	add_frac_out_rnd_frac,
	a4stg_in_of,
	add_frac_out_shl,
	a4stg_to_0,
	fadd_clken_l,
	rclk,
	
	a1stg_in2_neq_in1_frac,
	a1stg_in2_gt_in1_frac,
	a1stg_in2_eq_in1_exp,
	a2stg_frac2_63,
	a2stg_frac2hi_neq_0,
	a2stg_frac2lo_neq_0,
	a3stg_fsdtoix_nx,
	a3stg_fsdtoi_nx,
	a3stg_denorm,
	a3stg_denorm_inv,
	a3stg_lead0,
	a4stg_round,
	a4stg_shl_cnt,
	a4stg_denorm_inv,
	a3stg_inc_exp_inv,
	a3stg_same_exp_inv,
	a3stg_dec_exp_inv,
	a4stg_rnd_frac_40,
	a4stg_rnd_frac_39,
	a4stg_rnd_frac_11,
	a4stg_rnd_frac_10,
	a4stg_rndadd_cout,
	a4stg_frac_9_0_nx,
	a4stg_frac_dbl_nx,
	a4stg_frac_38_0_nx,
	a4stg_frac_sng_nx,
	a4stg_frac_neq_0,
	a4stg_shl_data_neq_0,
	add_of_out_cout,
	add_frac_out,

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
	input	[5:0]	dump_en; // Dump enable
	output	[5:0]	ch_out; // Chains out
	output	[5:0]	ch_out_vld; // Chains out Valid
	output	[5:0]	ch_out_done; // Chains done

	//*****[ERROR WIRE INSTANTIATIONS]******
	wire [18:0] lcl_err;


input [62:0]	inq_in1;		// request operand 1 to op pipes
input [63:0]	inq_in2;		// request operand 2 to op pipes
input		a1stg_step;		// add pipe load
input		a1stg_sngop;		// single precision operation- add 1 stg
input		a1stg_expadd3_11;	// exponent adder sign out- add 1 stg
input		a1stg_norm_dbl_in1;	// select line to normalized fraction 1
input		a1stg_denorm_dbl_in1;	// select line to normalized fraction 1
input		a1stg_norm_sng_in1;	// select line to normalized fraction 1
input		a1stg_denorm_sng_in1;	// select line to normalized fraction 1
input		a1stg_norm_dbl_in2;	// select line to normalized fraction 2
input		a1stg_denorm_dbl_in2;	// select line to normalized fraction 2
input		a1stg_norm_sng_in2;	// select line to normalized fraction 2
input		a1stg_denorm_sng_in2;	// select line to normalized fraction 2
input		a1stg_intlngop;		// integer/long input- add 1 stage
input		a2stg_frac1_in_frac1;	// select line to a2stg_frac1
input		a2stg_frac1_in_frac2;	// select line to a2stg_frac1
input		a1stg_2nan_in_inv;	// 2 NaN inputs- a1 stage
input		a1stg_faddsubop_inv;	// add/subtract- a1 stage
input		a2stg_frac1_in_qnan;	// make fraction 1 a QNaN
input		a2stg_frac1_in_nv;	// NV- make a new prec QNaN
input		a2stg_frac1_in_nv_dbl;	// NV- make a new double prec QNaN
input		a6stg_step;		// advance the add pipe
input		a2stg_frac2_in_frac1;	// select line to a2stg_frac2
input		a2stg_frac2_in_qnan;	// make fraction 2 a QNaN
input [5:0]	a2stg_shr_cnt_in;	// right shift count input- add 1 stage
input		a2stg_shr_cnt_5_inv_in;	// right shift count input[5]- add 1 stg
input		a2stg_shr_frac2_shr_int; // select line to a3stg_frac2
input		a2stg_shr_frac2_shr_dbl; // select line to a3stg_frac2
input		a2stg_shr_frac2_shr_sng; // select line to a3stg_frac2
input		a2stg_shr_frac2_max;	// select line to a3stg_frac2
input		a2stg_expadd_11;	// exponent adder[11]- add 2 stage
input		a2stg_sub_step;		// select line to a3stg_frac2
input		a2stg_fracadd_frac2_inv_in; // sel line to main adder input 2
input		a2stg_fracadd_frac2_inv_shr1_in; // sel line to main adder in 2
input		a2stg_fracadd_frac2;	// select line to main adder input 2
input		a2stg_fracadd_cin_in;	// carry in to main adder- add 1 stage
input [5:0]	a2stg_exp;		// exponent add 2 stage bits[5:0]
input		a2stg_expdec_neq_0;	// exponent will be < 54
input [1:0]	a3stg_faddsubopa;	// denorm compare lead0[10] input select
input		a3stg_sub_in;		// subtract in main adder- add 3 stage
input		a3stg_exp10_0_eq0;	// exponent[10:0]==0- add 3 stg
input		a3stg_exp10_1_eq0;	// exponent[10:1]==0- add 3 stg
input		a3stg_exp_0;		// exponent[0]- add 3 stg
input		a4stg_rnd_frac_add_inv;	// select line to a4stg_rnd_frac
input		a3stg_fdtos_inv;	// double to single convert- add 3 stg
input		a4stg_fixtos_fxtod_inv;	// int to single/double cvt- add 4 stg
input		a4stg_rnd_sng;		// round to single precision- add 4 stg
input		a4stg_rnd_dbl;		// round to double precision- add 4 stg
input [9:0]	a4stg_shl_cnt_in;	// postnorm shift left count- add 3 stg
input		add_frac_out_rndadd;	// select line to add_frac_out
input		add_frac_out_rnd_frac;	// select line to add_frac_out
input		a4stg_in_of;		// add overflow- select fraction out
input		add_frac_out_shl;	// select line to add_frac_out
input		a4stg_to_0;		// result to max finite on overflow
input		fadd_clken_l;           // add pipe clk enable - asserted low
input		rclk;		// global clock

output		a1stg_in2_neq_in1_frac;	// operand 2 fraction != oprnd 1 frac
output		a1stg_in2_gt_in1_frac;	// operand 2 fraction > oprnd 1 frac
output		a1stg_in2_eq_in1_exp;	// operand 2 exponent == oprnd 1 exp
output		a2stg_frac2_63;		// fraction 2 bit[63]- add 2 stage
output		a2stg_frac2hi_neq_0;	// fraction 2[62:32]in add 2 stage != 0
output		a2stg_frac2lo_neq_0;	// fraction 2[31:11] in add 2 stage != 0
output		a3stg_fsdtoix_nx;	// inexact result for flt -> ints
output		a3stg_fsdtoi_nx;	// inexact result for flt -> 32b ints
output		a3stg_denorm;		// denorm output- add 3 stage
output		a3stg_denorm_inv;	// result is not a denorm- add 3 stage
output [5:0]	a3stg_lead0;		// leading 0's count- add 3 stage
output		a4stg_round;		// round the result- add 4 stage
output [5:0]	a4stg_shl_cnt;		// subtract in main adder- add 4 stage
output		a4stg_denorm_inv;	// 0 the exponent
output		a3stg_inc_exp_inv;	// increment the exponent- add 3 stg
output		a3stg_same_exp_inv;	// keep the exponent- add 3 stg
output		a3stg_dec_exp_inv;	// decrement the exponent- add 3 stg
output		a4stg_rnd_frac_40;	// rounded fraction[40]- add 4 stage
output		a4stg_rnd_frac_39;	// rounded fraction[39]- add 4 stage
output		a4stg_rnd_frac_11;	// rounded fraction[11]- add 4 stage
output		a4stg_rnd_frac_10;	// rounded fraction[10]- add 4 stage
output		a4stg_rndadd_cout;	// fraction rounding adder carry out
output		a4stg_frac_9_0_nx;	// inexact double precision result
output		a4stg_frac_dbl_nx;	// inexact double precision result
output		a4stg_frac_38_0_nx;	// inexact single precision result
output		a4stg_frac_sng_nx;	// inexact single precision result
output		a4stg_frac_neq_0;	// fraction != 0- add 4 stage
output		a4stg_shl_data_neq_0;	// left shift result != 0- add 4 stage
output		add_of_out_cout;	// fraction rounding adder carry out
output [63:0]	add_frac_out;		// add fraction output

input           se;                     // scan_enable
input           si;                     // scan in
output          so;                     // scan out

	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(1181), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(6), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd1181})) shadow_capture_fpu_add_frac_dp (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({rclk}), 
		.din({{18{64'h0123456789ABCDEF}},29'h01234567}),
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

