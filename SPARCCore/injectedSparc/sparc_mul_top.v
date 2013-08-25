// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_mul_top.v
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
module sparc_mul_top(/*AUTOARG*/
   // Outputs
   mul_exu_ack, mul_spu_ack, mul_spu_shf_ack, mul_data_out, so, 
   // Inputs
   rclk, grst_l, arst_l, exu_mul_input_vld, exu_mul_rs1_data, exu_mul_rs2_data, 
   spu_mul_req_vld, spu_mul_acc, spu_mul_areg_shf, spu_mul_areg_rst, 
   spu_mul_op1_data, spu_mul_op2_data, spu_mul_mulres_lshft, si, se

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

	//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****
	input	sh_clk; // Shadow/data clock
	input	sh_rst; // Shadow/data reset
	input	c_en; // Capture enable
	input	[0:0]	dump_en; // Dump enable
	output	[0:0]	ch_out; // Chains out
	output	[0:0]	ch_out_vld; // Chains out Valid
	output	[0:0]	ch_out_done; // Chains done


//*****[SHADOW WIRE INSTANTIATIONS]*****
	wire inst_ch_out;
	wire inst_ch_out_vld;
	wire inst_ch_out_done;
	wire ch_dump_en;


input		rclk;
input		grst_l;			// system reset
input		arst_l;			// async reset
input		si;			// scan in
input		se;			// scan enablen
input		exu_mul_input_vld;	// EXU multipler op request
input [63:0]	exu_mul_rs1_data;	// EXU multipler Op1
input [63:0]	exu_mul_rs2_data;	// EXU multipler Op2
input		spu_mul_req_vld;	// SPU multipler op request
input		spu_mul_acc;		// MAC Op: ACCUM += op1 * op2 if spu_mul_acc=1
					// Bypass Op: Out = ACCUM * op1 if spu_mul_acc=0  
input		spu_mul_areg_shf;	// Shift >> 64 ACCUM register
input		spu_mul_areg_rst;	// Reset of ACCUM register (136-bit)
input [63:0]	spu_mul_op1_data;	// SPU multiplier Op1
input [63:0]	spu_mul_op2_data;	// SPU multiplier Op2

input spu_mul_mulres_lshft;

output		so;			// scan_out
output		mul_exu_ack;		// ack signal for EXU mul operation
output		mul_spu_ack;		// ack signal for SPU MAC and Bypass mul operation
output		mul_spu_shf_ack;	// acl signal for ACCUM >> 64 operation
output [63:0]	mul_data_out;		// Shared output data for both EXU and SPU

wire 		acc_imm, acc_actc2, acc_actc3, acc_actc5, acc_reg_enb;
wire 		acc_reg_rst, acc_reg_shf;
wire		byp_sel, byp_imm, spick, x2;
wire		c0_act;

wire 		rst_l;
wire		clk;

assign clk = rclk ;

dffrl_async	rstff	(
			.din	(grst_l),
			.clk	(clk),
			.rst_l	(arst_l),
			.q	(rst_l),
			.se	(se),
			.si	(),
			.so	()); 

sparc_mul_cntl	control	(
			.ecl_mul_req_vld  	(exu_mul_input_vld),
			.spu_mul_req_vld  	(spu_mul_req_vld),
			.spu_mul_acc	  	(spu_mul_acc),
			.spu_mul_areg_shf 	(spu_mul_areg_shf),
			.spu_mul_areg_rst 	(spu_mul_areg_rst),
			.spu_mul_mulres_lshft 	(spu_mul_mulres_lshft),
			.c0_act	  	  	(c0_act),
			.spick	  	  	(spick),
			.byp_sel	  	(byp_sel),
			.byp_imm	  	(byp_imm),
			.acc_imm 	  	(acc_imm),
			.acc_actc2 	  	(acc_actc2),
			.acc_actc3	  	(acc_actc3),
			.acc_actc5	  	(acc_actc5),
			.acc_reg_enb	  	(acc_reg_enb),
			.acc_reg_rst	  	(acc_reg_rst),
			.acc_reg_shf	  	(acc_reg_shf),
			.x2		  	(x2),
			.mul_ecl_ack	  	(mul_exu_ack),
			.mul_spu_ack	  	(mul_spu_ack),
			.mul_spu_shf_ack  	(mul_spu_shf_ack),
			.rst_l		  	(rst_l),
			.rclk 		  	(clk));

sparc_mul_dp	dpath 	(
			.ecl_mul_rs1_data 	(exu_mul_rs1_data),
			.ecl_mul_rs2_data 	(exu_mul_rs2_data),
			.spu_mul_op1_data 	(spu_mul_op1_data),
			.spu_mul_op2_data 	(spu_mul_op2_data),
			.valid		  	(c0_act),
			.spick		  	(spick),
			.byp_sel	  	(byp_sel),
			.byp_imm	  	(byp_imm),
			.acc_imm          	(acc_imm),
			.acc_actc2        	(acc_actc2),
                        .acc_actc3        	(acc_actc3),  
                        .acc_actc5        	(acc_actc5),  
                        .acc_reg_enb      	(acc_reg_enb),
                        .acc_reg_rst      	(acc_reg_rst),
                        .acc_reg_shf      	(acc_reg_shf),
			.x2		  	(x2),
			.mul_data_out	  	(mul_data_out),
			.rst_l		  	(rst_l),
			.si		  	(),
			.so		  	(),
			.se		  	(se),
			.rclk		  	(clk),
,
		.sh_clk(sh_clk),   // [SHADOW]
		.sh_rst(sh_rst),   // [SHADOW]
		.c_en(c_en),   // [SHADOW]
		.dump_en(ch_dump_en),   // [SHADOW]
		.ch_out(inst_ch_out),   // [SHADOW]
		.ch_out_done(inst_ch_out_done),    // [SHADOW]
		.ch_out_vld(inst_ch_out_vld) // [SHADOW]
);


	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(1), .USE_DCLK(1), .CHAINS_IN(1), .CHAINS_OUT(1), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd1})) shadow_capture_sparc_mul_top (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({clk}), 
		.din({rst_l}),
		.dump_en(dump_en), 
		.chains_in(inst_ch_out), 
		.chains_in_vld(inst_ch_out_vld), 
		.chains_in_done(inst_ch_out_done), 
		.chain_dump_en(ch_dump_en), 
		.chains_out(ch_out), 
		.chains_out_vld(ch_out_vld), 
		.chains_out_done(ch_out_done)
	);
endmodule // sparc_mul_top
