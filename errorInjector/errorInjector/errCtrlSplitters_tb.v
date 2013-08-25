`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:27:49 11/25/2012
// Design Name:   lclErrCtrlSplitter
// Module Name:   D:/Unrelated Junk/Stanford/Research/errorInjector/errorInjector/errCtrlSplitters_tb.v
// Project Name:  errorInjector
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: lclErrCtrlSplitter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module errCtrlSplitters_tb;
	localparam InWidth = 5;
	localparam LocalNum = 6;
	
	localparam Sub1Width = 4;
	localparam Sub1Num = 9;
	
	localparam Sub2Width = 4;
	localparam Sub2Num = 10;
	// Inputs
	reg err_en;
	reg [InWidth - 1:0] err_ctrl;

	// Outputs
	wire [LocalNum - 1 :0] lcl_err;

	lclErrCtrlSplitter #(.INW(InWidth), .LCL(LocalNum)) local (
		.err_en(err_en), 
		.err_ctrl(err_ctrl), 
		.lcl_err(lcl_err)
	);
	
	
	//Submodule 1
	wire [Sub1Width-1 : 0] sub1_err;
	wire sub1_err_en;
	subErrCtrlSplitter #(.INW(InWidth), .OUTW(Sub1Width), .LOW(LocalNum), .HIGH(LocalNum + Sub1Num - 1)) sub1sp (
		.err_en(err_en),
		.err_ctrl(err_ctrl), 
		.sub_err_en(sub1_err_en),
		.sub_err_ctrl(sub1_err)
	);
	
	wire [Sub1Num-1:0] sub1_lcl_err;
	lclErrCtrlSplitter #(.INW(Sub1Width), .LCL(Sub1Num)) sub1 (
		.err_en(sub1_err_en), 
		.err_ctrl(sub1_err), 
		.lcl_err(sub1_lcl_err)
	);
	
	
	//Submodule 2
	wire [Sub2Width-1 : 0] sub2_err;
	wire sub2_err_en;
	subErrCtrlSplitter #(.INW(InWidth), .OUTW(Sub2Width), .LOW(LocalNum + Sub1Num), .HIGH(LocalNum  + Sub1Num + Sub2Num - 1)) sub2sp (
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.sub_err_en(sub2_err_en),
		.sub_err_ctrl(sub2_err)
	);
	
	wire [Sub2Num-1:0] sub2_lcl_err;
	lclErrCtrlSplitter #(.INW(Sub2Width), .LCL(Sub2Num)) sub2 (
		.err_en(sub2_err_en), 
		.err_ctrl(sub2_err), 
		.lcl_err(sub2_lcl_err)
	);
	
	initial begin
		err_en = 0;
		err_ctrl = 0;
		#10;
			
		repeat(32)begin
			err_ctrl = err_ctrl + 1;
			#10;
		end 
		
		err_en = 1;
		err_ctrl = 0;
		#10;
			
		repeat(32)begin
			err_ctrl = err_ctrl + 1;
			#10;        
		end 
		$finish;
		
	end
      
endmodule

