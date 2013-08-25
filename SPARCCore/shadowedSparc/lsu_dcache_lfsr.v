// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: lsu_dcache_lfsr.v
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
//  Module Name: lsu_dcache_lfsr
*/
////////////////////////////////////////////////////////////////////////

module lsu_dcache_lfsr (/*AUTOARG*/
   // Outputs
   out, 
   // Inputs
   advance, clk, se, si, so, reset

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

   input 	advance;
   
   input 	clk, se, si, so, reset;

   output [1:0] out;

   reg [4:0]    q_next;
   wire [4:0]   q;
   

/*
   always @ (posedge clk)
     begin
	out = $random;
     end // always @ posedge
 */

//   always @ (posedge clk)
//     begin
//	q[4:0] <= q_next[4:0];
//     end

   always @ (/*AUTOSENSE*/advance or q or reset)
     begin
	      if (reset)
	        q_next = 5'b11111;
	      else if (advance)
	        begin
	           // lfsr -- stable at 000000, period of 63
	           q_next[1] = q[0];
	           q_next[2] = q[1];
	           q_next[3] = q[2];
	           q_next[4] = q[3];
	           q_next[0] = q[1] ^ q[4];
	        end
	      else
	        q_next = q;
     end // always @ (...

   assign out = {q[0], q[2]};

   dff_s #(5) lfsr_reg(.din  (q_next),
                     .q    (q),
                     .clk  (clk), .se(se), .si(), .so());
   

	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(5), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(1), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd5})) shadow_capture_lsu_dcache_lfsr (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({clk}), 
		.din({q}),
		.dump_en(dump_en), 
		.chains_in(), 
		.chains_in_vld(), 
		.chains_in_done(), 
		.chain_dump_en(), 
		.chains_out(ch_out), 
		.chains_out_vld(ch_out_vld), 
		.chains_out_done(ch_out_done)
	);
endmodule // lsu_dcache_lfsr

		
	       

