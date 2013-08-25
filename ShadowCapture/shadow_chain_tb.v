`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:44:39 05/18/2012
// Design Name:   shadow_chain
// Module Name:   D:/Unrelated Junk/Stanford/Sophomore/Spring Quarter/Research/ShadowCapture/shadow_chain_tb.v
// Project Name:  ShadowCapture
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: shadow_chain
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module shadow_chain_tb;
	localparam SIZE = 8;
	
	// Inputs
	reg clk;
	reg rst;
	reg c_en;
	reg d_en;
	reg d_clk;
	reg [SIZE-1:0] d_in;

	// Outputs
	wire d_out;
	wire d_ready;
	wire d_done;

	// Instantiate the Unit Under Test (UUT)
	shadow_chain #(.SIZE(SIZE), .COUNT_WIDTH(8)) uut (
		.clk(clk), 
		.rst(rst), 
		.c_en(c_en), 
		.d_en(d_en),
		.d_clk(d_clk), 
		.d_in(d_in), 
		.d_out(d_out), 
		.d_ready(d_ready), 
		.d_done(d_done)
	);

	// Clock and reset
	initial begin
		clk = 1'b0;
		rst = 1'b1;
		c_en = 0;
		d_en = 0;
		d_clk = 0;
		d_in = 0;
		
		repeat (4)begin
			#2.5 clk = ~clk;
			#2.5 d_clk = ~d_clk;
		end
		rst = 1'b0;
		forever begin
			#2.5 clk = ~clk;
			#2.5 d_clk = ~d_clk;
		end
	end
      
	initial begin
		#30 d_in = 8'hAB;
		c_en = 1;
		#10 c_en = 0;
		d_in = 0;
		#30 d_en = 1;
		#100;
		$finish;
	end
endmodule

