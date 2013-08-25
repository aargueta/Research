`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:43:07 01/11/2013 
// Design Name: 
// Module Name:    c_d_ctrl 
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
`define IDLE		3'b000
`define CAPTURE	3'b001
`define LABEL		3'b010
`define DUMPING	3'b011
`define PAUSED		3'b100

module c_d_ctrl(
    input clk,
    input rst,
	 input inj_err,
    input [7:0] ch_out,
    input [7:0] ch_out_vld,
    input [7:0] ch_out_done,
	 input serial_busy,
	 output err_en,
	 output reg [2:0] err_ctrl,
	 output c_en,
    output [7:0] dump_en,
    output serial_en,
    output reg [7:0] serial_tx,
	 output demo_done
	);
	wire [7:0] label = 8'hF0;
	
	wire [2:0] prevState;
	wire [2:0] state;
	reg [2:0] nextState;
	dffr_ns #(3) stateDff(
		.clk(clk),
		.rst(rst),
		.err_en(1'b0),
		.din(nextState),
		.q(state)
	);
	
	dffre_ns #(3) prevStateDff(
		.clk(clk),
		.rst(rst),
		.err_en(1'b0),
		.en(nextState != state),
		.din(state),
		.q(prevState)
	);
	
	wire [3:0] labelIndex;
	wire labelDone = (labelIndex == 4'd4);
	dffre_ns #(4) labelIndexDff(
		.clk(clk),
		.rst(rst | (state == `DUMPING)),
		.err_en(1'b0),
		.en(state == `LABEL),
		.din(labelIndex + 4'd1),
		.q(labelIndex)
	);
	
	wire [3:0] dumpNum;
	dffre_ns #(4) dumpNumState(
		.clk(clk),
		.rst(rst),
		.err_en(1'b0),
		.en(c_en),
		.din(dumpNum + 4'd1),
		.q(dumpNum)
	);
	
	assign err_en = inj_err & (dumpNum > 4'd1) & (dumpNum < 4'd6) & (state == `CAPTURE);
	
	always@(posedge clk)begin
		if(dumpNum == 4'd2)
			err_ctrl = 32;
		else if(dumpNum == 4'd3)
			err_ctrl = 64;
		else if(dumpNum == 4'd4)
			err_ctrl = 128;
		else if(dumpNum == 4'd5)
			err_ctrl = 256;
		else
			err_ctrl = 0;
	end
	
	always@(*)begin
		case(state)
			`IDLE:begin
				nextState = `CAPTURE;
			end
			`CAPTURE:begin
				nextState = `LABEL;
			end
			`LABEL:begin
				if(serial_busy)begin
					nextState = `PAUSED;
				end else if(labelDone)begin
					nextState = `DUMPING;
				end else begin
					nextState = `PAUSED;
				end
			end
			`DUMPING:begin
				if(&ch_out_done)begin
					nextState = `IDLE;
				end else begin
					if(serial_busy)begin
						nextState = `PAUSED;
					end else begin
						nextState = `PAUSED;
					end
				end
			end
			`PAUSED:begin
				if(serial_busy)begin
					nextState = `PAUSED;
				end else begin
					nextState = prevState;
				end
			end
			default:begin
				nextState = `IDLE;
			end
		endcase
	end
	assign demo_done = (dumpNum == 4'd10);
	assign c_en = demo_done? 1'b0 : (state == `CAPTURE);
	assign dump_en = demo_done? 8'b0 : {8{(state == `DUMPING)}};
	assign serial_en = demo_done? 1'b0 : (state == `DUMPING) || (state == `LABEL);
	
	always @(*)begin
		if(state == `LABEL)
			if(labelIndex == 4'd2)
				serial_tx = {4'd0, dumpNum};
			else
				serial_tx = label;
		else if(state == `DUMPING)
			serial_tx = ch_out;
		else if(c_en)
			serial_tx = 8'h0A;
		else
			serial_tx = 8'h00;
	end
		

endmodule
