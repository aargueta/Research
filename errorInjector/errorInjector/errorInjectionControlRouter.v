`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alejandro Argueta
// 
// Create Date:    23:06:36 11/21/2012 
// Design Name: 
// Module Name:    errorInjectionControlRouter 
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
module errorInjectionControlRouter(
    input err_en,
    input [15:0] err_ctrl,
    output reg [LCL-1:0] lcl_err
    );

	parameter LWB = 0;	// Lower bound
	parameter UPB = 1;	// Upper bound
	parameter LCL = 1;	// Number of local dffs

	wire inBounds = (err_ctrl <= UPB) | (err_ctrl >= LWB);
	wire [15:0] shft_err_ctrl = err_ctrl - LWB;
	
	genvar i;
	generate
		for(i = 0; i < LCL; i = i + 1)
		begin : ONEHOT
			always @(*)
				lcl_err[i] = (shft_err_ctrl == i)? err_en : 0;
		end
	endgenerate
	
	
	
	// RESUME HERE:
	// 1. Detect if error control ID is within bounds
	// 2. Subtract offset so that first local DFF has an ID of 0
	//	3. One-Hot the local IDs and rout them to the locals
	// 4. Pass down the shrunken(?) error control ID values (HOW DO WE SHRINK THE BINARY REPRESENTATION, DONE IN PARSER?)
	
	

endmodule
