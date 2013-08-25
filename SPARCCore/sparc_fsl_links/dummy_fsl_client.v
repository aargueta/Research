`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:21:35 07/07/2013 
// Design Name: 
// Module Name:    dummy_fsl_client 
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
`define FSL_D_WIDTH 32
module dummy_fsl_client(
	// Outputs
	fsl_m_control,
	fsl_m_data,
	fsl_m_write,

	fsl_s_read,
	
	data_out,

	// Inputs
	
	gclk,
	reset_l,

	fsl_m_full,

	fsl_s_exists,
	fsl_s_control,
	fsl_s_data,
	
	//Dummy input
	fsl_s_clk,
	fsl_m_clk
    );
	 
	 //=============================================
    // Outputs

    // PCX/FSL interface
    output reg                	 fsl_m_control;
    output reg [`FSL_D_WIDTH-1:0] fsl_m_data;
    output reg		                fsl_m_write;

    // MicroBlaze FSL Interface
    output reg fsl_s_read;
	 
	 //Dummy Data Out
	 output reg [7:0] data_out;

    //=============================================
    // Inputs
    input gclk;
    input reset_l;
	 
	 input fsl_s_clk;
	 input fsl_m_clk;

    // PCX/FSL interface
    input fsl_m_full;

    // MicroBlaze FSL Interface
    input                    fsl_s_exists;
    input                    fsl_s_control;
    input [`FSL_D_WIDTH-1:0] fsl_s_data;
	 
	 reg [15:0] count;
	 always @(posedge gclk)begin
		if(~reset_l | fsl_m_control)
			count <= 0;
		else
			count <= count + 16'd0;
	 end
	 
	 
	 always @(posedge gclk)begin
		fsl_m_control <= reset_l? (count == 16'd69) : 0;
		if(~reset_l & ~fsl_m_full)begin
			fsl_m_write <= 1'b1;
			fsl_m_data <= count;
		end else begin
			fsl_m_write <= 0;
			fsl_m_data <= 0;
		end			
	 end
	 
	 always @(posedge gclk)begin
		if(~reset_l)
			data_out <= 0;
		else if (fsl_s_exists | fsl_s_control)
			data_out <= {fsl_s_exists, fsl_s_control, fsl_s_data[5:0]};
		else
			data_out <= data_out;
	 end
endmodule
