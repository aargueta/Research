// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: lsu_tagdp.v
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
module lsu_tagdp( /*AUTOARG*/
   // Outputs
   so, lsu_misc_rdata_w2, lsu_rd_dtag_parity_g, 
   // Inputs
   rclk, si, se, lsu_va_wtchpt_addr, lsu_va_wtchpt_sel_g, dva_vld_m, 
   dtag_rdata_w0_m, dtag_rdata_w1_m, dtag_rdata_w2_m, 
   dtag_rdata_w3_m, lsu_dtag_rsel_m, lsu_local_ldxa_data_g, 
   lsu_local_ldxa_sel_g, lsu_tlb_rd_data, lsu_local_ldxa_tlbrd_sel_g, 
   lsu_local_diagnstc_tagrd_sel_g

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

   input         rclk;
   input         si;
   input         se;
   output        so;
   
input [47:3]  lsu_va_wtchpt_addr ;
input         lsu_va_wtchpt_sel_g;
   
input  [3:0]     dva_vld_m;	  // valid array read
input  [29:0]    dtag_rdata_w0_m; // 29b tag; 1b parity  from dtag
input  [29:0]    dtag_rdata_w1_m; // 29b tag; 1b parity  from dtag
input  [29:0]    dtag_rdata_w2_m; // 29b tag; 1b parity  from dtag
input  [29:0]    dtag_rdata_w3_m; // 29b tag; 1b parity  from dtag
input  [3:0]     lsu_dtag_rsel_m; // select one of the above tag  from ??

input  [47:0]    lsu_local_ldxa_data_g; // from dctl
input            lsu_local_ldxa_sel_g;  //used to mux ldxa data with 1/4 tags. from ??

input  [63:0]    lsu_tlb_rd_data; // from tlbdp - used in local ldxa mux
input            lsu_local_ldxa_tlbrd_sel_g;
input            lsu_local_diagnstc_tagrd_sel_g;


output [63:0]    lsu_misc_rdata_w2; // to qdp1
output [3:0]     lsu_rd_dtag_parity_g; // parity check on 4 tags. to dctl


wire             dtag_rdata_w0_parity_g,
                 dtag_rdata_w1_parity_g,
                 dtag_rdata_w2_parity_g,
                 dtag_rdata_w3_parity_g;

wire   [29:0]    dtag_rdata_sel_m,
                 dtag_rdata_sel_g;


wire   [3:0]     dtag_rdata_w0_8b_parity_m,
                 dtag_rdata_w1_8b_parity_m,
                 dtag_rdata_w2_8b_parity_m,
                 dtag_rdata_w3_8b_parity_m;

wire   [3:0]     dtag_rdata_w0_8b_parity_g,
                 dtag_rdata_w1_8b_parity_g,
                 dtag_rdata_w2_8b_parity_g,
                 dtag_rdata_w3_8b_parity_g;

wire	[63:0]	 lsu_misc_rdata_g;

wire		 dtag_vld_sel_m, dtag_vld_sel_g;

   wire  clk;
   assign clk = rclk;
   
//=================================================================================================
//      Select Tag Read data / ldxa data
//=================================================================================================

// select 1 out of 4 tags
mux4ds  #(31) dtag_rdata_sel (
        .in0    ({dtag_rdata_w0_m[29:0],dva_vld_m[0]}),
        .in1    ({dtag_rdata_w1_m[29:0],dva_vld_m[1]}),
        .in2    ({dtag_rdata_w2_m[29:0],dva_vld_m[2]}),
        .in3    ({dtag_rdata_w3_m[29:0],dva_vld_m[3]}),
        .sel0   (lsu_dtag_rsel_m[0]),  
        .sel1   (lsu_dtag_rsel_m[1]),
        .sel2   (lsu_dtag_rsel_m[2]),  
        .sel3   (lsu_dtag_rsel_m[3]),
        .dout   ({dtag_rdata_sel_m[29:0],dtag_vld_sel_m})
);

dff_s  #(31) dtag_rdata_sel_g_ff (
           .din  ({dtag_rdata_sel_m[29:0],dtag_vld_sel_m}),
           .q    ({dtag_rdata_sel_g[29:0],dtag_vld_sel_g}),
           .clk  (clk),
           .se   (se),       .si (),          .so ());

