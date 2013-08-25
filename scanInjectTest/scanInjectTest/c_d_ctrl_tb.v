`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:03:42 01/11/2013
// Design Name:   c_d_ctrl
// Module Name:   D:/Unrelated Junk/Stanford/Research/FPU/fpuInject/c_d_ctrl_tb.v
// Project Name:  fpuInject
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: c_d_ctrl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module c_d_ctrl_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [7:0] ch_out;
	reg [7:0] ch_out_vld;
	reg [7:0] ch_out_done;
	reg serial_busy;

	// Outputs
	wire c_en;
	wire [7:0] dump_en;
	wire serial_en;
	wire [7:0] serial_tx;

	// Instantiate the Unit Under Test (UUT)
	c_d_ctrl uut (
		.clk(clk), 
		.rst(rst), 
		.ch_out(ch_out), 
		.ch_out_vld(ch_out_vld), 
		.ch_out_done(ch_out_done), 
		.serial_busy(serial_busy), 
		.c_en(c_en), 
		.dump_en(dump_en), 
		.serial_en(serial_en), 
		.serial_tx(serial_tx)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		ch_out = 0;
		ch_out_vld = 0;
		ch_out_done = 0;
		serial_busy = 0;

		// Wait 100 ns for global reset to finish
		#5 clk = ~clk;
		#5 clk = ~clk;		
		#5 clk = ~clk;
		#5 clk = ~clk;
		rst = 0;
		forever begin
			#5 clk = ~clk;
		end
	end
   initial begin
		#20;
		repeat(5)begin
			repeat(200)begin
				ch_out = ch_out + 1;
				#10;
			end
			ch_out_done = 8'hFF;
			#30;
			ch_out_done = 8'h00;
		end
		$finish;
	end   
endmodule

