`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:22:52 05/25/2012 
// Design Name: 
// Module Name:    chain_interpreter_tm 
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
module chain_interpreter_tm(
    input clk,
    input rst,
	 input [CHAINS_IN-1:0] cin
    );
parameter CHAINS_IN = 1;
parameter CHAIN_DEPTH = 8;

	genvar i;
	generate for(i = 0; i < CHAINS_IN; i = i + 1)
			begin : REGISTERS
				wire [CHAIN_DEPTH-1:0] chain_reg;
				dffr_ns #(CHAIN_DEPTH) shift_register(
					.clk(clk),
					.rst(rst),
					.din({chain_reg[CHAIN_DEPTH-2:0], cin[i]}),
					.q(chain_reg)
				);
			end
		endgenerate
endmodule