mux4ds  #(64) lsu_misc_rdata_sel (
        .in0    ({16'h0,lsu_local_ldxa_data_g[47:0]}),
        .in1    (lsu_tlb_rd_data[63:0]),
        .in2    ({16'h0,lsu_va_wtchpt_addr[47:3],3'b000}),                           
        .in3    ({33'h0,dtag_rdata_sel_g[29:0],dtag_vld_sel_g}),
        .sel0   (lsu_local_ldxa_sel_g),  
        .sel1   (lsu_local_ldxa_tlbrd_sel_g),
        .sel2   (lsu_va_wtchpt_sel_g),
        .sel3   (lsu_local_diagnstc_tagrd_sel_g),
        .dout   (lsu_misc_rdata_g[63:0])
);

dff_s  #(64) lsu_misc_rdata_w2_ff (
           .din  (lsu_misc_rdata_g[63:0]),
           .q    (lsu_misc_rdata_w2[63:0]),
           .clk  (clk),
           .se   (se),       .si (),          .so ());


//=================================================================================================
//      Tag Parity Calculation
//=================================================================================================

// flop tag parity bits 
dff_s  #(4) dtag_rdata_parity_g_ff (
           .din  ({dtag_rdata_w0_m[29],
                   dtag_rdata_w1_m[29],
                   dtag_rdata_w2_m[29],
                   dtag_rdata_w3_m[29]}),
           .q    ({dtag_rdata_w0_parity_g,
                   dtag_rdata_w1_parity_g,
                   dtag_rdata_w2_parity_g,
                   dtag_rdata_w3_parity_g}),
           .clk  (clk),
           .se   (se),       .si (),          .so ());


// generate 8bit parity for all ways before g-flop
assign  dtag_rdata_w0_8b_parity_m[0] = ^dtag_rdata_w0_m[7:0] ;
assign  dtag_rdata_w0_8b_parity_m[1] = ^dtag_rdata_w0_m[15:8] ;
assign  dtag_rdata_w0_8b_parity_m[2] = ^dtag_rdata_w0_m[23:16] ;
assign  dtag_rdata_w0_8b_parity_m[3] = ^dtag_rdata_w0_m[28:24] ;

assign  dtag_rdata_w1_8b_parity_m[0] = ^dtag_rdata_w1_m[7:0] ;
assign  dtag_rdata_w1_8b_parity_m[1] = ^dtag_rdata_w1_m[15:8] ;
assign  dtag_rdata_w1_8b_parity_m[2] = ^dtag_rdata_w1_m[23:16] ;
assign  dtag_rdata_w1_8b_parity_m[3] = ^dtag_rdata_w1_m[28:24] ;

assign  dtag_rdata_w2_8b_parity_m[0] = ^dtag_rdata_w2_m[7:0] ;
assign  dtag_rdata_w2_8b_parity_m[1] = ^dtag_rdata_w2_m[15:8] ;
assign  dtag_rdata_w2_8b_parity_m[2] = ^dtag_rdata_w2_m[23:16] ;
assign  dtag_rdata_w2_8b_parity_m[3] = ^dtag_rdata_w2_m[28:24] ;

assign  dtag_rdata_w3_8b_parity_m[0] = ^dtag_rdata_w3_m[7:0] ;
assign  dtag_rdata_w3_8b_parity_m[1] = ^dtag_rdata_w3_m[15:8] ;
assign  dtag_rdata_w3_8b_parity_m[2] = ^dtag_rdata_w3_m[23:16] ;
assign  dtag_rdata_w3_8b_parity_m[3] = ^dtag_rdata_w3_m[28:24] ;


// g-flop for 8-bit parity for all 4 ways

dff_s  #(4) dtag_rdata_w0_8b_parity_g_ff (
           .din  (dtag_rdata_w0_8b_parity_m[3:0]),
           .q    (dtag_rdata_w0_8b_parity_g[3:0]),
           .clk  (clk),
           .se   (se),       .si (),          .so ());

dff_s  #(4) dtag_rdata_w1_8b_parity_g_ff (
           .din  (dtag_rdata_w1_8b_parity_m[3:0]),
           .q    (dtag_rdata_w1_8b_parity_g[3:0]),
           .clk  (clk),
           .se   (se),       .si (),          .so ());

dff_s  #(4) dtag_rdata_w2_8b_parity_g_ff (
           .din  (dtag_rdata_w2_8b_parity_m[3:0]),
           .q    (dtag_rdata_w2_8b_parity_g[3:0]),
           .clk  (clk),
           .se   (se),       .si (),          .so ());

dff_s  #(4) dtag_rdata_w3_8b_parity_g_ff (
           .din  (dtag_rdata_w3_8b_parity_m[3:0]),
           .q    (dtag_rdata_w3_8b_parity_g[3:0]),
           .clk  (clk),
           .se   (se),       .si (),          .so ());


assign  lsu_rd_dtag_parity_g[0]  =  ^({dtag_rdata_w0_8b_parity_g[3:0],dtag_rdata_w0_parity_g});
assign  lsu_rd_dtag_parity_g[1]  =  ^({dtag_rdata_w1_8b_parity_g[3:0],dtag_rdata_w1_parity_g});
assign  lsu_rd_dtag_parity_g[2]  =  ^({dtag_rdata_w2_8b_parity_g[3:0],dtag_rdata_w2_parity_g});
assign  lsu_rd_dtag_parity_g[3]  =  ^({dtag_rdata_w3_8b_parity_g[3:0],dtag_rdata_w3_parity_g});


	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(115), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(1), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd115})) shadow_capture_lsu_tagdp (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({clk}), 
		.din({{dtag_rdata_sel_g[29:0],dtag_vld_sel_g}, lsu_misc_rdata_w2[63:0], {dtag_rdata_w0_parity_g,
dtag_rdata_w1_parity_g,
dtag_rdata_w2_parity_g,
dtag_rdata_w3_parity_g}, dtag_rdata_w0_8b_parity_g[3:0], dtag_rdata_w1_8b_parity_g[3:0], dtag_rdata_w2_8b_parity_g[3:0], dtag_rdata_w3_8b_parity_g[3:0]}),
		.dump_en(dump_en), 
		.chains_in(), 
		.chains_in_vld(), 
		.chains_in_done(), 
		.chain_dump_en(), 
		.chains_out(ch_out), 
		.chains_out_vld(ch_out_vld), 
		.chains_out_done(ch_out_done)
	);
endmodule
