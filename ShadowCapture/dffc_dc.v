`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alejandro Argueta
// 
// Create Date:	22:33:23 05/04/2012 
// Design Name:	Capture DFF with Differential Clocking
// Module Name:	dffc_dc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A modified DFF used for capturing a data in one clock domain and dumping it off in another domain.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module dffc_dc(clk,	dclk, rst, c_en, d_en, din, q_ready, q);
	 
	parameter SIZE = 1;
    input clk;					 //System clock: Regular clock that all the shadow capture system operates on
    input dclk;				 //Data clock: Clock that host dffs run on, may or may not be different from system clock
	 input rst;					 //Reset
    input c_en; 				 //Capture enable: Data from host dffs on dclk should be shadowed on next dclk posclk
    input d_en; 			 	 //Dump enable: High if dumping and din is on system clock (typically chained from others)
    input [SIZE-1:0] din; 	 //Data in: Can be on either clk or dclk depending on if d_en is high or not
	 output q_ready; 			 //Q ready: High when native data has been captured, or if it's in dump mode 
    output reg [SIZE-1:0] q; //Data out: 

	wire op_clk;
	reg load_issued, load_complete;
	
	always @ (posedge op_clk)
		q[SIZE-1:0] <= rst ? 0 : (c_en ? din[SIZE-1:0] : (d_en ? din[SIZE-1:0] : q[SIZE-1:0]));
	
	always @ (posedge op_clk)
		load_issued <= rst ? 1'b0 : c_en;//(c_en ? 1'b1 : ~load_complete);
	
	always @ (posedge op_clk)
		load_complete <= (rst | c_en) ? 1'b0 : (load_issued | load_complete);
	
	assign op_clk = d_en? clk : ((load_issued && ~load_complete)? dclk : clk);
	assign q_ready = load_complete;
endmodule