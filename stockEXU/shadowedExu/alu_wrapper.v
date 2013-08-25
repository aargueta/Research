`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:12:54 10/03/2012
// Design Name:   sparc_exu_alu
// Module Name:   D:/Unrelated Junk/Stanford/Research/stockEXU/shadowedExu/alu_wrapper.v
// Project Name:  shadowedExu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: sparc_exu_alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu_wrapper(rclk, ch_out);

	// Inputs
	input rclk;
	reg se;
	reg si;
	reg [63:0] byp_alu_rs1_data_e;
	reg [63:0] byp_alu_rs2_data_e_l;
	reg [63:0] byp_alu_rs3_data_e;
	reg [63:0] byp_alu_rcc_data_e;
	reg ecl_alu_cin_e;
	reg ifu_exu_invert_d;
	reg ecl_alu_log_sel_and_e;
	reg ecl_alu_log_sel_or_e;
	reg ecl_alu_log_sel_xor_e;
	reg ecl_alu_log_sel_move_e;
	reg ecl_alu_out_sel_sum_e_l;
	reg ecl_alu_out_sel_rs3_e_l;
	reg ecl_alu_out_sel_shift_e_l;
	reg ecl_alu_out_sel_logic_e_l;
	reg [63:0] shft_alu_shift_out_e;
	reg ecl_alu_sethi_inst_e;
	reg ifu_lsu_casa_e;
	reg sh_clk;
	reg sh_rst;
	reg c_en;
	reg [1:0] dump_en;

	// Outputs
	wire so;
	wire [63:0] alu_byp_rd_data_e;
	wire [47:0] exu_ifu_brpc_e;
	wire [47:0] exu_lsu_ldst_va_e;
	wire [10:3] exu_lsu_early_va_e;
	wire [7:0] exu_mmu_early_va_e;
	wire alu_ecl_add_n64_e;
	wire alu_ecl_add_n32_e;
	wire alu_ecl_log_n64_e;
	wire alu_ecl_log_n32_e;
	wire alu_ecl_zhigh_e;
	wire alu_ecl_zlow_e;
	wire exu_ifu_regz_e;
	wire exu_ifu_regn_e;
	wire alu_ecl_adderin2_63_e;
	wire alu_ecl_adderin2_31_e;
	wire alu_ecl_adder_out_63_e;
	wire alu_ecl_cout32_e;
	wire alu_ecl_cout64_e_l;
	wire alu_ecl_mem_addr_invalid_e_l;
	output [1:0] ch_out;
	wire [1:0] ch_out_vld;
	wire [1:0] ch_out_done;

	// Instantiate the Unit Under Test (UUT)
	sparc_exu_alu uut (
		.so(so), 
		.alu_byp_rd_data_e(alu_byp_rd_data_e), 
		.exu_ifu_brpc_e(exu_ifu_brpc_e), 
		.exu_lsu_ldst_va_e(exu_lsu_ldst_va_e), 
		.exu_lsu_early_va_e(exu_lsu_early_va_e), 
		.exu_mmu_early_va_e(exu_mmu_early_va_e), 
		.alu_ecl_add_n64_e(alu_ecl_add_n64_e), 
		.alu_ecl_add_n32_e(alu_ecl_add_n32_e), 
		.alu_ecl_log_n64_e(alu_ecl_log_n64_e), 
		.alu_ecl_log_n32_e(alu_ecl_log_n32_e), 
		.alu_ecl_zhigh_e(alu_ecl_zhigh_e), 
		.alu_ecl_zlow_e(alu_ecl_zlow_e), 
		.exu_ifu_regz_e(exu_ifu_regz_e), 
		.exu_ifu_regn_e(exu_ifu_regn_e), 
		.alu_ecl_adderin2_63_e(alu_ecl_adderin2_63_e), 
		.alu_ecl_adderin2_31_e(alu_ecl_adderin2_31_e), 
		.alu_ecl_adder_out_63_e(alu_ecl_adder_out_63_e), 
		.alu_ecl_cout32_e(alu_ecl_cout32_e), 
		.alu_ecl_cout64_e_l(alu_ecl_cout64_e_l), 
		.alu_ecl_mem_addr_invalid_e_l(alu_ecl_mem_addr_invalid_e_l), 
		.rclk(rclk), 
		.se(se), 
		.si(si), 
		.byp_alu_rs1_data_e(byp_alu_rs1_data_e), 
		.byp_alu_rs2_data_e_l(byp_alu_rs2_data_e_l), 
		.byp_alu_rs3_data_e(byp_alu_rs3_data_e), 
		.byp_alu_rcc_data_e(byp_alu_rcc_data_e), 
		.ecl_alu_cin_e(ecl_alu_cin_e), 
		.ifu_exu_invert_d(ifu_exu_invert_d), 
		.ecl_alu_log_sel_and_e(ecl_alu_log_sel_and_e), 
		.ecl_alu_log_sel_or_e(ecl_alu_log_sel_or_e), 
		.ecl_alu_log_sel_xor_e(ecl_alu_log_sel_xor_e), 
		.ecl_alu_log_sel_move_e(ecl_alu_log_sel_move_e), 
		.ecl_alu_out_sel_sum_e_l(ecl_alu_out_sel_sum_e_l), 
		.ecl_alu_out_sel_rs3_e_l(ecl_alu_out_sel_rs3_e_l), 
		.ecl_alu_out_sel_shift_e_l(ecl_alu_out_sel_shift_e_l), 
		.ecl_alu_out_sel_logic_e_l(ecl_alu_out_sel_logic_e_l), 
		.shft_alu_shift_out_e(shft_alu_shift_out_e), 
		.ecl_alu_sethi_inst_e(ecl_alu_sethi_inst_e), 
		.ifu_lsu_casa_e(ifu_lsu_casa_e), 
		.sh_clk(sh_clk), 
		.sh_rst(sh_rst), 
		.c_en(c_en), 
		.dump_en(dump_en), 
		.ch_out(ch_out), 
		.ch_out_vld(ch_out_vld), 
		.ch_out_done(ch_out_done)
	);
	always @(*)begin
		se = rclk;
		si = rclk;
		byp_alu_rs1_data_e = {64{rclk}};
		byp_alu_rs2_data_e_l = {64{rclk}};
		byp_alu_rs3_data_e = {64{rclk}};
		byp_alu_rcc_data_e = {64{rclk}};
		ecl_alu_cin_e = rclk;
		ifu_exu_invert_d = rclk;
		ecl_alu_log_sel_and_e = rclk;
		ecl_alu_log_sel_or_e = rclk;
		ecl_alu_log_sel_xor_e = rclk;
		ecl_alu_log_sel_move_e = rclk;
		ecl_alu_out_sel_sum_e_l = rclk;
		ecl_alu_out_sel_rs3_e_l = rclk;
		ecl_alu_out_sel_shift_e_l = rclk;
		ecl_alu_out_sel_logic_e_l = rclk;
		shft_alu_shift_out_e = {64{rclk}};
		ecl_alu_sethi_inst_e = rclk;
		ifu_lsu_casa_e = rclk;
		sh_clk = rclk;
		sh_rst = rclk;
		c_en = rclk;
		dump_en = {2{rclk}};

	end
      
endmodule

