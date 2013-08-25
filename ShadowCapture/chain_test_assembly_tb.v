`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:57:33 05/18/2012 
// Design Name: 
// Module Name:    chain_test_assembly_tb 
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
module chain_test_assembly_tb;

	localparam CHAINS_IN = 5;
	localparam CHAINS_OUT = 3;
	localparam SIZE = 8;
	
	// Inputs
	reg clk;
	reg dclk1, dclk2;
	reg rst;
	reg c_en;
	reg [SIZE-1:0] d_0, d_1, d_2, d_3, d_4;
	
	reg [CHAINS_OUT-1:0] d_en;

	// Outputs
	wire [CHAINS_IN-1:0] d_out;
	wire [CHAINS_IN-1:0] d_ready;
	wire [CHAINS_IN-1:0] d_done;
	
	wire [CHAINS_IN-1:0] cin_en;
	wire [CHAINS_OUT-1:0] cout;
	wire [CHAINS_OUT-1:0] cout_status;
	
	
	shadow_chain #(.SIZE(SIZE), .COUNT_WIDTH(8)) chain_0 (
		.clk(clk), 
		.rst(rst), 
		.c_en(c_en), 
		.d_en(cin_en[0]),
		.d_clk(dclk1), 
		.d_in(d_0), 
		.d_out(d_out[0]), 
		.d_ready(d_ready[0]), 
		.d_done(d_done[0])
	);
	
	shadow_chain #(.SIZE(SIZE), .COUNT_WIDTH(8)) chain_1 (
		.clk(clk), 
		.rst(rst), 
		.c_en(c_en), 
		.d_en(cin_en[1]),
		.d_clk(dclk1), 
		.d_in(d_1), 
		.d_out(d_out[1]), 
		.d_ready(d_ready[1]), 
		.d_done(d_done[1])
	);
	
	shadow_chain #(.SIZE(SIZE), .COUNT_WIDTH(8)) chain_2 (
		.clk(clk), 
		.rst(rst), 
		.c_en(c_en), 
		.d_en(cin_en[2]),
		.d_clk(dclk2), 
		.d_in(d_2), 
		.d_out(d_out[2]), 
		.d_ready(d_ready[2]), 
		.d_done(d_done[2])
	);
	
	shadow_chain #(.SIZE(SIZE), .COUNT_WIDTH(8)) chain_3 (
		.clk(clk), 
		.rst(rst), 
		.c_en(c_en), 
		.d_en(cin_en[3]),
		.d_clk(dclk2), 
		.d_in(d_3), 
		.d_out(d_out[3]), 
		.d_ready(d_ready[3]), 
		.d_done(d_done[3])
	);
	
	shadow_chain #(.SIZE(SIZE), .COUNT_WIDTH(8)) chain_4 (
		.clk(clk), 
		.rst(rst), 
		.c_en(c_en), 
		.d_en(cin_en[4]),
		.d_clk(dclk2), 
		.d_in(d_4), 
		.d_out(d_out[4]), 
		.d_ready(d_ready[4]), 
		.d_done(d_done[4])
	);
	
	chain_controller #(.CHAINS_IN(CHAINS_IN), .CHAINS_OUT(CHAINS_OUT)) c_cont (
		.clk(clk), 
		.rst(rst), 
		.cin_ready(d_ready),
		.cin_done(d_done), 
		.cin(d_out), 
		.cin_en(cin_en), 
		.cout_en(d_en),
		.cout(cout), 
		.cout_status(cout_status)
	);
	
	chain_interpreter_tm #(.CHAINS_IN(CHAINS_OUT),.CHAIN_DEPTH(SIZE)) c_int (
		.clk(clk), 
		.rst(rst), 
		.cin(cout)
	);
	
	// Clock and reset
	initial begin
		clk = 1'b0;
		rst = 1'b1;
		dclk1 = 0;
		dclk2 = 0;
		
		c_en = 0;
		d_en = 0;
		
		d_0 = 8'hAB;
		d_1 = 8'hAC;
		d_2 = 8'hAD;
		d_3 = 8'hAE; 
		d_4 = 8'hAF;

		repeat (4)begin
			#5 clk = ~clk;
			#5 dclk1 = ~dclk1;
			#5 dclk2 = ~dclk2;
		end
		rst = 1'b0;
		forever begin
			#5 clk = ~clk;
			#5 dclk1 = ~dclk1;
			#5 dclk2 = ~dclk2;
		end
	end
	
	initial begin
		#60 c_en = 1;
		#30 c_en = 0;
		#30 d_en = 3'b111;
		#600;
		$finish;		
	end
endmodule
