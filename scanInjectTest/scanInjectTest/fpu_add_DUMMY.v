// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: fpu_add.v
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
//	FPU add pipe.
//
///////////////////////////////////////////////////////////////////////////////

module fpu_add_DUMMY (
	inq_op,
	inq_rnd_mode,
	inq_id,
	inq_fcc,
	inq_in1,
	inq_in1_50_0_neq_0,
	inq_in1_53_32_neq_0,
	inq_in1_exp_eq_0,
	inq_in1_exp_neq_ffs,
	inq_in2,
	inq_in2_50_0_neq_0,
	inq_in2_53_32_neq_0,
	inq_in2_exp_eq_0,
	inq_in2_exp_neq_ffs,
	inq_add,
	add_dest_rdy,
	fadd_clken_l,
	arst_l,
	grst_l,
	rclk,

	add_pipe_active,	
	a1stg_step,
	a6stg_fadd_in,
	add_id_out_in,
	a6stg_fcmpop,
	add_exc_out,
	a6stg_dbl_dst,
	a6stg_sng_dst,
	a6stg_long_dst,
	a6stg_int_dst,
	add_sign_out,
	add_exp_out,
	add_frac_out,
	add_cc_out,
	add_fcc_out,

	se_add_exp,
	se_add_frac,
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
	input	[7:0]	dump_en; // Dump enable
	output	[7:0]	ch_out; // Chains out
	output	[7:0]	ch_out_vld; // Chains out Valid
	output	[7:0]	ch_out_done; // Chains done

	//*****[ERROR WIRE INSTANTIATIONS]******
	wire fpu_add_ctl_err_en;
	wire [6:0] fpu_add_ctl_err_ctrl;
	wire fpu_add_exp_dp_err_en;
	wire [4:0] fpu_add_exp_dp_err_ctrl;
	wire fpu_add_frac_dp_err_en;
	wire [4:0] fpu_add_frac_dp_err_ctrl;

//*****[SHADOW WIRE INSTANTIATIONS]*****
	reg [9:0] inst_ch_out;
	reg [9:0] inst_ch_out_vld;
	reg [9:0] inst_ch_out_done;
	wire [9:0] ch_dump_en;



input [7:0]	inq_op;			// request opcode to op pipes
input [1:0]	inq_rnd_mode;		// request rounding mode to op pipes
input [4:0]	inq_id;			// request ID to the operation pipes
input [1:0]	inq_fcc;		// request cc ID to op pipes
input [63:0]	inq_in1;		// request operand 1 to op pipes
input		inq_in1_50_0_neq_0;	// request operand 1[50:0]!=0
input		inq_in1_53_32_neq_0;	// request operand 1[53:32]!=0
input		inq_in1_exp_eq_0;	// request operand 1 exp==0
input		inq_in1_exp_neq_ffs;	// request operand 1 exp!=0xff's
input [63:0]	inq_in2;		// request operand 2 to op pipes
input		inq_in2_50_0_neq_0;	// request operand 2[50:0]!=0
input		inq_in2_53_32_neq_0;	// request operand 2[53:32]!=0
input		inq_in2_exp_eq_0;	// request operand 2 exp==0
input		inq_in2_exp_neq_ffs;	// request operand 2 exp!=0xff's
input		inq_add;		// add pipe request
input		add_dest_rdy;		// add result req accepted for CPX
input		fadd_clken_l;           // fadd clock enable
input		arst_l;			// global async. reset- asserted low
input		grst_l;			// global sync. reset- asserted low
input		rclk;			// global clock

output		add_pipe_active;        // add pipe is executing a valid instr
output		a1stg_step;		// add pipe load
output		a6stg_fadd_in;		// add pipe output request next cycle
output [9:0]    add_id_out_in;		// add pipe output ID next cycle
output		a6stg_fcmpop;		// compare- add 6 stage
output [4:0]	add_exc_out;		// add pipe result- exception flags
output		a6stg_dbl_dst;		// float double result- add 6 stage
output		a6stg_sng_dst;		// float single result- add 6 stage
output		a6stg_long_dst;		// 64bit integer result- add 6 stage
output		a6stg_int_dst;		// 32bit integer result- add 6 stage
output		add_sign_out;		// add sign output
output [10:0]	add_exp_out;		// add exponent output
output [63:0]	add_frac_out;		// add fraction output
output [1:0]	add_cc_out;		// add pipe result- condition
output [1:0]	add_fcc_out;		// add pipe input fcc passed through

input           se_add_exp;     // scan_enable for add_exp_dp, add_ctl
input           se_add_frac;    // scan_enable for add_frac_dp
input           si;                     // scan in
output          so;                     // scan out

	wire [2:0] state;
	wire [2:0] next_state = state + 1;
	dffr_ns #(3) dummy_state(
		.clk(rclk),
		.rst(~grst_l),
		.err_en(1'b0),
		.din(next_state),
		.q(state)	
	);
	
	always @(posedge rclk)begin
		case(state)
			0:begin
				inst_ch_out = 10'h3FF;
				inst_ch_out_vld = 10'h3FF;
				inst_ch_out_done = 10'h000;
			end
			1:begin
				inst_ch_out = 10'h2EF;
				inst_ch_out_vld = 10'h3FF;
				inst_ch_out_done = 10'h000;
			end
			2:begin
				inst_ch_out = 10'h2DE;
				inst_ch_out_vld = 10'h3FF;
				inst_ch_out_done = 10'h000;
			end
			3:begin
				inst_ch_out = 10'h1DD;
				inst_ch_out_vld = 10'h3FF;
				inst_ch_out_done = 10'h000;
			end
			4:begin
				inst_ch_out = 10'h0CD;
				inst_ch_out_vld = 10'h3FF;
				inst_ch_out_done = 10'h000;
			end
			5:begin
				inst_ch_out = 10'hABC;
				inst_ch_out_vld = 10'h3FF;
				inst_ch_out_done = 10'h000;
			end
			6:begin
				inst_ch_out = 10'hDEF;
				inst_ch_out_vld = 10'h3FF;
				inst_ch_out_done = 10'h000;
			end
			7:begin
				inst_ch_out = 10'h000;
				inst_ch_out_vld = 10'h3FF;
				inst_ch_out_done = 10'h111;
			end
		endcase
	end

	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(0), .USE_DCLK(0), .CHAINS_IN(10), .CHAINS_OUT(8), .DISCRETE_DFFS(), .DFF_WIDTHS()) shadow_capture_fpu_add (
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


