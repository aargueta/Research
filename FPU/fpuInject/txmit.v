/******************************************************************************
*
*    File Name:  txmit.v
*      Version:  1.1
*         Date:  January 22, 2000
*        Model:  Uart Chip
*
*      Company:  Xilinx
*
*
*   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY 
*                WHATSOEVER AND XILINX SPECIFICALLY DISCLAIMS ANY 
*                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
*                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
*
*                Copyright (c) 2000 Xilinx, Inc.
*                All rights reserved
*
******************************************************************************/

`timescale 1 ns / 1 ns

module txmit (din,tbre,tsre,rst,clk16x,wrn,sdo) ;

output tbre ;
output tsre ;
output sdo ;
input [7:0] din ;
input rst ;
input clk16x ;
input wrn ;

reg tbre ;
reg tsre ;
reg clk1x_enable ;
reg [7:0] tsr ;
reg [7:0] tbr ;

reg parity ;

reg[3:0] clkdiv ;
wire clk1x ;
reg sdo ;
reg [3:0] no_bits_sent ;
reg wrn1 ;
reg wrn2 ;

always @(posedge clk16x or posedge rst)
begin
if (rst)
begin
wrn1 <= 1'b1 ;
wrn2 <= 1'b1 ;
end
else 
begin
wrn1 <= wrn ;
wrn2 <= wrn1 ;
end
end

always @(posedge clk16x or posedge rst)
begin
if (rst)
begin
tbre <= 1'b0 ;
clk1x_enable <= 1'b0 ;
end
else if (!wrn1 && wrn2) 
begin
clk1x_enable <= 1'b1 ;
tbre <= 1'b1 ;
end
else if (no_bits_sent == 4'b0010)
tbre <= 1'b1 ;
else if (no_bits_sent == 4'b1101)
begin
clk1x_enable <= 1'b0 ;
tbre <= 1'b0 ;
end
end

always @(negedge wrn or posedge rst)
begin
if (rst)
tbr = 8'b0 ;
else
tbr = din ;
end

always @(posedge clk16x or posedge rst)
begin
if (rst)
clkdiv = 4'b0 ; 
else if (clk1x_enable)
clkdiv = clkdiv + 1 ;
end

assign clk1x = clkdiv[3] ;

always @(negedge clk1x or posedge rst)
if (rst)
begin
sdo <= 1'b1 ;
tsre <= 1'b1 ;
parity <= 1'b1 ;
tsr <= 8'b0 ;
end
else
begin
if (no_bits_sent == 4'b0001)
begin
tsr <= tbr ;
tsre <= 1'b0 ;
end
else if (no_bits_sent == 4'b0010)
begin
sdo <= 1'b0 ;
end
else
if ((no_bits_sent >= 4'b0011) && (no_bits_sent <= 4'b1010))
begin
tsr[7:1] <= tsr[6:0] ;
tsr[0] <= 1'b0 ;
sdo <= tsr[7] ;
parity <= parity ^ tsr[7] ;
end
else if (no_bits_sent == 4'b1011)
begin
sdo <= parity ;
end
else if (no_bits_sent == 4'b1100)
begin
sdo <= 1'b1 ;
tsre <= 1'b1 ;
end

end

always @(posedge clk1x or posedge rst or negedge clk1x_enable)

if (rst) 
no_bits_sent = 4'b0000 ;
else if (!clk1x_enable)
no_bits_sent = 4'b0000 ;
else
no_bits_sent = no_bits_sent + 1 ;

endmodule

 
