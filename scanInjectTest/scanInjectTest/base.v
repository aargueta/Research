`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:39:09 01/25/2013 
// Design Name: 
// Module Name:    base 
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
module base(
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
	 wire [7:0] three;
	 reg [7:0] nextThree;
	 wire [7:0] four;
	 reg [7:0] nextFour;
	 
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
	 
	 dff_ns #(8) threeState(
		.clk(clk),
		.din(nextThree),
		.q(three)
	 );
	 
	 dff_ns #(8) fourState(
		.clk(clk),
		.din(nextFour),
		.q(four)
	);
	
	wire lvl1_out;
	lvl1 lvl1(
		.clk(clk),
		.rst(rst),
		.out(lvl1_out)
	);
	
	assign out = one[1] & two[1] & three[1] & four[1];
	
	always @(*)begin
		nextOne = rst? 8'hDE : one + 8'h09 + lvl1_out;
		nextTwo = rst? 8'hBE : two + 8'h0B;
		nextThree = rst? 8'hD1 : three + 8'h0D;
		nextFour = rst? 8'hB0 : four + 8'h0F;
	end


endmodule
