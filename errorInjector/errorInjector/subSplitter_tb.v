`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:49:50 11/25/2012
// Design Name:   subErrCtrlSplitter
// Module Name:   D:/Unrelated Junk/Stanford/Research/errorInjector/errorInjector/subSplitter_tb.v
// Project Name:  errorInjector
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: subErrCtrlSplitter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module subSplitter_tb;

	// Inputs
	reg [0:0] err_ctrl;

	// Outputs
	wire [0:0] sub_err_ctrl;

	// Instantiate the Unit Under Test (UUT)
	subErrCtrlSplitter uut (
		.err_ctrl(err_ctrl), 
		.sub_err_ctrl(sub_err_ctrl)
	);

	initial begin
		// Initialize Inputs
		err_ctrl = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

