`timescale 1ns / 1ps  

//`define COUNTER_WIDTH 12 
/*	
 *	This means local DFF_BITS is limited to:
 *	(2^COUNTER_WIDTH + 2)* CHAINS_OUT - CHAINS_OUT^2 - 1 
 *	which, in most cases is overkill. Worst case scenario: 12 bits w/ 1 chain = 4096 DFF_BITS
 */
 
module shadow_capture (clk, rst, capture_en, dclk, din, dump_en, chains_in, chains_in_vld, chains_in_done, chain_dump_en, chains_out, chains_out_vld, chains_out_done);
	parameter DFF_BITS = 1;
	parameter USE_DCLK = 0;
	parameter CHAINS_IN = 1;
	parameter CHAINS_OUT = 1;
	parameter COUNTER_WIDTH = clog2(DFF_BITS) + 1;
	
	function integer clog2;
		input [31:0] depth;
		integer i;
		begin
			i = depth;		
			for(clog2 = 0; i > 0; clog2 = clog2 + 1)
				i = i >> 1;
		end
	endfunction
	
	localparam LOCAL_CHAIN_LENGTH = DFF_BITS / CHAINS_OUT;
	localparam EXTRA_BITS = DFF_BITS % CHAINS_OUT;
	localparam DFF_LIMIT = (DFF_BITS == 0? 0: DFF_BITS-1);
	localparam CIN_LIMIT = (CHAINS_IN == 0? 0: CHAINS_IN-1);
	

	input		clk;
	input		rst;
	input		capture_en;
	input		[(USE_DCLK ? DFF_BITS-1 : 0):0]	dclk; 	//Data clocks, if USE_DCLK is 0, tie dclk to clk
	input		[DFF_LIMIT:0] 	din; 								//Input from local level DFFs
	input		[CHAINS_OUT-1:0]	dump_en;						//Enable for local level dumping to parent
	input		[CIN_LIMIT:0] 	chains_in; 						//Chains to be merged, feeding from child shadow_capture modules
	input		[CIN_LIMIT:0]	chains_in_vld; 				//Chains in valid
	input 	[CIN_LIMIT:0]	chains_in_done; 					//Signals when a chain in is done
	output	[CIN_LIMIT:0]	chain_dump_en; 				//Signal telling which child chains to proceed dumping in
	output	[CHAINS_OUT-1:0] 	chains_out; 				//Dump to parent port
	output	[CHAINS_OUT-1:0]	chains_out_vld; 			//Chains out valid or not
	output	[CHAINS_OUT-1:0]	chains_out_done; 					//Signals the chain's contents are dumped to next level up
	
	wire dump_en_single = |dump_en;
	
	wire [DFF_LIMIT:0] asdin;	//Segmented switching data in for multiple chains
	wire [DFF_LIMIT:0] sdin;	//Switching local DFF data in
	wire [DFF_LIMIT:0] s_chains_out;
	
	wire [CHAINS_OUT-1:0] routed_child_chains; //Connection point between chains_out and the child chains that are currently dumping
	
	wire dump_done; //Signals when all contents are dumped to the next level up
	wire local_dump_done; //Tracks which chains have finished dumping local data
	
	wire [DFF_LIMIT:0] bits_captured;
	wire local_capture_done = DFF_BITS == 0? 1 : &bits_captured;
	
	/*CHAIN ARBITER INOUTS*/
	wire [CHAINS_OUT-1:0] cout_vld;
	wire [CHAINS_OUT-1:0] cout_done;
	wire [CIN_LIMIT:0] dump_cmd;
	
	wire capture_issued;
	wire next_capture_issued = (rst | dump_done)? 1'b0 : (capture_issued | capture_en);
	dffr_ns capture_issued_state(
		.clk(clk),
		.rst(rst),
		.din(next_capture_issued),
		.q(capture_issued)
	);
	
	genvar i;
//	/*Actual shadow DFFs*/
	generate 
		for(i = 0; i < DFF_BITS; i = i + 1)
			begin : SHADOW_DFFS
				dffc_dc #(1) s_dff(
					.clk(clk),
					.dclk(USE_DCLK? dclk[i] : clk),
					.rst(rst),
					.c_en(capture_en),
					.d_en(dump_en_single),
					.din(sdin[i]), 
					.q_ready(bits_captured[i]),
					.q(s_chains_out[i])
				);
			end
	endgenerate
