`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:29:53 05/25/2012
// Design Name:   chain_interpreter_tm
// Module Name:   D:/Unrelated Junk/Stanford/Sophomore/Spring Quarter/Research/ShadowCapture/chain_interpreter_tb.v
// Project Name:  ShadowCapture
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: chain_interpreter_tm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module chain_interpreter_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [2:0] cin;

	// Instantiate the Unit Under Test (UUT)
	chain_interpreter_tm #(.CHAINS_IN(3),.CHAIN_DEPTH(4)) uut (
		.clk(clk), 
		.rst(rst), 
		.cin(cin)
	);
	
	// Clock and reset
	initial begin
		clk = 1'b0;
		rst = 1'b1;
		cin = 0;

		repeat (4)begin
			#10 clk = ~clk;
		end
		rst = 1'b0;
		forever begin
			#10 clk = ~clk;
		end
	end
	
	initial begin
		#40 cin = 3'b001;
		#20 cin = 3'b010;
		#20 cin = 3'b111;
		#20 cin = 3'b110;
	end
      
endmodule

