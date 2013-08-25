`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:	Alejandro Argueta
//
// Create Date:   19:55:23 04/28/2012
// Design Name:   shadow_capture
// Module Name:   D:/Unrelated Junk/Stanford/Sophomore/Spring Quarter/Research/ShadowCapture/shadow_capture_tb.v
// Project Name:  ShadowCapture
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: shadow_capture
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module shadow_capture_tb;
	localparam DFF_BITS = 17;
	localparam CHAINS_IN = 3;
	localparam CHAINS_OUT = 3;
	localparam USE_DCLK = 1;
	
	reg [7:0] i;
	reg [7:0] cc1, cc2, cc3;
	
	// Inputs
	reg clk;
	reg rst;
	reg capture_en;
	reg [DFF_BITS - 1:0] din;
	reg dump_en;
	reg [(CHAINS_IN-1):0] chains_in;
	reg [(CHAINS_IN-1):0] chains_in_vld;
	reg [(CHAINS_IN-1):0] chains_done;

	// Outputs
	wire [(CHAINS_IN-1):0] chain_dump_en;
	wire [CHAINS_OUT-1:0] chains_out;
	wire [CHAINS_OUT-1:0] chains_out_vld;
	wire dump_done;

	// Instantiate the Unit Under Test (UUT)
	shadow_capture #(.DFF_BITS(DFF_BITS),.USE_DCLK(USE_DCLK), .CHAINS_IN(CHAINS_IN),.CHAINS_OUT(CHAINS_OUT)) uut (
		.clk(clk), 
		.rst(rst), 
		.capture_en(capture_en), 
		.dclk({DFF_BITS{clk}}),
		.din(din), 
		.dump_en(dump_en), 
		.chains_in(chains_in), 
		.chains_in_vld(chains_in_vld),
		.chains_done(chains_done), 
		.chain_dump_en(chain_dump_en), 
		.chains_out(chains_out),
		.chains_out_vld(chains_out_vld),
		.dump_done(dump_done)
	);

	// Clock and reset
	initial begin
		clk = 1'b0;
		rst = 1'b1;
		
		// Initialize Inputs
		i = 0;
		cc1 = 8'hFC;
		cc2 = 8'hEB;
		cc3 = 8'hDA;
		capture_en = 0;
		din = 0;
		dump_en = 0;
		chains_in = 0;
		chains_in_vld = 0;
		chains_done = 0;

		repeat (4) #5 clk = ~clk;
		rst = 1'b0;
		forever #5 clk = ~clk;
	end
	
	initial begin
		#30;
		din = 17'h1ABCD; 
		#20;
		capture_en = 1;
		#10 capture_en = 0;
		dump_en = 1;
		#180;
		
		for(i = 0; i < 8; i = i + 1)begin
			chains_in =  {1'bx, cc2[i], cc1[i]};
			chains_in_vld = 3'b011;
			#10;
		end
		chains_done = 3'b011;
		for(i = 0; i < 8; i = i + 1)begin
			chains_in =  {cc3[i], 2'bx};
			chains_in_vld = 3'b100;
			#10;
		end
		chains_done = 3'b111;
		chains_in_vld = 3'b000;
		#100;
		$finish;
	end      
endmodule

