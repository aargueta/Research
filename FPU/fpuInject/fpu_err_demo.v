`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:57:56 01/10/2013 
// Design Name: 
// Module Name:    fpu_err_demo 
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
module fpu_demo_packets(
	clk,
	rst,
	pcxReady,
	pcxValid,
	pcxRequestType,
	pcxCpuID, 
	pcxThreadID,
	pcxData, 
	fpuOpcode,
	fpuConditionCode,
	fpuRoundMode
    );
	 
	input clk;
	input rst;
	
	output pcxReady;
	output reg pcxValid; 		// Always '1'
	output reg [122:118] pcxRequestType; // FP1 = 5'b01010, FP@ = 5'b01011
	output reg [116:114] pcxCpuID; 		// Identifies sender CPU of the PCX packet
	output reg [113:112] pcxThreadID; 	// Identifies sender thread in a multi-threaded sender CPU
	output reg [63:0] pcxData; 		// Actual value of float
	
	/*** FPU Operation Metadata ***/
	output reg [79:72] fpuOpcode; // 8-bit opcode for FPU operation
	output reg [67:66] fpuConditionCode; // 2-bit condition code for FPU operation
	output reg [65:64] fpuRoundMode;  // 2-bit rounding mode code for FPU operation
	
	wire getPacket;
	assign pcxReady = getPacket;
	dffr_ns getPacketState(
		.clk(clk),
		.rst(rst),
		.err_en(1'b0),
		.din(~getPacket),
		.q(getPacket)
	);
	
	wire [9:0] packetIndex;
	dffre_ns #(10) indexState(
		.clk(clk),
		.rst(rst),
		.err_en(1'b0),
		.en(getPacket),
		.din(packetIndex + 10'b1),
		.q(packetIndex)
	);
	
	always@(posedge clk)begin
		case(packetIndex[1:0])
			0:begin
				pcxValid = 1'b1;	
				pcxRequestType = 5'b01011; 		// FP2 = 5'b01011
				pcxCpuID = 3'b101;					// Random CPU ID
				pcxThreadID = 2'b10; 				// Random Thread ID
				pcxData = 64'h3FE8000000000000; 	// Float #1 = .75
				fpuOpcode = 8'b01000010; 			// FADDd
				fpuConditionCode = 2'b00; 			// Not applicable (==)
				fpuRoundMode = 2'b00;  				// Round to nearest
			end
			1:begin
				pcxValid = 1'b1;						// Always 1 for valid
				pcxRequestType = 5'b01011; 		// FP2 = 5'b01011
				pcxCpuID = 3'b101;					// Random CPU ID
				pcxThreadID = 2'b10; 				// Random Thread ID
				pcxData = 64'h3FD5555555555555; 	// Float #2 = 1/3
				fpuOpcode = 8'b01000010; 			// FADDd
				fpuConditionCode = 2'b00; 			// Not applicable (==)
				fpuRoundMode = 2'b00;  				// Round to nearest
			end
			2:begin
				pcxValid = 1'b1;						// Always 1 for valid
				pcxRequestType = 5'b01011; 		// FP2 = 5'b01011
				pcxCpuID = 3'b101;					// Random CPU ID
				pcxThreadID = 2'b10; 				// Random Thread ID
				pcxData = 64'h3FF8000000000000; 	// Float #1 = 1.5
				fpuOpcode = 8'b01001010; 			// FMULd
				fpuConditionCode = 2'b00; 			// Not applicable (==)
				fpuRoundMode = 2'b00;  				// Round to nearest
			end
			3:begin
				pcxValid = 1'b1;						// Always 1 for valid
				pcxRequestType = 5'b01011; 		// FP2 = 5'b01011
				pcxCpuID = 3'b101;					// Random CPU ID
				pcxThreadID = 2'b10; 				// Random Thread ID
				pcxData = 64'h4000000000000000; 	// Float #2 = 2
				fpuOpcode = 8'b01001010; 			// FMULd
				fpuConditionCode = 2'b00; 			// Not applicable (==)
				fpuRoundMode = 2'b00;  				// Round to nearest
			end
			default:begin
				pcxValid = 1'b0;
				pcxRequestType = 5'b00000;
				pcxCpuID = 3'b000;
				pcxThreadID = 2'b00;
				pcxData = 64'h0000000000000000;
				fpuOpcode = 8'b00000000;
				fpuConditionCode = 2'b00;
				fpuRoundMode = 2'b00;
			end
		endcase
	end

endmodule
