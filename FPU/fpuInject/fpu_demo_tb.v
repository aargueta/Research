`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:36:55 01/11/2013
// Design Name:   fpu_demo
// Module Name:   D:/Unrelated Junk/Stanford/Research/FPU/fpuInject/fpu_demo_tb.v
// Project Name:  fpuInject
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fpu_demo
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fpu_demo_tb;

	// Inputs
	reg clk;
	reg up_button;

	// Outputs
	wire serial1_tx;

	// Instantiate the Unit Under Test (UUT)
	fpu_demo uut (
		.clk(clk), 
		.up_button(up_button), 
		.serial1_tx(serial1_tx),
		.sw(8'hFF)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		up_button = 1;

		#5 clk = ~clk;
		#5 clk = ~clk;		
		#5 clk = ~clk;
		#5 clk = ~clk;
		up_button = 0;
		forever begin
			#5 clk = ~clk;
		end
	end
	
	initial begin
		#10000;
		$finish;
	end
      
endmodule

