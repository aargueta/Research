`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:33:37 04/28/2012 
// Design Name: 
// Module Name:    chain_arbiter 
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
`define ADD_WIDTH 8
module chain_arbiter(clk, rst, cin, cin_status, cin_vld, local_done, cout, cout_status, cout_vld, dump_cmd);

	parameter CHAINS_IN = 1;
	parameter CHAINS_OUT = 1;
	
	localparam CIN_LIMIT = (CHAINS_IN == 0? 0: CHAINS_IN-1);
	localparam CHAIN_BLOCKS = CHAINS_IN /CHAINS_OUT + ((CHAINS_IN % CHAINS_OUT > 0)? 1 : 0);

	input 	clk;
	input 	rst;
	input		[CIN_LIMIT:0]	cin_status;
	input 	[CIN_LIMIT:0]	cin;
	input		[CIN_LIMIT:0] cin_vld;
	input 	local_done;
	output reg	[CHAINS_OUT - 1:0]	cout;
	output reg	[CHAINS_OUT - 1:0]	cout_status;
	output reg	[CHAINS_OUT - 1:0] cout_vld;
	output	[CIN_LIMIT:0]	dump_cmd;
	
	wire [`ADD_WIDTH - 1:0] cblk_slct, next_cblk_slct;//Chain block selection
	wire cblk_slct_oor = (cblk_slct * CHAINS_OUT) > CHAINS_IN - 1; //Chain block selection Out Of Range
	wire [((CHAINS_IN == 0)? 0 : CHAIN_BLOCKS - 1):0] block_status; //Completion status of each chain block
	wire cin_block_done = cblk_slct_oor? 0 : block_status[cblk_slct]; // CHANGED: cblk_slct_oor to cblk_slct TODO:Verify functionality
	
	genvar i;
	generate 
		if(CHAINS_IN == 0)begin
			assign block_status[0] = 1'b1;
		end else begin
			for(i = 0; i < CHAIN_BLOCKS; i = i + 1)begin: CHAIN_BLOCK_TRACKING
				if((i + 1)*CHAINS_OUT < CIN_LIMIT)begin
					assign block_status[i] = &cin_status[(i + 1)*CHAINS_OUT : i * CHAINS_OUT];
				end else begin
					assign block_status[i] = &cin_status[CIN_LIMIT : i * CHAINS_OUT];
				end
			end
		end
	endgenerate

	
	
	dffre_ns #(/*.NO_ERR(1),*/ .SIZE(`ADD_WIDTH)) cin_selection(
		.clk(clk), 
		.rst(rst), 
		//.err_en(1'b0),
		.en(cin_block_done), 
		.din(next_cblk_slct), 
		.q(cblk_slct)
	);
	assign next_cblk_slct = rst? 0 : cblk_slct + 1;
	
	generate
		for(i = 0; i < CHAINS_OUT; i = i + 1) begin : CHAIN_ALIGNMENT
			always @(*)begin
				if((CHAINS_IN == 0) )begin
					cout[i] = 1'b0; //No chains in
					cout_vld[i] = 1'b0;
					cout_status[i] = 1'b1;
				end else if(cblk_slct * CHAINS_OUT + i > CHAINS_IN - 1)begin
					cout[i] = 1'b0; //Current chain does not exist
					cout_vld[i]=1'b0;
					cout_status[i] = 1'b1;
				end else if((cin_status[cblk_slct * CHAINS_OUT + i]))begin
					cout[i] = 1'b0; //Current chain done
					cout_vld[i] = 1'b0;
					cout_status[i] = 1'b1;
				end else begin
					cout[i] = cin[cblk_slct * CHAINS_OUT + i]; //Current chain valid
					cout_vld[i] = cin_vld[cblk_slct * CHAINS_OUT + i];
					cout_status[i] = cin_status[cblk_slct * CHAINS_OUT + i];
				end
			end
		end
	endgenerate
	
	generate for(i = 0; i < CHAINS_IN; i = i + 1)
		begin : COMMAND_ASSIGNMENT
			assign dump_cmd[i] = local_done? (cblk_slct == (i / CHAINS_OUT)) : 0;
		end
	endgenerate
endmodule
