// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_ifu_rndrob.v
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
//  Module Name: sparc_ifu_rndrob
//  Description:	
//  Round robin scheduler.  Least priority to the last granted
//  customer.  If no requests, the priority remains the same. 
//
*/
////////////////////////////////////////////////////////////////////////

module sparc_ifu_rndrob(/*AUTOARG*/
   // Outputs
   grant_vec, so, 
   // Inputs
   clk, reset, se, si, req_vec, advance, rst_tri_enable

,
//*****[SHADOW CAPTURE MODULE INOUTS]*****
	sh_clk, // Shadow/data clock
	sh_rst, // Shadow/data reset
	c_en, // Capture enable
	dump_en, // Dump enable
	ch_out, // Chains out
	ch_out_vld, // Chains out valid
	ch_out_done // Chains done
   );

	//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****
	input	sh_clk; // Shadow/data clock
	input	sh_rst; // Shadow/data reset
	input	c_en; // Capture enable
	input	[0:0]	dump_en; // Dump enable
	output	[0:0]	ch_out; // Chains out
	output	[0:0]	ch_out_vld; // Chains out Valid
	output	[0:0]	ch_out_done; // Chains done

   input     clk, reset, se, si;

   input [3:0]  req_vec;
   
   input 	advance;
   input 	rst_tri_enable;
   
   output [3:0] grant_vec;
   
   output 	so;

   wire [3:0] 	next_pv,
		pv,
		gv,
		park_vec;
   
   
   assign 	pv =  advance ? grant_vec : 
	                        park_vec;

   assign 	next_pv[3:1] = pv[3:1] & {3{~reset}};
   assign 	next_pv[0] = pv[0] | reset;
   
   dff_s #4  park_reg(.din  (next_pv),
		    .clk  (clk),
		    .q    (park_vec),
		    .se   (se), .si(), .so());

   // if noone requests, don't advance, otherwise we'll go back to 0
   // and will not be fair to other requestors
   assign gv[0] = park_vec[3] & req_vec[0] |
		  park_vec[2] & ~req_vec[3] & req_vec[0] |
		  park_vec[1] & ~req_vec[2] & ~req_vec[3] & req_vec[0] |
	          ~req_vec[1] & ~req_vec[2] & ~req_vec[3];
   
   assign gv[1] = park_vec[0] & req_vec[1] |
		  park_vec[3] & ~req_vec[0] & req_vec[1] |
		  park_vec[2] & ~req_vec[3] & ~req_vec[0] & req_vec[1] |
	          req_vec[1] & ~req_vec[2] & ~req_vec[3] & ~req_vec[0];

   assign gv[2] = park_vec[1] & req_vec[2] |
		  park_vec[0] & ~req_vec[1] & req_vec[2] |
		  park_vec[3] & ~req_vec[0] & ~req_vec[1] & req_vec[2] |
		  req_vec[2] & ~req_vec[3] & ~req_vec[0] & ~req_vec[1];

   assign gv[3] = park_vec[2] & req_vec[3] |
		  park_vec[1] & ~req_vec[2] & req_vec[3] |
		  park_vec[0] & ~req_vec[1] & ~req_vec[2] & req_vec[3] |
		  req_vec[3] & ~req_vec[0] & ~req_vec[1] & ~req_vec[2];

   assign grant_vec[0] = gv[0] | rst_tri_enable;
   assign grant_vec[3:1] = gv[3:1] & {3{~rst_tri_enable}};
   


	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(4), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(1), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd4})) shadow_capture_sparc_ifu_rndrob (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({clk}), 
		.din({park_vec}),
		.dump_en(dump_en), 
		.chains_in(), 
		.chains_in_vld(), 
		.chains_in_done(), 
		.chain_dump_en(), 
		.chains_out(ch_out), 
		.chains_out_vld(ch_out_vld), 
		.chains_out_done(ch_out_done)
	);
endmodule // sparc_ifu_rndrob

   
   