//	generate	
//		if(DFF_BITS > 0)begin
//			dffc_dc #(DFF_BITS) s_dff(
//				.clk(clk),
//				.dclk(USE_DCLK? dclk : clk),
//				.rst(rst),
//				.c_en(capture_en),
//				.d_en(dump_en_single),
//				.din(sdin), 
//				.q_ready(bits_captured),
//				.q(s_chains_out)
//			);
//		end
//	endgenerate
		
	/*Internal routing of local DFF data to appropriate number of chains*/
	genvar j;
	generate for(j = 0; j < CHAINS_OUT; j = j + 1)
		begin : ROUTE_DFFS_TO_CHAIN
			if(DFF_BITS == 0 || LOCAL_CHAIN_LENGTH == 0)begin
				//No local DFFs to route, so the shadow module is just a chain arbiter
				assign asdin = 0;
			end else begin
				if(j != CHAINS_OUT - 1)begin
					//Shifts each chain independently
					assign asdin[((j + 1) * LOCAL_CHAIN_LENGTH) - 1 : j * LOCAL_CHAIN_LENGTH ] = {1'b0, s_chains_out[((j + 1) * LOCAL_CHAIN_LENGTH) - 1 : j * LOCAL_CHAIN_LENGTH + 1]};
				end else begin
					//Tacks on any extra bits to the last chain, making it longer than the others
					assign asdin[((j + 1) * LOCAL_CHAIN_LENGTH) - 1 + EXTRA_BITS : j * LOCAL_CHAIN_LENGTH] = {1'b0, s_chains_out[((j + 1) * LOCAL_CHAIN_LENGTH) - 1 + EXTRA_BITS : j * LOCAL_CHAIN_LENGTH + 1]};
				end
			end
			//When a chain is idle, it is assigned to take in child chains
			assign chains_out[j] = (~local_dump_done)? s_chains_out[j * LOCAL_CHAIN_LENGTH] : (dump_done)? 1'bz : routed_child_chains[j];
		end
	endgenerate
			
	/*Tracking of local dump states*/
	generate
		if(CHAINS_OUT > 1)begin
			/* For multiple chains out, the DFF bits are evenly distributed with any extras placed in the last chain */
			wire [COUNTER_WIDTH - 1:0] next_rld_state, curr_rld_state; //RLS = Regular local dump state (dump state of all other chains)
			wire [COUNTER_WIDTH - 1:0] next_eld_state, curr_eld_state; //ELD = Extra local dump state (dump state of chain with EXTRA_BITS)
			
			reg [COUNTER_WIDTH - 1:0] rld_state;
			reg [COUNTER_WIDTH - 1:0] eld_state;
			
			dffe_ns #(COUNTER_WIDTH) regular_local_dump_state(
				.clk(clk), 
				.en(dump_en_single | capture_en | rst),
				.din(next_rld_state), 
				.q(curr_rld_state)
			);
			dffe_ns #(COUNTER_WIDTH) extra_local_dump_state(
				.clk(clk),  
				.en(dump_en_single | capture_en | rst),
				.din(next_eld_state), 
				.q(curr_eld_state)
			);
			
			always @(*)begin
				rld_state <= (rst | capture_en)? LOCAL_CHAIN_LENGTH : curr_rld_state;
				eld_state <= (rst | capture_en)? LOCAL_CHAIN_LENGTH + EXTRA_BITS : curr_eld_state;
			end
			
			assign next_rld_state = (rst | capture_en)? LOCAL_CHAIN_LENGTH : ((curr_rld_state != 0)? rld_state - 1 : 0);
			assign next_eld_state = (rst | capture_en)? LOCAL_CHAIN_LENGTH + EXTRA_BITS : ((curr_eld_state != 0)? eld_state - 1 : 0);
			assign local_dump_done = (rst | capture_en)? 0 : (curr_rld_state == 0) && (curr_eld_state == 0);
			assign chains_out_vld = local_dump_done? (((CHAINS_IN > 0)? (&chains_in_done) : 1'b1)? 0 : cout_vld) :  {CHAINS_OUT{dump_en_single}} & {eld_state != 0, {CHAINS_OUT-1{rld_state != 0}}};
		end else begin
			// OPTIMIZATION: Remove local dump state if no local dffs exist
			wire 	[COUNTER_WIDTH - 1:0] 	curr_ld_state, next_ld_state;
			reg 	[COUNTER_WIDTH - 1:0] 	ld_state;
			
			dffe_ns #(COUNTER_WIDTH) local_dump_state(
				.clk(clk), 
				.en(rst | ((dump_en_single | capture_en) & local_capture_done)),
				.din(next_ld_state), 
				.q(curr_ld_state)
			);
			
			always @(*)
				ld_state <= (rst | capture_en)? LOCAL_CHAIN_LENGTH : curr_ld_state;
				
			assign next_ld_state = (rst | capture_en)? LOCAL_CHAIN_LENGTH : ((ld_state != 0)? ld_state - 1 : 0);
			assign local_dump_done = (rst | capture_en)? 0 : (curr_ld_state == 0);
			assign chains_out_vld = local_dump_done? (((CHAINS_IN > 0)? (&chains_in_done) : 1'b1)? 0 : cout_vld) : dump_en_single;
		end
	endgenerate
	
	/*Child dump enables*/
	chain_arbiter #(.CHAINS_IN(CHAINS_IN), .CHAINS_OUT(CHAINS_OUT)) c_arb(
		.clk(clk), 
		.rst(rst | capture_en), 
		.cin(chains_in), 
		.cin_vld(chains_in_vld),
		.cin_status(chains_in_done), 
		.local_done(&local_dump_done), 
		.cout(routed_child_chains), 
		.cout_vld(cout_vld),
		.cout_status(cout_done),
		.dump_cmd(dump_cmd)
	);
	
	assign chains_out_done = {CHAINS_OUT{local_dump_done}} & cout_done;
	assign chain_dump_en = dump_cmd & {CIN_LIMIT + 1{capture_issued}};
	assign sdin = (capture_en | ~local_capture_done)? din : (dump_en? asdin : sdin);
	assign dump_done = ((CHAINS_IN > 0)? (&chains_in_done) : 1'b1) && local_dump_done;
endmodule 