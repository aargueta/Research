`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:35:11 01/25/2013
// Design Name:   top
// Module Name:   D:/Unrelated Junk/Stanford/Research/scanInjectTest/scanInjectTest/top_tb.v
// Project Name:  scanInjectTest
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_tb;

	// Inputs
	reg clk;
	reg up_button;
	reg [8:1] sw;

	// Outputs
	wire [3:0] leds_l;
	wire [3:0] leds_r;
	wire serial1_tx;

	// Instantiate the Unit Under Test (UUT)
	top uut (
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
		up_button = 1;
		sw = 0;
		repeat(4)begin
			#5 clk = ~clk;
		end
		up_button = 0;
		forever
			#5 clk = ~clk;
	end
	
	initial begin
		#200000;
		sw = 8'hFFFF;
		#200000;
		$finish;
	end
      
endmodule

