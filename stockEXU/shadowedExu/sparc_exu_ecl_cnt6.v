// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_exu_ecl_cnt6.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
////////////////////////////////////////////////////////////////////////
/*
//  Module Name: sparc_exu_cnt6
//	Description: 6 bit binary counter
*/
module sparc_exu_ecl_cnt6 (/*AUTOARG*/
   // Outputs
   cntr, 
   // Inputs
   reset, clk, se

,
//*****[SHADOW CAPTURE MODULE INOUTS]*****
	sh_clk, // Shadow/data clock
	sh_rst, // Shadow/data reset
	c_en, // Capture enable
	dump_en, // Dump enable
	ch_out, // Chains out
	ch_out_vld, // Chains out valid
	ch_out_done // Chains done
   ) ;

//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****
input	sh_clk; // Shadow/data clock
input	sh_rst; // Shadow/data reset
input	c_en; // Capture enable
input	[0:0]	dump_en; // Dump enable
output	[0:0]	ch_out; // Chains out
output	[0:0]	ch_out_vld; // Chains out Valid
output	[0:0]	ch_out_done; // Chains done
   input reset;
   input clk;
   input se;
   
   output [5:0] cntr;

   wire [5:0]   next_cntr;
   wire         tog1;
   wire         tog2;
   wire         tog3;
   wire         tog4;
   wire         tog5;

   assign       tog1 = cntr[0];
   assign       tog2 = cntr[0] & cntr[1];
   assign       tog3 = cntr[0] & cntr[1] & cntr[2];
   assign       tog4 = cntr[0] & cntr[1] & cntr[2] & cntr[3];
   assign       tog5 = cntr[0] & cntr[1] & cntr[2] & cntr[3] & cntr[4];
   assign next_cntr[0] = ~reset & ~cntr[0];
   assign next_cntr[1] = ~reset & ((~cntr[1] & tog1) | (cntr[1] & ~tog1)); 
   assign next_cntr[2] = ~reset & ((~cntr[2] & tog2) | (cntr[2] & ~tog2)); 
   assign next_cntr[3] = ~reset & ((~cntr[3] & tog3) | (cntr[3] & ~tog3)); 
   assign next_cntr[4] = ~reset & ((~cntr[4] & tog4) | (cntr[4] & ~tog4)); 
   assign next_cntr[5] = ~reset & ((~cntr[5] & tog5) | (cntr[5] & ~tog5)); 
   

   // counter flop
   dff_s #(6) cntr_dff(.din(next_cntr[5:0]), .clk(clk), .q(cntr[5:0]), .se(se), .si(), .so());

//[Shadow Module Instantiation here]
shadow_capture #(.DFF_BITS(6),.USE_DCLK(1),.CHAINS_IN(0),.CHAINS_OUT(1)) shadow_capture_sparc_exu_ecl_cnt6 (
      .clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
      .dclk({{6{clk}}}), 
		.din({cntr[5:0]}),
		.dump_en(dump_en), 
		.chains_in(), 
		.chains_in_vld(), 
		.chains_in_done(), 
		.chain_dump_en(), 
		.chains_out(ch_out), 
		.chains_out_vld(ch_out_vld), 
      .chains_out_done(ch_out_done)
  );
endmodule // sparc_exu_ecl_cnt6
