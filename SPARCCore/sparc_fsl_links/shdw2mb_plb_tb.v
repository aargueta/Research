`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:28:46 08/06/2013
// Design Name:   shdw2mb_plb
// Module Name:   D:/Unrelated Junk/Stanford/Research/SPARCCore/sparc_fsl_links/shdw2mb_plb_tb.v
// Project Name:  sparc_fsl_links
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: shdw2mb_plb
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module shdw2mb_plb_tb;

	// Inputs
	reg gclk;
	reg [31:0] sh_out;
	reg [31:0] sh_out_vld;
	reg [31:0] sh_out_done;
	reg Bus2IP_Clk;
	reg Bus2IP_Reset;
	reg [0:31] Bus2IP_Addr;
	reg [0:0] Bus2IP_CS;
	reg Bus2IP_RNW;
	reg [0:31] Bus2IP_Data;
	reg [0:3] Bus2IP_BE;
	reg [0:7] Bus2IP_RdCE;
	reg [0:7] Bus2IP_WrCE;

	// Outputs
	wire err_en;
	wire [11:0] err_ctrl;
	wire sh_rst;
	wire c_en;
	wire [31:0] dump_en;
	wire [0:31] IP2Bus_Data;
	wire IP2Bus_RdAck;
	wire IP2Bus_WrAck;
	wire IP2Bus_Error;

	// Instantiate the Unit Under Test (UUT)
	shdw2mb_plb uut (
		.gclk(gclk), 
		.err_en(err_en), 
		.err_ctrl(err_ctrl), 
		.sh_rst(sh_rst), 
		.c_en(c_en), 
		.dump_en(dump_en), 
		.sh_out(sh_out), 
		.sh_out_vld(sh_out_vld), 
		.sh_out_done(sh_out_done), 
		.Bus2IP_Clk(Bus2IP_Clk), 
		.Bus2IP_Reset(Bus2IP_Reset), 
		.Bus2IP_Addr(Bus2IP_Addr), 
		.Bus2IP_CS(Bus2IP_CS), 
		.Bus2IP_RNW(Bus2IP_RNW), 
		.Bus2IP_Data(Bus2IP_Data), 
		.Bus2IP_BE(Bus2IP_BE), 
		.Bus2IP_RdCE(Bus2IP_RdCE), 
		.Bus2IP_WrCE(Bus2IP_WrCE), 
		.IP2Bus_Data(IP2Bus_Data), 
		.IP2Bus_RdAck(IP2Bus_RdAck), 
		.IP2Bus_WrAck(IP2Bus_WrAck), 
		.IP2Bus_Error(IP2Bus_Error)
	);

	initial begin
		// Initialize Inputs
		gclk = 0;
		sh_out = 32'hF000000A;
		sh_out_vld = 0;
		sh_out_done = 0;
		Bus2IP_Clk = 0;
		Bus2IP_Reset = 1;
		Bus2IP_Addr = 0;
		Bus2IP_CS = 0;
		Bus2IP_RNW = 0;
		Bus2IP_Data = 0;
		Bus2IP_BE = 4'b1111;
		Bus2IP_RdCE = 0;
		Bus2IP_WrCE = 0;

		repeat(4)begin
			#5 Bus2IP_Clk = ~Bus2IP_Clk;
			#5 Bus2IP_Clk = ~Bus2IP_Clk;
			gclk = ~gclk;
		end
		
		Bus2IP_Reset = 0;
		
		forever begin
			#5 Bus2IP_Clk = ~Bus2IP_Clk;
			#5 Bus2IP_Clk = ~Bus2IP_Clk;
			gclk = ~gclk;
			sh_out = dump_en[0]? sh_out + 32'h00000010 : sh_out;
		end
	end
	
	initial begin
		#55;
		Bus2IP_WrCE = 8'b10000000;
		Bus2IP_Data = 32'h17800000;
		#10;
		Bus2IP_WrCE = 8'b00000000;
		Bus2IP_RdCE = 8'b00000010;
		#10;
		Bus2IP_WrCE = 8'b10000000;
		Bus2IP_Data = 32'h40000000;//00000002;
		Bus2IP_RdCE = 8'b00000000;
		#10;
		Bus2IP_WrCE = 8'b10000000;
		Bus2IP_Data = 32'h20000000;//00000004;
		#10;
		Bus2IP_WrCE = 8'b00010000;
		Bus2IP_Data = 32'hFFFFFFFF;
		Bus2IP_RdCE = 8'b00000100;
		#10;
		Bus2IP_WrCE = 8'b00000000;
		Bus2IP_Data = 32'h00000000;
		Bus2IP_RdCE = 8'b00000000;
		#10;
		Bus2IP_WrCE = 8'b00010000;
		Bus2IP_Data = 32'hFFFFFFFF;
		Bus2IP_RdCE = 8'b00000100;
		#10;
		Bus2IP_WrCE = 8'b00010000;
		Bus2IP_Data = 32'hFFFFFFFF;
		Bus2IP_RdCE = 8'b00000100;
		#10;
		Bus2IP_WrCE = 8'b00000000;
		Bus2IP_Data = 32'h00000000;
		Bus2IP_RdCE = 8'b00000000;
		#40;
		Bus2IP_WrCE = 8'b00010000;
		Bus2IP_Data = 32'hFFFFFFFF;
		Bus2IP_RdCE = 8'b00000100;
		#10;
		$finish;
		
	end      
endmodule

