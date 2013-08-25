`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:17:48 02/01/2013 
// Design Name: 
// Module Name:    top_fpu_add 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define NO_SCAN
module top_fpu_add(
    input clk,
    input up_button,
    input [8:1] sw,
    output [3:0] leds_l,
    output [3:0] leds_r,
    output serial1_tx
    );
	 
	 	 
	wire [7:0] inject_errors = sw;
	wire rst = up_button;
	
	// Shadowing/Error Control Inputs
	wire err_en;
	wire [6:0] err_ctrl;
	wire c_en;
	wire [7:0] dump_en;
	wire dump_done;
	
	wire [7:0] ch_out;
	wire [7:0] ch_out_vld;
	wire [7:0] ch_out_done;
	 
	wire [7:0] tx_data;
	wire tx_en;
	wire serial_busy;
	
	assign leds_l = {dump_done, |dump_en, serial_busy, serial1_tx};
	assign leds_r = {err_en, tx_data[2:0]};
	
	fpu_add_demo_ctrl demo_ctrl(
		.clk(clk),
		.rst(rst),
		.inj_err(inject_errors),
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.ch_out(ch_out),
		.ch_out_vld(ch_out_vld),
		.ch_out_done(ch_out_done),
		.serial_busy(serial_busy),
		.c_en(c_en),
		.dump_en(dump_en),
		.serial_en(tx_en),
		.serial_tx(tx_data),
		.demo_done(dump_done)
	);
	
	
	/*uart_tx serial(
		.uart_busy(serial_busy),   // High means UART is transmitting
		.uart_tx(serial1_tx),     // UART transmit wire
		// Inputs
		.tx_en(tx_en),   // Raise to transmit byte
		.tx_data(tx_data),  // 8-bit data
		.clk(clk),   // System clock, 68 MHz
		.rst(rst)    // System reset
	);*/
	
	async_transmitter #(.ClkFrequency(69118054), .Baud(115200)) serial (
		.clk(clk), 
		.TxD_start(tx_en), 
		.TxD_data(tx_data), 
		.TxD(serial1_tx), 
		.TxD_busy(serial_busy)
	);


	// FPU_ADD Inputs
	wire [7:0] inq_op;
	wire [1:0] inq_rnd_mode;
	wire [4:0] inq_id;
	wire [1:0] inq_fcc;
	wire [63:0] inq_in1;
	wire inq_in1_50_0_neq_0;
	wire inq_in1_53_32_neq_0;
	wire inq_in1_exp_eq_0;
	wire inq_in1_exp_neq_ffs;
	wire [63:0] inq_in2;
	wire inq_in2_50_0_neq_0;
	wire inq_in2_53_32_neq_0;
	wire inq_in2_exp_eq_0;
	wire inq_in2_exp_neq_ffs;
	wire inq_add;
	wire add_dest_rdy = 1'b1;
	wire fadd_clken_l = 1'b0;
	wire arst_l = ~rst;
	wire grst_l = ~rst;
	wire rclk = clk;
	wire se_add_exp;
	wire se_add_frac;
	wire si;
	
	// Instantiate the Unit Under Test (UUT)
	fpu_add_input fpu_add_input (
		.clk(clk), 
		.rst(rst), 
		.opcode(inq_op), 
		.round_mode(inq_rnd_mode), 
		.req_id(inq_id), 
		.req_cc_id(inq_fcc), 
		.operand1(inq_in1), 
		.oprd1_50_0_neq_0(inq_in1_50_0_neq_0), 
		.oprd1_53_32_neq_0(inq_in1_53_32_neq_0), 
		.oprd1_exp_neq_0(inq_in1_exp_eq_0), 
		.oprd1_exp_neq_ff(inq_in1_exp_neq_ffs), 
		.operand2(inq_in2), 
		.oprd2_50_0_neq_0(inq_in2_50_0_neq_0), 
		.oprd2_53_32_neq_0(inq_in2_53_32_neq_0), 
		.oprd2_exp_neq_0(inq_in2_exp_eq_0), 
		.oprd2_exp_neq_ff(inq_in2_exp_neq_ffs), 
		.add_req(inq_add)
	);

	// FPU_ADD Outputs
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

	// FPU ADD
	fpu_add fpu_add (
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
		.sh_clk(clk), 
		.sh_rst(rst), 
		.c_en(c_en), 
		.dump_en(dump_en), 
		.ch_out(ch_out), 
		.ch_out_vld(ch_out_vld), 
		.ch_out_done(ch_out_done)
	);
endmodule
