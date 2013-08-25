`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:28:25 02/01/2013
// Design Name:   fpu_add_input
// Module Name:   D:/Unrelated Junk/Stanford/Research/scanInjectTest/scanInjectTest/fpu_add_input_tb.v
// Project Name:  scanInjectTest
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fpu_add_input
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fpu_add_input_tb;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire [7:0] opcode;
	wire [1:0] round_mode;
	wire [4:0] req_id;
	wire [1:0] req_cc_id;
	wire [63:0] operand1;
	wire oprd1_50_0_neq_0;
	wire oprd1_53_32_neq_0;
	wire oprd1_exp_neq_0;
	wire oprd1_exp_neq_ff;
	wire [63:0] operand2;
	wire oprd2_50_0_neq_0;
	wire oprd2_53_32_neq_0;
	wire oprd2_exp_neq_0;
	wire oprd2_exp_neq_ff;
	wire add_req;

	// Instantiate the Unit Under Test (UUT)
	fpu_add_input uut (
		.clk(clk), 
		.rst(rst), 
		.opcode(opcode), 
		.round_mode(round_mode), 
		.req_id(req_id), 
		.req_cc_id(req_cc_id), 
		.operand1(operand1), 
		.oprd1_50_0_neq_0(oprd1_50_0_neq_0), 
		.oprd1_53_32_neq_0(oprd1_53_32_neq_0), 
		.oprd1_exp_neq_0(oprd1_exp_neq_0), 
		.oprd1_exp_neq_ff(oprd1_exp_neq_ff), 
		.operand2(operand2), 
		.oprd2_50_0_neq_0(oprd2_50_0_neq_0), 
		.oprd2_53_32_neq_0(oprd2_53_32_neq_0), 
		.oprd2_exp_neq_0(oprd2_exp_neq_0), 
		.oprd2_exp_neq_ff(oprd2_exp_neq_ff), 
		.add_req(add_req)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

