`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alejandro Argueta
// 
// Create Date:    19:18:56 03/30/2013 
// Design Name: 	SPARC Core Shadow Dump Interface to Microblaze Coprocessor
// Module Name:    shdw2mb 
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
`define FSL_CTRL_DUMP_START	32'hF0000001
`define FSL_CTRL_DUMP_DONE		32'hF0000002
`define FSL_CTRL_DUMP_IDLE		32'hF0000003

module shdw2mb(
    input clk,
    input rst_l,
	 
	 // FSL Master
    output reg [31:0] fsl_m_data,
    output reg			fsl_m_ctrl,
    output reg			fsl_m_write,
    input 				fsl_m_full,
	 
	 // FSL Slave
    output reg		fsl_s_read,
    input [31:0] 	fsl_s_data,
    input 			fsl_s_ctrl,
    input 			fsl_s_exists,
	 
	 // SPARC Interface
	 output reg				err_en,
	 output reg [11:0]	err_ctrl,
	 output reg				sh_rst,
	 output reg				c_en,
	 output [31:0]			dump_en,
	 input [31:0]	sh_out,
	 input [31:0]	sh_out_vld,
	 input [31:0]	sh_out_done
    );
	parameter C_EXT_RESET_HIGH = 0;
	 
	 /**************************
	 |BIT	|		PURPOSE		|
	  0	-	Valid Packet
	  1	-	Error Enable
	  2-13-	Error Control
	  14	-	Shadow Reset
	  15	-	Shadow Capture Enable
	  16	-	Shadow Dump Enable
	  17-31-	Unused
	 ***************************/
	 wire rst = ~rst_l;
	 /*** INCOMING COMMAND LOGIC ***/
	 wire fsl_valid =	fsl_s_data[0];	 
	 reg d_en_cmd;
	 always @(posedge clk)begin
		fsl_s_read = rst? 0 : (fsl_s_exists? 1 : 0);
		if(rst)begin
			err_en 	= 0;
			err_ctrl = 0;
			sh_rst 	= 1;
			c_en 		= 0;
			d_en_cmd	= 0;
		end if(fsl_s_exists && fsl_valid)begin
			err_en 	= fsl_s_data[1];
			err_ctrl = fsl_s_data[13:2];
			sh_rst 	= fsl_s_data[14];
			c_en 		= fsl_s_data[15];
			d_en_cmd	= fsl_s_data[16];
		end else begin
			err_en 	= err_en;
			err_ctrl = err_ctrl;
			sh_rst 	= sh_rst;
			c_en 		= c_en;
			d_en_cmd	= d_en_cmd;
		end
	 end
	 
	 /*** OUTGOING DATA LOGIC ***/
	 assign dump_en = rst? 0 : (fsl_m_full? 0 : d_en_cmd);
	 wire dump_done = &sh_out_done;
	 wire dump_valid = &sh_out_vld;
	 wire ack_err_en = fsl_s_data[1];
	 
	 reg prev_dump_done;
	 always @(posedge clk)begin
		fsl_m_ctrl <= rst? 0 : (dump_done | ack_err_en);
		prev_dump_done <= dump_done;
		if(ack_err_en)begin
			fsl_m_write <= 1;
			fsl_m_data <= {16'hDEAD, err_en, err_ctrl, c_en, d_en, dump_done};
		end else if(~rst & ~fsl_m_full & ~dump_done & dump_valid)begin
			fsl_m_write <= 1;
			fsl_m_data <= sh_out;
		end else if(prev_dump_done && ~dump_done)begin
			fsl_m_write <= 1;
			fsl_m_data <= `FSL_CTRL_DUMP_START;
		end else if(~prev_dump_done && dump_done)begin
			fsl_m_write <= 1;
			fsl_m_data <= `FSL_CTRL_DUMP_DONE;
		end else begin
			fsl_m_write <= 0;
			fsl_m_data <= 0;		
		end			
	 end
	 
endmodule
