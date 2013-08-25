`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   05:50:46 02/05/2013
// Design Name:   async_transmitter
// Module Name:   D:/Unrelated Junk/Stanford/Research/scanInjectTest/scanInjectTest/async_transmitter_tb.v
// Project Name:  scanInjectTest
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: async_transmitter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module async_transmitter_tb;

	// Inputs
	reg clk;
	reg TxD_start;
	reg [7:0] TxD_data;

	// Outputs
	wire TxD;
	wire TxD_busy;

	// Instantiate the Unit Under Test (UUT)
	async_transmitter uut (
		.clk(clk), 
		.TxD_start(TxD_start), 
		.TxD_data(TxD_data), 
		.TxD(TxD), 
		.TxD_busy(TxD_busy)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		TxD_start = 0;
		TxD_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

