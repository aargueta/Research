`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:54:09 05/05/2012
// Design Name:   dffc_dc
// Module Name:   D:/Unrelated Junk/Stanford/Sophomore/Spring Quarter/Research/ShadowCapture/dff_dc_tb.v
// Project Name:  ShadowCapture
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dffc_dc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dff_dc_tb;
	localparam SIZE = 8;
	
	// Inputs
	reg clk;
	reg dclk;
	reg rst;
	reg c_en;
	reg d_en;
	reg [SIZE-1:0] din;

	// Outputs
	wire q_ready;
	wire [SIZE-1:0] q;

	// Instantiate the Unit Under Test (UUT)
	dffc_dc #(.SIZE(SIZE)) uut (
		.clk(clk), 
		.dclk(dclk), 
		.rst(rst), 
		.c_en(c_en), 
		.d_en(d_en), 
		.din(din), 
		.q_ready(q_ready), 
		.q(q)
	);

	// Clock and reset
	initial begin
		clk = 1'b0;
		rst = 1'b1;
		// Initialize Inputs
		c_en = 0;
		d_en = 0;
		din = 0;

		repeat (4) #5 clk = ~clk;
		rst = 1'b0;
		forever begin
			#5 clk = ~clk;
		end
	end
	
	// Data clock
	initial begin
		dclk = 1'b0;
		repeat (20) #7.5 dclk = ~dclk;
		repeat (10) #15 dclk = ~dclk;
		repeat (40) #2.5 dclk = ~dclk;
	end
	
	
   initial begin
		#30;
		din = 8'hAB;
		#10 c_en = 1'b1;
		#10 c_en = 1'b0;
		#50 d_en = 1'b1;
		din = 8'hFF;
		#20 din = 8'hFE;
		#20 d_en = 1'b0;
		din = 8'hFD;
		#10;
		
		
		#10 din = 8'hCD;
		#10 c_en = 1'b1;
		#10 c_en = 1'b0;
		#50 d_en = 1'b1;
		din = 8'hFF;
		#20 din = 8'hFE;
		#20 d_en = 1'b0;
		din = 8'hFD;
		#10;
		
		#10 din = 8'hEF;
		#10 c_en = 1'b1;
		#10 c_en = 1'b0;
		#50 d_en = 1'b1;
		din = 8'hFF;
		#20 din = 8'hFE;
		#20 d_en = 1'b0;
		din = 8'hFD;
		#10;
		$finish;
	end
endmodule

