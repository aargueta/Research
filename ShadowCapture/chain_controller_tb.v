`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:55:43 05/18/2012
// Design Name:   chain_controller
// Module Name:   D:/Unrelated Junk/Stanford/Sophomore/Spring Quarter/Research/ShadowCapture/chain_controller_tb.v
// Project Name:  ShadowCapture
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: chain_controller
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module chain_controller_tb;
	localparam CHAINS_IN = 5;
	localparam CHAINS_OUT = 3;
	
	// Inputs
	reg clk;
	reg rst;
	reg [CHAINS_IN-1:0] cin_status;
	reg [CHAINS_IN-1:0] cin;
	reg [CHAINS_OUT-1:0] cout_en;

	// Outputs
	wire [CHAINS_IN-1:0] cin_en;
	wire [CHAINS_OUT-1:0] cout;
	wire [CHAINS_OUT-1:0] cout_status;

	// Instantiate the Unit Under Test (UUT)
	chain_controller #(.CHAINS_IN(CHAINS_IN), .CHAINS_OUT(CHAINS_OUT)) uut (
		.clk(clk), 
		.rst(rst), 
		.cin_status(cin_status), 
		.cin(cin), 
		.cin_en(cin_en), 
		.cout_en(cout_en),
		.cout(cout), 
		.cout_status(cout_status)
	);
	
	// Clock and reset
	initial begin
		clk = 1'b0;
		rst = 1'b1;
		cin_status = 0;
		cin = 0;
		cout_en = 0;

		repeat (4) #5 clk = ~clk;
		rst = 1'b0;
		forever #5 clk = ~clk;
	end
	
	initial begin
		#30 cin_status = 5'b00000;
		cout_en = 3'b111;
		#10 cin = 5'b11111;
		#10 cin = 5'b01111;
		#10 cin = 5'b10111;
		#10 cin = 5'b00011;
		#10 cin = 5'b11011;
		#10 cin = 5'b01011;
		#10 cin_status = 5'b11100;
		
		#10 cin = 5'b00011;
		#10 cin = 5'b00001;
		#10 cin = 5'b00010;
		#10 cin = 5'b00000;
		#10 cin_status = 5'b11111;
		#20;
		$finish;
	end
      
endmodule

