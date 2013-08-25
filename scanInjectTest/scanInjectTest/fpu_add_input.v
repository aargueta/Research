`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:53:01 02/01/2013 
// Design Name: 
// Module Name:    fpu_add_input 
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
module fpu_add_input(
    input clk,
    input rst,
    output reg [7:0] opcode,
    output reg [1:0] round_mode,
    output reg [4:0] req_id,		// CPU & Thread ID, arbitrary
    output reg [1:0] req_cc_id, // Request Condition Code ID, 2'b00
    output reg [63:0] operand1,
    output oprd1_50_0_neq_0,
    output oprd1_53_32_neq_0,
    output oprd1_exp_neq_0,
    output oprd1_exp_neq_ff,
    output reg [63:0] operand2,
    output oprd2_50_0_neq_0,
    output oprd2_53_32_neq_0,
    output oprd2_exp_neq_0,
    output oprd2_exp_neq_ff,
    output reg add_req
    );
	
	assign oprd1_50_0_neq_0 = |operand1[50:0];
	assign oprd1_53_32_neq_0 = |operand1[53:32];
	assign oprd1_exp_neq_0 = (!((|operand1[62:55]) || (opcode[1] && (|operand1[54:52]))));
	assign oprd1_exp_neq_ff =  (!((&operand1[62:55]) && (opcode[0] || (&operand1[54:52]))));
	
	assign oprd2_50_0_neq_0 = |operand2[50:0];
	assign oprd2_53_32_neq_0 = |operand2[53:32];
	assign oprd2_exp_neq_0 = (!((|operand2[62:55]) || (opcode[1] && (|operand2[54:52]))));
	assign oprd2_exp_neq_ff =  (!((&operand2[62:55]) && (opcode[0] || (&operand2[54:52]))));
	
	wire [2:0] input_state;
	reg [2:0] next_input_state;
	
	dffr_ns #(3) state(
		.clk(clk),
		.rst(rst),
		.err_en(1'b0),
		.din(next_input_state),
		.q(input_state)
	);
	
	always@(posedge clk)begin
		next_input_state = rst? 3'd0 : input_state + 1;
		case(input_state)
			1:	begin
				opcode = 8'b01000010; 					// FADDd
				round_mode = 2'b00;
				req_id =  5'd1;
				req_cc_id = 2'b00;
				operand1 = 64'h3FE8000000000000; 	// Float #1 = .75
				operand2 = 64'h3FD5555555555555; 	// Float #2 = 1/3
				add_req = 1'b1;
				end
			3:	begin
				opcode = 8'b01000010; 					// FADDd
				round_mode = 2'b00;
				req_id =  5'd3;
				req_cc_id = 2'b00;
				operand1 = 64'h40F86A1000000000; 	// Float #1 = 100001
				operand2 = 64'h4197D78404000000; 	// Float #2 = 100000001 
				add_req = 1'b1;
				end
			5:	begin
				opcode = 8'b01000010; 					// FADDd
				round_mode = 2'b00;
				req_id =  5'd5;
				req_cc_id = 2'b00;
				operand1 = 64'hC0B62E1F97247454; 	// Float #1 = -5678.1234 
				operand2 = 64'h40934A456D5CFAAD; 	// Float #2 = 1234.5678 
				add_req = 1'b1;
				end
			7:	begin
				opcode = 8'b01000010; 					// FADDd
				round_mode = 2'b00;
				req_id =  5'd7;
				req_cc_id = 2'b00;
				operand1 = 64'h547D42AEA2879F2E; 	// Float #1 = 1e99
				operand2 = 64'hD4E6DC186EF9F45C; 	// Float #2 = -1e101 
				add_req = 1'b1;
				end
			default:begin
				opcode = 8'b01000010; 					// FADDd
				round_mode = 2'b00;
				req_id =  5'd0;
				req_cc_id = 2'b00;
				operand1 = 64'h0000000000000000;
				operand2 = 64'h0000000000000000;
				add_req = 1'b0;				
			end
		endcase
	end

endmodule
