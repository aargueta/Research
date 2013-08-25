`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:31:00 05/17/2012 
// Design Name: 
// Module Name:    shadow_chain 
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
module shadow_chain(
	 input clk,					// System clock
    input rst,					// System reset
    input c_en,				// Capture enable
	 input d_en,				// Data dump enable
    input d_clk,				// Data Clock
    input [SIZE-1:0] d_in,	// Data in
    output reg d_out,		// Data out
	 output reg d_ready,		// Data ready
	 output reg d_done		// Data dump done
    );

	parameter SIZE = 1;
	parameter COUNT_WIDTH = 16;
	
	wire s_clk = d_en? clk : d_clk;		// Shadow clock, switches between system clock and native data clock
	
	wire [SIZE-1:0] d_chain;
	
	genvar i;
	generate for(i = 0; i < SIZE; i = i + 1)
		begin : SHADOW_DFFS
			if(SIZE == 1 || i == 0)begin
				dffre_ns s_dff1(
					.clk(s_clk),
					.rst(rst),
					.en(c_en | d_en),
					.din(d_in[0]), 
					.q(d_chain[0])
				);
			end else begin
				dffre_ns s_dff(
					.clk(s_clk),
					.rst(rst),
					.en(c_en | d_en),
					.din(d_en ? d_chain[i - 1] : d_in[i]), 
					.q(d_chain[i])
				);
			end
		end
	endgenerate
	
	wire[COUNT_WIDTH-1:0] curr_dump_state;
	reg [COUNT_WIDTH-1:0] next_dump_state;
	dffre_ns #(COUNT_WIDTH) dump_state(
		.clk(clk),
		.rst(rst),
		.en(d_en | rst),
		.din(next_dump_state),
		.q(curr_dump_state)
	);
	
	always @(*)begin
		next_dump_state = (rst | c_en | ~d_en)? 0 : curr_dump_state + 1;
		d_done = rst? 0 : (curr_dump_state == SIZE);
	end
	
	reg c_cmd_issued;
	always @(negedge d_clk)begin
		c_cmd_issued = (rst | d_ready)? 0 : c_en;
	end
	
	always @(negedge clk)begin
		d_out <= d_chain[SIZE-1];
		d_ready = (rst | d_ready)? 0 : c_cmd_issued;
	end
	
endmodule
