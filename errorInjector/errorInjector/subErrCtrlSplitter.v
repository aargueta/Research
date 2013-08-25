`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:51:36 11/25/2012 
// Design Name: 
// Module Name:    localErrorInjectionControl 
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
module subErrCtrlSplitter(err_en, err_ctrl, sub_err_en, sub_err_ctrl);
	parameter INW =  1; // Input bitwidth
	parameter OUTW = 1; // Output bitwidth
	parameter LOW = 0; // Lower limit for the submodule's error control
	parameter HIGH = 1; // Upper limit for the submodule's error control

	input err_en;
	input [INW-1 : 0] err_ctrl;
	output sub_err_en;
	output [OUTW-1 : 0]  sub_err_ctrl;
	
	assign sub_err_en = ((err_ctrl > HIGH) || (err_ctrl < LOW))? 1'b0 : err_en;
	assign sub_err_ctrl = err_ctrl - LOW;
 
endmodule
