`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:31:18 07/22/2013
// Design Name:   ccx2mb
// Module Name:   D:/Unrelated Junk/Stanford/Research/SPARCCore/sparc_fsl_links/ccx2mb_tb.v
// Project Name:  sparc_fsl_links
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ccx2mb
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ccx2mb_tb;

	// Inputs
	reg gclk;
	reg reset_l;
	reg [123:0] spc_pcx_data_pa;
	reg spc_pcx_atom_pq;
	reg [4:0] spc_pcx_req_pq;
	reg fsl_pcx_m_full;
	reg fsl_cpx_s_exists;
	reg fsl_cpx_s_control;
	reg [31:0] fsl_cpx_s_data;

	// Outputs
	wire [4:0] pcx_spc_grant_px;
	wire pcx_fsl_m_control;
	wire [31:0] pcx_fsl_m_data;
	wire pcx_fsl_m_write;
	wire cpx_spc_data_rdy_cx2;
	wire [144:0] cpx_spc_data_cx2;
	wire cpx_fsl_s_read;

	// Instantiate the Unit Under Test (UUT)
	ccx2mb uut (
		.pcx_spc_grant_px(pcx_spc_grant_px), 
		.pcx_fsl_m_control(pcx_fsl_m_control), 
		.pcx_fsl_m_data(pcx_fsl_m_data), 
		.pcx_fsl_m_write(pcx_fsl_m_write), 
		.cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2), 
		.cpx_spc_data_cx2(cpx_spc_data_cx2), 
		.cpx_fsl_s_read(cpx_fsl_s_read), 
		.gclk(gclk), 
		.reset_l(reset_l), 
		.spc_pcx_data_pa(spc_pcx_data_pa), 
		.spc_pcx_atom_pq(spc_pcx_atom_pq), 
		.spc_pcx_req_pq(spc_pcx_req_pq), 
		.fsl_pcx_m_full(fsl_pcx_m_full), 
		.fsl_cpx_s_exists(fsl_cpx_s_exists), 
		.fsl_cpx_s_control(fsl_cpx_s_control), 
		.fsl_cpx_s_data(fsl_cpx_s_data)
	);

	initial begin
		// Initialize Inputs
		gclk = 0;
		reset_l = 0;
		spc_pcx_data_pa = 0;
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		fsl_pcx_m_full = 0;
		fsl_cpx_s_exists = 0;
		fsl_cpx_s_control = 0;
		fsl_cpx_s_data = 0;

		repeat(4)
			#5 gclk = ~gclk;
			
		reset_l = 1'b1;
		
		forever begin
			#5 gclk = ~gclk;
		end

	end
      
	initial begin
		#40;
		spc_pcx_data_pa = {16{8'hA1}};
		spc_pcx_atom_pq = 1;
		spc_pcx_req_pq = 4'b1;
		#10;
		spc_pcx_data_pa = 124'h0000;
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		#50;
		spc_pcx_data_pa = {16{8'hB2}};
		spc_pcx_atom_pq = 1;
		spc_pcx_req_pq = 4'b1;
		#10;
		spc_pcx_data_pa = 124'h0000;
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		#50;
		spc_pcx_data_pa = {16{8'hC3}};
		spc_pcx_atom_pq = 1;
		spc_pcx_req_pq = 4'b1;
		#10;		
		spc_pcx_data_pa = 124'h0000;
		spc_pcx_atom_pq = 0;
		spc_pcx_req_pq = 0;
		#500;
		$finish;
		
		
	end
endmodule

