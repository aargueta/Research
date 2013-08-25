`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:28:15 01/25/2013 
// Design Name: 
// Module Name:    top 
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
module top(
    input clk,
    input up_button,
	 input [8:1] sw,
    output [3:0] leds_l,
    output [3:0] leds_r,
    output serial1_tx
    );
	 
	wire inject_errors = sw[8];
	wire reset = up_button;
	
	// Shadowing/Error Control Inputs
	wire err_en;
	wire [2:0] err_ctrl;
	wire c_en;
	wire [7:0] dump_en;
	wire dump_done;
	
	wire [7:0] ch_out;
	wire [7:0] ch_out_vld;
	wire [7:0] ch_out_done;
	 
	wire [7:0] tx_data;
	wire tx_en;
	wire serial_busy;
	
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
	
	
	uart_tx serial(
		.uart_busy(serial_busy),   // High means UART is transmitting
		.uart_tx(serial1_tx),     // UART transmit wire
		// Inputs
		.tx_en(tx_en),   // Raise to transmit byte
		.tx_data(tx_data),  // 8-bit data
		.clk(clk),   // System clock, 68 MHz
		.rst(reset)    // System reset
	);
	
	base base (
		.clk(clk), 
		.rst(reset), 
		.out(out), 
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

endmodule
