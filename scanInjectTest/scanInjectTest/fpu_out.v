// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: fpu_out.v
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
//	FPU result output.
//
///////////////////////////////////////////////////////////////////////////////


module fpu_out (
	d8stg_fdiv_in,
	m6stg_fmul_in,
	a6stg_fadd_in,
	div_id_out_in,
	m6stg_id_in,
	add_id_out_in,
	div_exc_out,
	d8stg_fdivd,
	d8stg_fdivs,
	div_sign_out,
	div_exp_out,
	div_frac_out,
	mul_exc_out,
	m6stg_fmul_dbl_dst,
	m6stg_fmuls,
	mul_sign_out,
	mul_exp_out,
	mul_frac_out,
	add_exc_out,
	a6stg_fcmpop,
	add_cc_out,
	add_fcc_out,
	a6stg_dbl_dst,
	a6stg_sng_dst,
	a6stg_long_dst,
	a6stg_int_dst,
	add_sign_out,
	add_exp_out,
	add_frac_out,
	arst_l,
	grst_l,
	rclk,
	
	fp_cpx_req_cq,
	add_dest_rdy,
	mul_dest_rdy,
	div_dest_rdy,
	fp_cpx_data_ca,

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
	input	[3:0] err_ctrl; // Error injection control

	//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****
	input	sh_clk; // Shadow/data clock
	input	sh_rst; // Shadow/data reset
	input	c_en; // Capture enable
	input	[0:0]	dump_en; // Dump enable
	output	[0:0]	ch_out; // Chains out
	output	[0:0]	ch_out_vld; // Chains out Valid
	output	[0:0]	ch_out_done; // Chains done

	//*****[ERROR WIRE INSTANTIATIONS]******
	wire fpu_out_dp_err_en;
	wire [0:0] fpu_out_dp_err_ctrl;
	wire fpu_out_ctl_err_en;
	wire [2:0] fpu_out_ctl_err_ctrl;

//*****[SHADOW WIRE INSTANTIATIONS]*****
	wire [1:0] inst_ch_out;
	wire [1:0] inst_ch_out_vld;
	wire [1:0] inst_ch_out_done;
	wire [1:0] ch_dump_en;



input		d8stg_fdiv_in;		// div pipe output request next cycle
input		m6stg_fmul_in;		// mul pipe output request next cycle
input		a6stg_fadd_in;		// add pipe output request next cycle
input [9:0]	div_id_out_in;		// div pipe output ID next cycle
input [9:0]	m6stg_id_in;		// mul pipe output ID next cycle
input [9:0]	add_id_out_in;		// add pipe output ID next cycle
input [4:0]	div_exc_out;		// divide pipe result- exception flags
input		d8stg_fdivd;		// divide double- divide stage 8
input		d8stg_fdivs;		// divide single- divide stage 8
input		div_sign_out;		// divide sign output
input [10:0]	div_exp_out;		// divide exponent output
input [51:0]	div_frac_out;		// divide fraction output
input [4:0]	mul_exc_out;		// multiply pipe result- exception flags
input		m6stg_fmul_dbl_dst;	// double precision multiply result
input		m6stg_fmuls;		// fmuls- multiply 6 stage
input		mul_sign_out;		// multiply sign output
input [10:0]	mul_exp_out;		// multiply exponent output
input [51:0]	mul_frac_out;		// multiply fraction output
input [4:0]	add_exc_out;		// add pipe result- exception flags
input		a6stg_fcmpop;		// compare- add 6 stage
input [1:0]	add_cc_out;		// add pipe result- condition
input [1:0]	add_fcc_out;		// add pipe input fcc passed through
input		a6stg_dbl_dst;		// float double result- add 6 stage
input		a6stg_sng_dst;		// float single result- add 6 stage
input		a6stg_long_dst;		// 64bit integer result- add 6 stage
input		a6stg_int_dst;		// 32bit integer result- add 6 stage
input		add_sign_out;		// add sign output
input [10:0]	add_exp_out;		// add exponent output
input [63:0]	add_frac_out;		// add fraction output
input		arst_l;			// global async. reset- asserted low
input		grst_l;			// global sync. reset- asserted low
input		rclk;			// global clock

output [7:0]	fp_cpx_req_cq;		// FPU result request to CPX
output		add_dest_rdy;		// add pipe result request this cycle
output		mul_dest_rdy;		// mul pipe result request this cycle
output		div_dest_rdy;		// div pipe result request this cycle
output [144:0]	fp_cpx_data_ca;		// FPU result to CPX

input           se;                     // scan_enable
input           si;                     // scan in
output          so;                     // scan out


///////////////////////////////////////////////////////////////////////////////
//
//	Outputs of fpu_out_ctl.
//
///////////////////////////////////////////////////////////////////////////////

wire [7:0]	fp_cpx_req_cq;		// FPU result request to CPX
wire [1:0]	req_thread;		// thread ID of result req this cycle
wire [2:0]	dest_rdy;		// pipe with result request this cycle
wire		add_dest_rdy;		// add pipe result request this cycle
wire		mul_dest_rdy;		// mul pipe result request this cycle
wire		div_dest_rdy;		// div pipe result request this cycle


///////////////////////////////////////////////////////////////////////////////
//
//	Outputs of fpu_out_dp.
//
///////////////////////////////////////////////////////////////////////////////

wire [144:0]	fp_cpx_data_ca;		// FPU result to CPX


///////////////////////////////////////////////////////////////////////////////
//
//	Instantiations.
//
///////////////////////////////////////////////////////////////////////////////

fpu_out_ctl fpu_out_ctl (
	.d8stg_fdiv_in			(d8stg_fdiv_in),
	.m6stg_fmul_in			(m6stg_fmul_in),
	.a6stg_fadd_in			(a6stg_fadd_in),
	.div_id_out_in			(div_id_out_in[9:0]),
	.m6stg_id_in			(m6stg_id_in[9:0]),
	.add_id_out_in			(add_id_out_in[9:0]),
	.arst_l				(arst_l),
	.grst_l				(grst_l),
	.rclk			(rclk),

	.fp_cpx_req_cq			(fp_cpx_req_cq[7:0]),
	.req_thread			(req_thread[1:0]),
	.dest_rdy			(dest_rdy[2:0]),
	.add_dest_rdy			(add_dest_rdy),
	.mul_dest_rdy			(mul_dest_rdy),
	.div_dest_rdy			(div_dest_rdy),

	.se                             (se),
        .si                             (si),
        .so                             (scan_out_fpu_out_ctl)
,
		.err_en(fpu_out_ctl_err_en), // [ERROR]
		.err_ctrl(fpu_out_ctl_err_ctrl) // [ERROR]
,
		.sh_clk(sh_clk),   // [SHADOW]
		.sh_rst(sh_rst),   // [SHADOW]
		.c_en(c_en),   // [SHADOW]
		.dump_en(ch_dump_en[1]),   // [SHADOW]
		.ch_out(inst_ch_out[1]),   // [SHADOW]
		.ch_out_done(inst_ch_out_done[1]),    // [SHADOW]
		.ch_out_vld(inst_ch_out_vld[1]) // [SHADOW]
);


fpu_out_dp fpu_out_dp (
	.dest_rdy			(dest_rdy[2:0]),
	.req_thread			(req_thread[1:0]),
	.div_exc_out			(div_exc_out[4:0]),
	.d8stg_fdivd			(d8stg_fdivd),
	.d8stg_fdivs			(d8stg_fdivs),
	.div_sign_out			(div_sign_out),
	.div_exp_out			(div_exp_out[10:0]),
	.div_frac_out			(div_frac_out[51:0]),
	.mul_exc_out			(mul_exc_out[4:0]),
	.m6stg_fmul_dbl_dst		(m6stg_fmul_dbl_dst),
	.m6stg_fmuls			(m6stg_fmuls),
	.mul_sign_out			(mul_sign_out),
	.mul_exp_out			(mul_exp_out[10:0]),
	.mul_frac_out			(mul_frac_out[51:0]),
	.add_exc_out			(add_exc_out[4:0]),
	.a6stg_fcmpop			(a6stg_fcmpop),
	.add_cc_out			(add_cc_out[1:0]),
	.add_fcc_out			(add_fcc_out[1:0]),
	.a6stg_dbl_dst			(a6stg_dbl_dst),
	.a6stg_sng_dst			(a6stg_sng_dst),
	.a6stg_long_dst			(a6stg_long_dst),
	.a6stg_int_dst			(a6stg_int_dst),
	.add_sign_out			(add_sign_out),
	.add_exp_out			(add_exp_out[10:0]),
	.add_frac_out			(add_frac_out[63:0]),
	.rclk			(rclk),

	.fp_cpx_data_ca			(fp_cpx_data_ca[144:0]),

	.se                             (se),
        .si                             (scan_out_fpu_out_ctl),
        .so                             (so)
,
		.err_en(fpu_out_dp_err_en), // [ERROR]
		.err_ctrl(fpu_out_dp_err_ctrl) // [ERROR]
,
		.sh_clk(sh_clk),   // [SHADOW]
		.sh_rst(sh_rst),   // [SHADOW]
		.c_en(c_en),   // [SHADOW]
		.dump_en(ch_dump_en[0]),   // [SHADOW]
		.ch_out(inst_ch_out[0]),   // [SHADOW]
		.ch_out_done(inst_ch_out_done[0]),    // [SHADOW]
		.ch_out_vld(inst_ch_out_vld[0]) // [SHADOW]
);



	//[Sub Error Control Splitter Instantiations here]
	subErrCtrlSplitter #(.INW(4), .OUTW(1), .LOW(0), .HIGH(1)) sub_err_splitter_fpu_out_dp(
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.sub_err_en(fpu_out_dp_err_en),
		.sub_err_ctrl(fpu_out_dp_err_ctrl)
	);


	subErrCtrlSplitter #(.INW(4), .OUTW(3), .LOW(2), .HIGH(9)) sub_err_splitter_fpu_out_ctl(
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.sub_err_en(fpu_out_ctl_err_en),
		.sub_err_ctrl(fpu_out_ctl_err_ctrl)
	);



	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(0), .USE_DCLK(0), .CHAINS_IN(2), .CHAINS_OUT(1), .DISCRETE_DFFS(), .DFF_WIDTHS()) shadow_capture_fpu_out (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk(), 
		.din(),
		.dump_en(dump_en), 
		.chains_in(inst_ch_out), 
		.chains_in_vld(inst_ch_out_vld), 
		.chains_in_done(inst_ch_out_done), 
		.chain_dump_en(ch_dump_en), 
		.chains_out(ch_out), 
		.chains_out_vld(ch_out_vld), 
		.chains_out_done(ch_out_done)
	);
endmodule


