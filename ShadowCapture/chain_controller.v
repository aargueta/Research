`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:41:05 05/18/2012 
// Design Name: 
// Module Name:    chain_controller 
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
module chain_controller(
    input clk,
    input rst,
	 
    input [CHAINS_IN-1:0] cin_ready,		// Chains in ready
	 input [CHAINS_IN-1:0] cin_done,			// Chains in done dumping
    input [CHAINS_IN-1:0] cin,				// Chains in
	 output [CHAINS_IN-1:0] cin_en,			// Chains in enable
	 
    input [CHAINS_OUT-1:0] cout_en,			// Chains out enable
    output reg [CHAINS_OUT-1:0] cout,		// Chains out
	 output [CHAINS_OUT-1:0] cout_status	// Chains out status
    );

	parameter CHAINS_IN = 1;
	parameter CHAINS_OUT = 1;
	parameter ADD_WIDTH = 8;
	
	wire [CHAINS_IN-1:0] stable_cin_ready;
	dffr_ns #(CHAINS_IN) cin_ready_latch(
		.clk(clk),
		.rst(rst),
		.din(cin_ready | stable_cin_ready),
		.q(stable_cin_ready)
	);
	
	wire [CHAINS_IN-1:0] stable_cin_done;
	dffr_ns #(CHAINS_IN) cin_done_latch(
		.clk(clk),
		.rst(rst),
		.din(cin_done| stable_cin_done),
		.q(stable_cin_done)
	);
	
	wire cin_block_done = cout_status[0] | &cin_done[cblk_slct * CHAINS_OUT];
	wire [ADD_WIDTH - 1:0] cblk_slct, next_cblk_slct;	// Chain block selection
	dffre_ns #(ADD_WIDTH) cin_selection(
		.clk(clk), 
		.rst(rst | cout_status[0]), 
		.en(cin_block_done), 
		.din(next_cblk_slct), 
		.q(cblk_slct)
	);
	assign next_cblk_slct = rst ? 0 : cblk_slct + 1;
	
	genvar i;
	generate for(i = 0; i < CHAINS_OUT; i = i + 1)
		begin : CHAIN_ALIGNMENT
			always @(*)begin
				if(cin_done[cblk_slct * CHAINS_OUT + i])begin
					if((cblk_slct + 1) * CHAINS_OUT + i > CHAINS_IN - 1)begin
						cout[i] = 1'bz; //Current chain done and next out of bounds
					end else begin
						cout[i] = cin[(cblk_slct + 1) * CHAINS_OUT + i]; //Next chain valid
					end
				end else if(cblk_slct * CHAINS_OUT + i > CHAINS_IN - 1)begin
					cout[i] = 1'bz; //Current chain does not exist
				end else begin
					cout[i] = cin[cblk_slct * CHAINS_OUT + i]; //Current chain valid
				end
			end
		end
	endgenerate	
	
	generate for(i = 0; i < CHAINS_IN; i = i + 1)
		begin : COMMAND_ASSIGNMENT
			assign cin_en[i] = stable_cin_ready ?(cblk_slct == (i / CHAINS_OUT)) : 0;
		end
	endgenerate
	
	generate for(i = 0; i < CHAINS_OUT; i = i + 1)
		begin : COUT_STATUS_ASSIGNMENT
			assign cout_status[i] = (&stable_cin_done);//(cblk_slct * CHAINS_OUT + i > CHAINS_IN)? 1 : cin_done[cblk_slct * CHAINS_OUT + i];
		end
	endgenerate
endmodule
