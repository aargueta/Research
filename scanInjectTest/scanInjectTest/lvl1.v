`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:45:06 01/31/2013 
// Design Name: 
// Module Name:    lvl1 
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
module lvl1(
    clk,
    rst,
    out
    );

	input clk;
	input rst;
	output out;
	
	 wire [7:0] one;
	 reg [7:0] nextOne;
	 wire [7:0] two;
	 reg [7:0] nextTwo;
	 
	 dff_ns #(8) oneState(
		.clk(clk),
		.din(nextOne),
		.q(one)
	 );
	 
	 dff_ns #(8) twoState(
		.clk(clk),
		.din(nextTwo),
		.q(two)
	);
	
	assign out = one[1] & two[1];
	
	always @(*)begin
		nextOne = rst? 8'hDE : one + 8'h09;
		nextTwo = rst? 8'hBE : two + 8'h0B;
	end

endmodule
