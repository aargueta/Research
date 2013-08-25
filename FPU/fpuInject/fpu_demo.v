////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:58:25 01/10/2013
// Design Name:   fpu
// Module Name:   D:/Unrelated Junk/Stanford/Research/FPU/fpuInject/fpu_demo.v
// Project Name:  fpuInject
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

module fpu_demo(
	// Clock
	input clk,     
	// Push button interface
	/*input  left_button,
	input  right_button,*/
	input  up_button,
	//input  down_button,
	// Tactile Switches
	input [8:1] sw,
	// LEDs
	output wire [3:0] leds_l,
	output wire [3:0] leds_r,
	// Serial
	output wire serial1_tx
);
	wire [7:0] inject_errors = sw[8:1];
	wire reset = up_button;

	// Shadowing/Error Control Inputs
	wire err_en;
	wire [8:0] err_ctrl;
	wire c_en;
	wire [7:0] dump_en;
	
	// FPU Inputs
	wire pcxPacketReady; 	//PCX packet ready flag
	wire [123:0] pcxPacket; // PCX packet
	wire arst_l = ~reset;	// Chip asynchronous reset (asserted low)
	wire grst_l = ~reset;	// Chip synchronous reset (asserted low)
	wire gclk = clk;			// Global chip clock
	wire cluster_cken = 1'b1;	// Cluster clock enable
	wire ctu_tst_pre_grst_l = 1'b0;
	wire global_shift_enable =  1'b0;
	wire ctu_tst_scan_disable =  1'b0;
	wire ctu_tst_scanmode =  1'b0;
	wire ctu_tst_macrotest =  1'b0;
	wire ctu_tst_short_chain =  1'b0;
	wire si =  1'b0;

	// FPU Outputs
	wire [7:0]  cpxResultRequest; 	//FPU result request to CPX
	wire [144:0] cpxResultPacket; 	// FPU result packet to CPX
	wire so;
	wire [7:0] ch_out;
	wire [7:0] ch_out_vld;
	wire [7:0] ch_out_done;


	/*** PCX packet assembly ***/
		wire pcxValid; 						// Always '1'
		wire [122:118] pcxRequestType; // FP1 = 5'b01010, FP@ = 5'b01011
		wire [116:114] pcxCpuID; 		// Identifies sender CPU of the PCX packet
		wire [113:112] pcxThreadID; 	// Identifies sender thread in a multi-threaded sender CPU
		wire [103:64] pcxAddress; 		// Only last 16 bits used for operation data in FPU PCX packets
		wire [63:0] pcxData; 				// Actual value of float
		
	/*** FPU Operation Metadata ***/
		wire [79:72] fpuOpcode; 			// 8-bit opcode for FPU operation
		wire [67:66] fpuConditionCode; // 2-bit condition code for FPU operation
		wire [65:64] fpuRoundMode; 		// 2-bit rounding mode code for FPU operation
		
		assign pcxAddress = {24'b0, fpuOpcode, 4'b0, fpuConditionCode, fpuRoundMode};
		assign pcxPacket = {pcxValid, pcxRequestType, 1'b0, pcxCpuID, pcxThreadID, 8'b0, pcxAddress, pcxData};

	/*** CPX Packet Disassembly ***/
		wire [3:0] cpxReturnType; 		// 4'b1000 for FP return
		wire [1:0] cpxThreadId;
		wire [127:0] cpxData;
		
	/*** FPU Operation Return Data  Disassembly***/
		wire NV; 						// Invalid
		wire OF; 						// Overflow
		wire UF; 						// Underflow
		wire DZ; 						// Division by zero
		wire NX; 						// Inexact
		wire compOp; 					// Compare operation result
		wire [1:0] cpxCondCode; 
		wire [1:0] pcxCondCode; 	// Condition codes from PCX
		wire [63:0] fpuReturnVal;
	
	assign cpxReturnType = cpxResultPacket[143:140];
	assign cpxReturnThread= cpxResultPacket[135:134];
	assign cpxData = cpxResultPacket[127:0];
	
	assign {NV, OF, UF, DZ, NX} = cpxData[76:72];
	assign {compOp, cpxCondCode, pxcCondCode} = cpxData[69:65];
	assign fpuReturnVal = cpxData[63:0];
	
	wire [7:0] tx_data;
	wire tx_en;
	wire serial_busy;
	wire dump_done;
	
	assign leds_l = {dump_done, |dump_en, serial_busy, serial1_tx};
	assign leds_r = {err_en, tx_data[2:0]};
	c_d_ctrl capture_dump_controller(
		.clk(clk),
		.rst(reset),
		.inj_err(inject_errors),
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.ch_out(ch_out),
		.ch_out_vld(ch_out_vld),
		.ch_out_done(ch_out_done),
		.serial_busy(serial_busy),
		.c_en(c_en),
		.dump_en(dump_en),
		.serial_en(tx_en),
		.serial_tx(tx_data),
		.demo_done(dump_done)
	);
	
	fpu_demo_packets fpu_instrs (
		.clk(clk),
		.rst(reset),
		.pcxReady(pcxPacketReady),
		.pcxValid(pcxValid),
		.pcxRequestType(pcxRequestType),
		.pcxCpuID(pcxCpuID), 
		.pcxThreadID(pcxThreadID),
		.pcxData(pcxData), 
		.fpuOpcode(fpuOpcode),
		.fpuConditionCode(fpuConditionCode),
		.fpuRoundMode(fpuRoundMode)
	);
	
	fpu fpu (
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
		.err_en(err_en), 
		.err_ctrl(err_ctrl), 
		.sh_clk(clk), 
		.sh_rst(reset), 
		.c_en(c_en), 
		.dump_en(dump_en), 
		.ch_out(ch_out), 
		.ch_out_vld(ch_out_vld), 
		.ch_out_done(ch_out_done)
	);
	
	uart_tx serial(
		.uart_busy(serial_busy),   // High means UART is transmitting
		.uart_tx(serial1_tx),     // UART transmit wire
		// Inputs
		.tx_en(tx_en),   // Raise to transmit byte
		.tx_data(tx_data),  // 8-bit data
		.clk(clk),   // System clock, 68 MHz
		.rst(reset)    // System reset
	);
	
	// Xilinx UART
	/*wire tbre, tsre, prev_tbre, wrn;
	wire [7:0] serial_din;
	wire [6:0] clock_count;
	wire clk16x = clock_count[6];
	wire prev_clk16x, posedge_clk16x;
	dffr_ns #(7) serialClock(
		.clk(clk),
		.rst(reset),
		.err_en(1'b0),
		.din(clock_count + 1'b1),
		.q(clock_count)
	);
	
	dffr_ns busyState(
		.clk(clk),
		.rst(reset),
		.err_en(1'b0),
		.din(tbre),
		.q(prev_tbre)
	);
	
	dffr_ns prevClkState(
		.clk(clk),
		.rst(reset),
		.err_en(1'b0),
		.din(clk16x),
		.q(prev_clk16x)
	);
	
	dffre_ns #(8) dataState(
		.clk(clk),
		.rst(reset),
		.err_en(1'b0),
		.en(~wrn),
		.din(tx_data),
		.q(serial_din)
	);
	
	dffr_ns writeState(
		.clk(clk),
		.rst(reset|posedge_clk16x),
		.err_en(1'b0),
		.din(tx_en | wrn),
		.q(wrn)
	);
	
	assign posedge_clk16x = ~prev_clk16x & clk16x;
	assign serial_busy = ~(prev_tbre & ~tbre);
	
	txmit serial (
		.tbre(tbre), 	// Transmit buffer empty
		.tsre(tsre), 	// Transmit sending register empty
		.sdo(serial1_tx), 		// Serial data out
		.din(serial_din), 		// Data in
		.rst(reset), 		
		.clk16x(clk16x),// Clk = 16 x Baudrate  
		.wrn(wrn)		// Write enable?
	);*/
endmodule

