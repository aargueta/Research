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
module shdw2mb(

	// DO NOT EDIT BELOW THIS LINE ////////////////////
	// Bus protocol ports, do not add or delete. 
	input 	        	FSL_Clk,
	input 	        	FSL_Rst,
	input 	        	FSL_S_Clk,
	output	reg     	FSL_S_Read,
	input 	[31 : 0]	FSL_S_Data,
	input 	        	FSL_S_Control,
	input 	        	FSL_S_Exists,
	input 	        	FSL_M_Clk,
	output	        	FSL_M_Write,
	output	[31 : 0]	FSL_M_Data,
	output	        	FSL_M_Control,
	input 	        	FSL_M_Full
	// DO NOT EDIT ABOVE THIS LINE ////////////////////
	 
	 // SPARC Interface
	 output reg				err_en,
	 output reg [11:0]	err_ctrl,
	 output reg				sh_rst,
	 output reg				c_en,
	 output [31:0]			dump_en,
	 input [31:0]	sh_out,
	 input [31:0]	sh_out_vld,
	 input [31:0]	sh_out_done,

	 // Debug
	 output [7:0]	debug_out
    );

	// ADD USER PARAMETERS BELOW THIS LINE 
	localparam WORDS_PER_DUMP = 1000;
	// ADD USER PARAMETERS ABOVE THIS LINE

	// Define the states of state machine
	localparam IDLE        = 3'd0;
	localparam CAPTURE_EN  = 3'd1;
	localparam DUMP        = 3'd2;
	localparam DUMP_PAUSED = 3'd3;
	localparam TEST 	   = 3'd4

	reg [2:0] state;
	reg [15:0] dump_count;

	wire data_valid = | sh_out_vld;
	wire dump_done = | sh_out_done;
	wire cutoff_dump = dump_count > WORDS_PER_DUMP;


	wire fsl_shdw_rst 	= FSL_S_Data[0];
	wire fsl_c_en 		= FSL_S_Data[1];
	wire fsl_dump_en 	= FSL_S_Data[2];
	wire fsl_test       = FSL_S_Data[3];
	wire fsl_test_echo 	= FSL_S_Data[11:4];

	reg [8:0] test_vector;

	always @(posedge FSL_Clk) 
	begin
	  if (FSL_Rst)
	    begin
	       // CAUTION: make sure your reset polarity is consistent with the
	       // system reset polarity
	       FSL_S_Read   <= 0;
	       state        <= IDLE;
	    end
	  else
	    case (state)
	      IDLE: 
	        if (FSL_S_Exists) begin
				FSL_S_Read  <= 1;
	          	if(fsl_c_en)
	          		state 	<= CAPTURE_EN;
        		else if(fsl_dump_en)
        			state 	<= DUMP;
        		else
        			state <= TEST;
	        end else begin
	          FSL_S_Read  <= 0;
	          state       <= IDLE;          
	        end
	      CAPTURE_EN: 
	        if (FSL_S_Exists) begin
	          FSL_S_Read  <= 1;
	          state       <= fsl_dump_en? DUMP : CAPTURE_EN;
	        end else begin
	          FSL_S_Read  <= 0;
	          state       <= CAPTURE_EN;          
	        end
	      DUMP: 
			if(dump_done | cutoff_dump)begin
				FSL_S_Read	<= 0;
				state 		<= IDLE;
	        end else if (FSL_S_Exists == 1) begin
	          FSL_S_Read  <= 1;
	          state       <= fsl_dump_en? DUMP : (fsl_c_en? CAPTURE_EN : IDLE);
	        end else begin
	          FSL_S_Read  <= 0;
	          state       <= DUMP;          
	        end
	      DUMP_PAUSED:
	        if(dump_done | cutoff_dump)begin
	          FSL_S_Read  <= 0;
	          state       <= IDLE;
	        end else if(FSL_S_Exists) begin
	          FSL_S_Read  <= 1;
	          state       <= fsl_dump_en? DUMP : (fsl_c_en? CAPTURE_EN : IDLE);
	        end else begin
	          FSL_S_Read  <= 0;
	          state       <= DUMP_PAUSED;
	        end
          TEST:
			FSL_S_Read <= 0;
          	state <= FSL_M_Full? TEST : IDLE;
	    endcase

	    // Dump counting
	    if(FSL_Rst || state == CAPTURE_EN)
	      dump_count <= 0;
	    else if(state == DUMP && ~FSL_M_Full)
	      dump_count <= dump_count + 16'd1;
	    else
	      dump_count <= dump_count;

	    test_vector <= {fsl_test_echo, fsl_test};

      	// Data output
      	if(state == DUMP)begin
			FSL_M_Write <= ~FSL_M_Full;
			FSL_M_Data 	<= sh_out;
		end else if(state == TEST)begin
			FSL_M_Write <= ~FSL_M_Full;
			FSL_M_Data 	<= test_vector[0]? {16'hABC0, fsl_test_echo} : {16'hABCF, fsl_test_echo};
		end else begin
			FSL_M_Write	<= 0;
			FSL_M_Data	<= 32'h0B00B135;
		end
	end	

	//	OpenSPARC logic
	always @(posedge FSL_Clk)begin
		err_en 		<= 0;
		err_ctrl 	<= 11'b0;
		sh_rst 		<= fsl_shdw_rst;
		c_en 		<= (state == CAPTURE_EN);
		dump_en 	<= {32{(state == DUMP)}};
	end 
endmodule
