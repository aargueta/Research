`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:00:00 01/10/2013 
// Design Name: 
// Module Name:    uart_tx 
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
module uart_tx(
   // Outputs
   uart_busy,   // High means UART is transmitting
   uart_tx,     // UART transmit wire
   // Inputs
   tx_en,   // Raise to transmit byte
   tx_data,  // 8-bit data
   clk,   // System clock, 68 MHz
   rst    // System reset
);

  input tx_en;
  input [7:0] tx_data;
  input clk;
  input rst;

  output uart_busy;
  output uart_tx;

  reg [3:0] bitcount;
  reg [8:0] shifter;
  reg uart_tx;

  wire uart_busy = |bitcount[3:1];
  wire sending = |bitcount;

  // clk is 1.152MHz.  We want a 115200Hz clock

  reg [28:0] d;
  wire [28:0] dInc = d[28] ? (115200) : (115200 - 68000000);
  wire [28:0] dNxt = d + dInc;
  always @(posedge clk)
  begin
    d = rst? 28'd0 : dNxt;
  end
  wire ser_clk = ~d[28]; // this is the 115200 Hz clock

  always @(posedge clk)
  begin
    if (rst) begin
      uart_tx <= 1;
      bitcount <= 0;
      shifter <= 0;
    end else begin
      // just got a new byte
      if (tx_en & ~uart_busy) begin
        shifter <= { tx_data[7:0], 1'h0 };
        bitcount <= (1 + 8 + 2);
      end

      if (sending & ser_clk) begin
        { shifter, uart_tx } <= { 1'h1, shifter };
        bitcount <= bitcount - 1;
      end
    end
  end

endmodule
