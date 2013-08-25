`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:15:26 11/21/2012
// Design Name:   errorInjectionControlRouter
// Module Name:   D:/Unrelated Junk/Stanford/Research/errorInjector/errorInjector/errorInjectionControlRouter_tb.v
// Project Name:  errorInjector
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: errorInjectionControlRouter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module errorInjectionControlRouter_tb;

	// Inputs
	reg error_en;
	reg [15:0] error_control;

	// Outputs
	wire [17:0] local_error;

	// Instantiate the Unit Under Test (UUT)
	errorInjectionControlRouter #(.UPB(4), .LWB(0), .LCL(5)) uut1 (
		.err_en(error_en), 
		.err_ctrl(error_control), 
		.lcl_err(local_error[4:0])
	);

	errorInjectionControlRouter #(.UPB(10), .LWB(5), .LCL(6)) uut2 (
		.err_en(error_en), 
		.err_ctrl(error_control), 
		.lcl_err(local_error[10:5])
	);
	
	errorInjectionControlRouter #(.UPB(17), .LWB(11), .LCL(7)) uut3 (
		.err_en(error_en), 
		.err_ctrl(error_control), 
		.lcl_err(local_error[17:11])
	);
	
	initial begin
		// Initialize Inputs
		error_en = 0;
		error_control = 0;

		repeat(2)begin
			repeat(20)begin
				error_control = error_control + 1;
				#10;
			end
			error_control = 0;
			error_en = 1;
		end
		$finish;
	end
      
endmodule

