`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:22:12 11/25/2012 
// Design Name: 
// Module Name:    lclErrCtrlSplitter 
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
module lclErrCtrlSplitter(err_en, err_ctrl, lcl_err);
	 
	 parameter INW = 1;
	 parameter LCL = 1;
	 
    input err_en;
    input [INW-1 : 0] err_ctrl;
    output [LCL-1 : 0] lcl_err;

	genvar i;
	generate
		for(i = 0; i < LCL; i = i + 1)
		begin : ONEHOT
			assign lcl_err[i] = (err_ctrl == i)? err_en : 1'b0;
		end
	endgenerate
endmodule
