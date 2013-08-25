`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:04:43 02/01/2013
// Design Name:   top_fpu_add
// Module Name:   D:/Unrelated Junk/Stanford/Research/scanInjectTest/scanInjectTest/top_fpu_add_tb.v
// Project Name:  scanInjectTest
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_fpu_add
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_fpu_add_tb;

	// Inputs
	reg clk;
	reg up_button;
	reg [8:1] sw;

	// Outputs
	wire [3:0] leds_l;
	wire [3:0] leds_r;
	wire serial1_tx;

	// Instantiate the Unit Under Test (UUT)
	top_fpu_add uut (
		.clk(clk), 
		.up_button(up_button), 
		.sw(sw), 
		.leds_l(leds_l), 
		.leds_r(leds_r), 
		.serial1_tx(serial1_tx)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		up_button = 1'b1;
		sw = 0;
		
		repeat(4)
			#10 clk = ~clk;
		
		up_button = 1'b0;
		forever
			#10 clk = ~clk;
	end
	
	initial begin
		#20000;
		$finish;
	end
	
      
endmodule

