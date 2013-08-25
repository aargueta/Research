`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:30:28 08/21/2012
// Design Name:   fpu
// Module Name:   D:/Unrelated Junk/Stanford/Sophomore/Spring Quarter/Research/ShadowCapture/shadowed_fpu_tb.v
// Project Name:  ShadowCapture
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

	
	/*** FPU OPCODES ***/
	//	Opcode 	op3 			opf 				Operation
	//------------------------------------------------
	//	FADDs 	11 0100 		0 0100 0001 	Add Single
	//	FADDd 	11 0100 		0 0100 0010 	Add Double
	//	FADDq 	11 0100 		0 0100 0011 	Add Quad
	//	FSUBs 	11 0100 		0 0100 0101 	Subtract Single
	//	FSUBd 	11 0100 		0 0100 0110 	Subtract Double
	//	FSUBq 	11 0100 		0 0100 0111 	Subtract Quad

	/*** FPU CONDITION CODES ***/
	//	Code	Condition
	//------------------
	//	00		FP1 = FP2
	//	01		FP1 < FP2
	//	10		FP1 > FP2
	//	11		FP1 ? FP2 (unordered)
	
	/*** FPU ROUNDING CODES ***/
	//	CODE	ROUNDING
	//---------------
	//	00		Nearest
	//	01		0
	//	10		+INF
	//	11		-INF
	
module shadowed_fpu_tb;
	localparam CHAINS_OUT = 64;

	// Inputs
	reg pcxPacketReady; //PCX packet ready flag
	wire [123:0] pcxPacket; // PCX packet
	reg arst_l; // Chip asynchronous reset (asserted low)
	reg grst_l; // Chip synchronous reset (asserted low)
	reg gclk; // Global chip clock
	reg cluster_cken; // Cluster clock enable
	reg ctu_tst_pre_grst_l;
	reg global_shift_enable;
	reg ctu_tst_scan_disable;
	reg ctu_tst_scanmode;
	reg ctu_tst_macrotest;
	reg ctu_tst_short_chain;
	reg si; 
	reg sh_clk;
	reg sh_rst;
	reg c_en;
	reg dump_en; // Dump enable
	reg force_error;

	// Outputs
	wire [7:0]  cpxResultRequest; //FPU result request to CPX
	wire [144:0] cpxResultPacket; // FPU result packet to CPX
	wire so;
	wire [CHAINS_OUT-1:0] ch_out;
	wire [CHAINS_OUT-1:0] ch_out_vld;
	wire [CHAINS_OUT-1:0] ch_out_done;
	
	/*** PCX packet assembly ***/
	reg pcxValid; 		// Always '1'
	reg [122:118] pcxRequestType; // FP1 = 5'b01010, FP@ = 5'b01011
	reg [116:114] pcxCpuID; 		// Identifies sender CPU of the PCX packet
	reg [113:112] pcxThreadID; 	// Identifies sender thread in a multi-threaded sender CPU
	wire [103:64] pcxAddress; 	// Only last 16 bits used for operation data in FPU PCX packets
	reg [63:0] pcxData; 		// Actual value of float
	
	/*** FPU Operation Metadata ***/
	reg [79:72] fpuOpcode; // 8-bit opcode for FPU operation
	reg [67:66] fpuConditionCode; // 2-bit condition code for FPU operation
	reg [65:64] fpuRoundMode;  // 2-bit rounding mode code for FPU operation
	
	assign pcxAddress = {24'b0, fpuOpcode, 4'b0, fpuConditionCode, fpuRoundMode};
	assign pcxPacket = {pcxValid, pcxRequestType, 1'b0, pcxCpuID, pcxThreadID, 8'b0, pcxAddress, pcxData};

	/*** CPX Packet Disassembly ***/
	wire [3:0] cpxReturnType; // 4'b1000 for FP return
	wire [1:0] cpxThreadId;
	wire [127:0] cpxData;
	
	/*** FPU Operation Return Data  Disassembly***/
	wire NV; // Invalid
	wire OF; // Overflow
	wire UF; // Underflow
	wire DZ; // Division by zero
	wire NX; // Inexact
	wire compOp; // Compare operation result
	wire [1:0] cpxCondCode; 
	wire [1:0] pcxCondCode; // Condition codes from PCX
	wire [63:0] fpuReturnVal;
	
	assign cpxReturnType = cpxResultPacket[143:140];
	assign cpxReturnThread= cpxResultPacket[135:134];
	assign cpxData = cpxResultPacket[127:0];
	
	assign {NV, OF, UF, DZ, NX} = cpxData[76:72];
	assign {compOp, cpxCondCode, pxcCondCode} = cpxData[69:65];
	assign fpuReturnVal = cpxData[63:0];
	
	// Instantiate the Unit Under Test (UUT)
	fpu uut (
		.pcx_fpio_data_rdy_px2(pcxPacketReady), 
		.pcx_fpio_data_px2(pcxPacket), 
		.arst_l(arst_l), 
		.grst_l(grst_l), 
		.gclk(gclk), 
		.cluster_cken(cluster_cken), 
		.fp_cpx_req_cq(cpxResultRequest), 
		.fp_cpx_data_ca(cpxResultPacket), 
		.ctu_tst_pre_grst_l(ctu_tst_pre_grst_l), 
		.global_shift_enable(global_shift_enable), 
		.ctu_tst_scan_disable(ctu_tst_scan_disable), 
		.ctu_tst_scanmode(ctu_tst_scanmode), 
		.ctu_tst_macrotest(ctu_tst_macrotest), 
		.ctu_tst_short_chain(ctu_tst_short_chain), 
		.si(si), 
		.so(so), 
		.sh_clk(sh_clk), 
		.sh_rst(sh_rst),
		.c_en(c_en), 
		.dump_en({CHAINS_OUT{dump_en}}), 
		.ch_out(ch_out),
		.ch_out_vld(ch_out_vld),
		.ch_out_done(ch_out_done),
		.force_error(force_error)
	);

	initial begin
		// Initialize Inputs
		pcxValid = 1'b1;						// Always 1 for valid
		pcxRequestType = 5'b01010; 		// FP1 = 5'b01010
		pcxCpuID = 3'b101;					// Random CPU ID
		pcxThreadID = 2'b10; 				// Random Thread ID
		pcxData = 64'h3FE8000000000000; 	// Float #1 = .75
		fpuOpcode = 8'b01000010; 			// FADDd
		fpuConditionCode = 2'b00; 			// Not applicable (==)
		fpuRoundMode = 2'b00;  				// Round to nearest
		
		pcxPacketReady = 0;
		arst_l = 0;
		grst_l = 0;
		gclk = 0;
		cluster_cken = 0;
		ctu_tst_pre_grst_l = 0;
		global_shift_enable = 0;
		ctu_tst_scan_disable = 0;
		ctu_tst_scanmode = 0;
		ctu_tst_macrotest = 0;
		ctu_tst_short_chain = 0;
		si = 0;
		sh_clk = 0;
		sh_rst = 0;
		c_en = 0;
		dump_en = 0;
		force_error = 0;

		
		#20 gclk = ~gclk;
		sh_clk = ~sh_clk;
		sh_rst = 1'b1;
		repeat(8)begin
			#20 gclk = ~gclk;
			sh_clk = ~sh_clk;
		end
		arst_l = 1'b1;
		grst_l = 1'b1;
		sh_rst= 1'b0;
		cluster_cken = 1;
		
		forever begin
			#20 gclk = ~gclk;
			sh_clk = ~sh_clk;
		end
	end
	
	initial begin
		#320;
		pcxValid = 1'b1;						// Always 1 for valid
		pcxRequestType = 5'b01011; 		// FP2 = 5'b01011
		pcxCpuID = 3'b101;					// Random CPU ID
		pcxThreadID = 2'b10; 				// Random Thread ID
		pcxData = 64'h3FE8000000000000; 	// Float #1 = .75
		fpuOpcode = 8'b01000010; 			// FADDd
		fpuConditionCode = 2'b00; 			// Not applicable (==)
		fpuRoundMode = 2'b00;  				// Round to nearest
		
		pcxPacketReady = 1'b1;
		#40;// pcxPacketReady = 1'b0;
		
		pcxValid = 1'b1;						// Always 1 for valid
		pcxRequestType = 5'b01011; 		// FP2 = 5'b01011
		pcxCpuID = 3'b101;					// Random CPU ID
		pcxThreadID = 2'b10; 				// Random Thread ID
		pcxData = 64'h3FD5555555555555; 	// Float #2 = 1/3
		fpuOpcode = 8'b01000010; 			// FADDd
		fpuConditionCode = 2'b00; 			// Not applicable (==)
		fpuRoundMode = 2'b00;  				// Round to nearest
		
		//#20 pcxPacketReady = 1'b1;
		#40 pcxPacketReady = 1'b0;
		c_en = 1;
		
		#40 c_en = 0;
		dump_en = 1;
		
		//#40 dump_en = 0;
		// RETURN VALUE SHOULD BE 0x3FF1 5555 5555 5555
		// 1.08333333333333325931846502499E0
		#4200;
		$finish;
	end
      
endmodule

