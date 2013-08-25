// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_exu_rml_cwp.v
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
//  Module Name: sparc_exu_rml_cwp
//	Description: Register management logic.  Contains CWP, CANSAVE, CANRESTORE
//		and other window management registers.  Generates RF related traps
//  		and switches the global registers to alternate globals.  All the registers
//		are written in the W stage (there is no bypassing so they must
//		swap out) and will either get a new value generated by a window management
//		Instruction or by a WRPS instruction.  The following traps can be generated:
//			Fill: restore with canrestore == 0
//			clean_window: save with cleanwin-canrestore == 0
//			spill: flushw with cansave != nwindows -2 or
//				save with cansave == 0
//		It is assumed that the contents of the new window will get squashed
//		on a clean_window or fill trap so the save or restore gets executed
//		normally.  Spill traps or WRCWPs mean that all 16 windowed registers
//		must be saved and restored (a 4 cycle operation).
*/
module sparc_exu_rml_cwp (/*AUTOARG*/
   // Outputs
   rml_ecl_cwp_d, rml_ecl_cwp_e, exu_tlu_cwp0_w, exu_tlu_cwp1_w, 
   exu_tlu_cwp2_w, exu_tlu_cwp3_w, rml_irf_cwpswap_tid_e, old_cwp_e, 
   new_cwp_e, swap_locals_ins, swap_outs, exu_tlu_spill, 
   exu_tlu_spill_wtype, exu_tlu_spill_other, exu_tlu_spill_tid, 
   rml_ecl_swap_done, exu_tlu_cwp_cmplt, exu_tlu_cwp_cmplt_tid, 
   exu_tlu_cwp_retry, oddwin_w, 
   // Inputs
   clk, se, reset, rst_tri_en, rml_ecl_wtype_e, rml_ecl_other_e, 
   exu_tlu_spill_e, tlu_exu_cwpccr_update_m, tlu_exu_cwp_retry_m, 
   tlu_exu_cwp_m, thr_d, ecl_rml_thr_m, ecl_rml_thr_w, tid_e, 
   next_cwp_w, next_cwp_e, cwp_wen_w, save_e, restore_e, 
   ifu_exu_flushw_e, ecl_rml_cwp_wen_e, full_swap_e, rml_kill_w
   ) ;
   input clk;
   input se;
   input reset;
   input rst_tri_en;
   input [2:0] rml_ecl_wtype_e;
   input       rml_ecl_other_e;
   input       exu_tlu_spill_e;
   input       tlu_exu_cwpccr_update_m;
   input       tlu_exu_cwp_retry_m;
   input [2:0] tlu_exu_cwp_m; // for switching cwp on return from trap
   input [3:0] thr_d;
   input [3:0] ecl_rml_thr_m;
   input [3:0] ecl_rml_thr_w;
   input [1:0] tid_e;
   input [2:0] next_cwp_w;
   input [2:0] next_cwp_e;
   input       cwp_wen_w;
   input       save_e;
   input       restore_e;
   input       ifu_exu_flushw_e;
   input       ecl_rml_cwp_wen_e;
   input       full_swap_e;
   input       rml_kill_w;

   output [2:0] rml_ecl_cwp_d;
   output [2:0] rml_ecl_cwp_e;
   output [2:0] exu_tlu_cwp0_w;
   output [2:0] exu_tlu_cwp1_w;
   output [2:0] exu_tlu_cwp2_w;
   output [2:0] exu_tlu_cwp3_w;
   output [1:0] rml_irf_cwpswap_tid_e;
   output [2:0] old_cwp_e;
   output [2:0] new_cwp_e;
   output       swap_locals_ins;
   output       swap_outs;
   output      exu_tlu_spill;
   output [2:0] exu_tlu_spill_wtype;
   output       exu_tlu_spill_other;
   output [1:0] exu_tlu_spill_tid;
   output [3:0] rml_ecl_swap_done;
   output       exu_tlu_cwp_cmplt;
   output [1:0] exu_tlu_cwp_cmplt_tid;
   output       exu_tlu_cwp_retry;
   output [3:0] oddwin_w;
   
   wire         can_swap;
   wire         swapping;
   wire         just_swapped;
   wire         full_swap_m;
   wire         full_swap_w;
   wire [3:0]   swap_done_next_cycle;
   wire [3:0] swap_sel_input;
   wire [3:0] swap_sel_tlu;
   wire [3:0] swap_keep_value;
   wire [2:0]  trap_old_cwp_m;
   wire   tlu_cwp_no_change;
   wire [2:0] tlu_cwp_xor;
   wire   cwp_cmplt_next;
   wire [1:0] cwp_cmplt_tid_next;
   wire       cwp_retry_next;
   wire   cwp_fastcmplt_m;
   wire   cwp_fastcmplt_w;
   wire   cwpccr_update_w;
   wire   valid_tlu_swap_w;
   wire [2:0] tlu_exu_cwp_w;
   wire       tlu_exu_cwp_retry_w;

   wire [3:0] swap_thr;
   wire [1:0] swap_tid;
   wire [3:0] swap_req_vec;
   wire       kill_swap_slot_w;
   wire [3:0] thr_e;
   
   wire [1:0] swap_slot0_state;
   wire [1:0] swap_slot1_state;
   wire [1:0] swap_slot2_state;
   wire [1:0] swap_slot3_state;
   wire [1:0] swap_slot0_state_valid;
   wire [1:0] swap_slot1_state_valid;
   wire [1:0] swap_slot2_state_valid;
   wire [1:0] swap_slot3_state_valid;
   wire [1:0] next_slot0_state;
   wire [1:0] next_slot1_state;
   wire [1:0] next_slot2_state;
   wire [1:0] next_slot3_state;
   wire [3:0] swap_keep_state;
   wire [3:0] swap_next_state;
   wire [1:0] swap_state;

   wire [3:0] next_swap_thr;
   wire [12:0] swap_data;
   wire [12:0] tlu_swap_data;
   wire [12:0] swap_input_data;
   wire [12:0] next_slot0_data;
   wire [12:0] next_slot1_data;
   wire [12:0] next_slot2_data;
   wire [12:0] next_slot3_data;
   wire [12:0] swap_slot0_data;
   wire [12:0] swap_slot1_data;
   wire [12:0] swap_slot2_data;
   wire [12:0] swap_slot3_data;

   wire        new_cwp_sel_swap;
   wire [2:0]  old_swap_cwp;
   wire [2:0]  new_swap_cwp;

   
   // wires for cwp register
   wire [2:0]   cwp_thr0;
   wire [2:0]   cwp_thr1;
   wire [2:0]   cwp_thr2;
   wire [2:0]   cwp_thr3;
   wire [2:0]   cwp_thr0_next;
   wire [2:0]   cwp_thr1_next;
   wire [2:0]   cwp_thr2_next;
   wire [2:0]   cwp_thr3_next;
   wire          cwp_wen_thr0_w;
   wire          cwp_wen_thr1_w;
   wire          cwp_wen_thr2_w;
   wire          cwp_wen_thr3_w;
   wire [3:0]    cwp_wen_tlu_w;
   wire [3:0] cwp_wen_spill;
   wire [2:0] spill_cwp;
   wire [3:0]    cwp_wen_l;
   wire [2:0]    old_cwp_w;
   wire        spill_next;
   wire [1:0]  spill_tid_next;
   wire        spill_other_next;
   wire [2:0]  spill_wtype_next;

   // decode thr_e
   assign        thr_e[0] = ~tid_e[1] & ~tid_e[0];
   assign        thr_e[1] = ~tid_e[1] & tid_e[0];
   assign        thr_e[2] = tid_e[1] & ~tid_e[0];
   assign        thr_e[3] = tid_e[1] & tid_e[0];
   
   /////////////////////////////////
   // CWP output to IRF
   /////////////////////////////////
   // Output current_d thr on saves or restores
   mux2ds #(2) irf_thr_mux(.dout(rml_irf_cwpswap_tid_e[1:0]),
                              .in0(tid_e[1:0]),
                              .in1(swap_tid[1:0]),
                              .sel0(~can_swap),
                              .sel1(can_swap));
   // Output cwp_e for save, restore, flushw
   // and swap_cwp from queue for swap restores (default)
   // Need to have an incremented cwp for swap of outs
   assign        old_swap_cwp[2:0] = swap_data[2:0];
   assign        new_swap_cwp[2:0] = swap_data[5:3];
   
   assign        new_cwp_sel_swap = can_swap;

   assign new_cwp_e[2:0] = (new_cwp_sel_swap)?  new_swap_cwp[2:0]: next_cwp_e[2:0];
   assign old_cwp_e[2:0] = (new_cwp_sel_swap)?  old_swap_cwp[2:0]: rml_ecl_cwp_e[2:0];
   
 
   /////////////////////////////////
   // CWP register
   /////////////////////////////////
   assign exu_tlu_cwp0_w[2:0] = cwp_thr0[2:0];
   assign exu_tlu_cwp1_w[2:0] = cwp_thr1[2:0];
   assign exu_tlu_cwp2_w[2:0] = cwp_thr2[2:0];
   assign exu_tlu_cwp3_w[2:0] = cwp_thr3[2:0];
   
   mux4ds #(3) mux_cwp_old_w(.dout(old_cwp_w[2:0]), .sel0(ecl_rml_thr_w[0]),
                             .sel1(ecl_rml_thr_w[1]), .sel2(ecl_rml_thr_w[2]),
                             .sel3(ecl_rml_thr_w[3]), .in0(cwp_thr0[2:0]),
                             .in1(cwp_thr1[2:0]), .in2(cwp_thr2[2:0]),
                             .in3(cwp_thr3[2:0]));

   //  Output selection for reg
   mux4ds #(3) mux_cwp_out_d(.dout(rml_ecl_cwp_d[2:0]), .sel0(thr_d[0]),
                             .sel1(thr_d[1]), .sel2(thr_d[2]),
                             .sel3(thr_d[3]), .in0(cwp_thr0[2:0]),
                             .in1(cwp_thr1[2:0]), .in2(cwp_thr2[2:0]),
                             .in3(cwp_thr3[2:0]));
   mux4ds #(3) mux_cwp_out_e(.dout(rml_ecl_cwp_e[2:0]), .sel0(thr_e[0]),
                             .sel1(thr_e[1]), .sel2(thr_e[2]),
                             .sel3(thr_e[3]), .in0(cwp_thr0[2:0]),
                             .in1(cwp_thr1[2:0]), .in2(cwp_thr2[2:0]),
                             .in3(cwp_thr3[2:0]));
   mux4ds #(3) mux_cwp_trap(.dout(trap_old_cwp_m[2:0]), .sel0(ecl_rml_thr_m[0]),
                             .sel1(ecl_rml_thr_m[1]), .sel2(ecl_rml_thr_m[2]),
                             .sel3(ecl_rml_thr_m[3]), .in0(cwp_thr0[2:0]),
                             .in1(cwp_thr1[2:0]), .in2(cwp_thr2[2:0]),
                             .in3(cwp_thr3[2:0]));

   //////////////////////////////////////
   //  Storage of cwp
   //////////////////////////////////////
   // enable input for each thread
   assign     cwp_wen_spill[3:0] = swap_thr[3:0] & {4{spill_next}};
   assign        cwp_wen_thr0_w = ((ecl_rml_thr_w[0] & cwp_wen_w)) & ~cwp_wen_spill[0];
   assign        cwp_wen_thr1_w = ((ecl_rml_thr_w[1] & cwp_wen_w)) & ~cwp_wen_spill[1];
   assign        cwp_wen_thr2_w = ((ecl_rml_thr_w[2] & cwp_wen_w)) & ~cwp_wen_spill[2];
   assign        cwp_wen_thr3_w = ((ecl_rml_thr_w[3] & cwp_wen_w)) & ~cwp_wen_spill[3];
   assign        cwp_wen_tlu_w[3:0] = ecl_rml_thr_w[3:0] & {4{valid_tlu_swap_w}} & ~cwp_wen_spill &
                                       {~cwp_wen_thr3_w,~cwp_wen_thr2_w,~cwp_wen_thr1_w,~cwp_wen_thr0_w};
   assign        cwp_wen_l[3:0] = ~(cwp_wen_tlu_w[3:0] | cwp_wen_spill[3:0] |
                                    {cwp_wen_thr3_w,cwp_wen_thr2_w, cwp_wen_thr1_w,cwp_wen_thr0_w});

   // oddwin_w is the new value of cwp[0]
   assign        oddwin_w[3:0] = {cwp_thr3_next[0],cwp_thr2_next[0],cwp_thr1_next[0],cwp_thr0_next[0]};
   // mux between new and current value
   mux4ds #(3) cwp_next0_mux(.dout(cwp_thr0_next[2:0]),
                             .in0(cwp_thr0[2:0]),
                             .in1(next_cwp_w[2:0]),
                             .in2(tlu_exu_cwp_w[2:0]),
                             .in3(spill_cwp[2:0]),
                             .sel0(cwp_wen_l[0]),
                             .sel1(cwp_wen_thr0_w),
                             .sel2(cwp_wen_tlu_w[0]),
                             .sel3(cwp_wen_spill[0]));
   mux4ds #(3) cwp_next1_mux(.dout(cwp_thr1_next[2:0]),
                             .in0(cwp_thr1[2:0]),
                             .in1(next_cwp_w[2:0]),
                             .in2(tlu_exu_cwp_w[2:0]),
                             .in3(spill_cwp[2:0]),
                             .sel0(cwp_wen_l[1]),
                             .sel1(cwp_wen_thr1_w),
                             .sel2(cwp_wen_tlu_w[1]),
                             .sel3(cwp_wen_spill[1]));
   mux4ds #(3) cwp_next2_mux(.dout(cwp_thr2_next[2:0]),
                             .in0(cwp_thr2[2:0]),
                             .in1(next_cwp_w[2:0]),
                             .in2(tlu_exu_cwp_w[2:0]),
                             .in3(spill_cwp[2:0]),
                             .sel0(cwp_wen_l[2]),
                             .sel1(cwp_wen_thr2_w),
                             .sel2(cwp_wen_tlu_w[2]),
                             .sel3(cwp_wen_spill[2]));
   mux4ds #(3) cwp_next3_mux(.dout(cwp_thr3_next[2:0]),
                             .in0(cwp_thr3[2:0]),
                             .in1(next_cwp_w[2:0]),
                             .in2(tlu_exu_cwp_w[2:0]),
                             .in3(spill_cwp[2:0]),
                             .sel0(cwp_wen_l[3]),
                             .sel1(cwp_wen_thr3_w),
                             .sel2(cwp_wen_tlu_w[3]),
                             .sel3(cwp_wen_spill[3]));

   // store new value
   dff_s #(3) dff_cwp_thr0(.din(cwp_thr0_next[2:0]), .clk(clk), .q(cwp_thr0[2:0]),
                       .se(se), .si(), .so());
   dff_s #(3) dff_cwp_thr1(.din(cwp_thr1_next[2:0]), .clk(clk), .q(cwp_thr1[2:0]),
                       .se(se), .si(), .so());
   dff_s #(3) dff_cwp_thr2(.din(cwp_thr2_next[2:0]), .clk(clk), .q(cwp_thr2[2:0]),
                       .se(se), .si(), .so());
   dff_s #(3) dff_cwp_thr3(.din(cwp_thr3_next[2:0]), .clk(clk), .q(cwp_thr3[2:0]),
                       .se(se), .si(), .so());



   ////////////////////////////////////////////
   // Queue for full window swaps
   ////////////////////////////////////////////
   // A full swap of the current window requires a 2 cycle operation.
   // Each cycle must make sure that
   // there isn't another instruction trying to save or restore on top of it.
   // The same thread also cannot issue a swap to irf in back-to-back cycles.
   // Data is stored as follows:
   //   2:0 - CWP
   //   5:3 - NewCWP
   //   6   - !WRCWP/SPILL
   //   7   - Trap return
   //   8   - OTHER (for spill trap)
   //   11:9- WTYPE (for spill trap)
   //		12  - Retry (for trap return)
   dff_s full_swap_e2m(.din(full_swap_e), .clk(clk), .q(full_swap_m), .se(se), .si(), .so());
   dff_s full_swap_m2w(.din(full_swap_m), .clk(clk), .q(full_swap_w), .se(se), .si(), .so());
   assign     swap_input_data = {1'b0, rml_ecl_wtype_e[2:0], rml_ecl_other_e, 1'b0, exu_tlu_spill_e, 
                                 next_cwp_e[2:0],rml_ecl_cwp_e[2:0]};
   assign     tlu_swap_data = {tlu_exu_cwp_retry_w, 4'b0, 1'b1, 1'b0, tlu_exu_cwp_w[2:0], old_cwp_w[2:0]};


   assign     swap_sel_input[3:0] = thr_e[3:0] & {4{full_swap_e}};
   assign     swap_sel_tlu[3:0] = ecl_rml_thr_w[3:0] & {4{cwpccr_update_w}} 
                                    & ~swap_sel_input[3:0];
   assign     swap_keep_value[3:0] = ~(swap_sel_tlu[3:0] | swap_sel_input[3:0]);
   assign     swap_keep_state[3:0] = ~(swap_sel_tlu[3:0] | swap_sel_input[3:0]) & 
                                        ~(swap_thr[3:0] & {4{can_swap}});
   assign     swap_next_state[3:0] = ~(swap_sel_tlu[3:0] | swap_sel_input[3:0]) 
                                         & (swap_thr[3:0] & {4{can_swap}});
   mux3ds #(13) slot0_data_mux(.dout(next_slot0_data[12:0]),
                               .in0(swap_input_data[12:0]),
                               .in1(tlu_swap_data[12:0]),
                               .in2(swap_slot0_data[12:0]),
                               .sel0(swap_sel_input[0]),
                               .sel1(swap_sel_tlu[0]),
                               .sel2(swap_keep_value[0]));
   mux3ds #(13) slot1_data_mux(.dout(next_slot1_data[12:0]),
                               .in0(swap_input_data[12:0]),
                               .in1(tlu_swap_data[12:0]),
                               .in2(swap_slot1_data[12:0]),
                               .sel0(swap_sel_input[1]),
                               .sel1(swap_sel_tlu[1]),
                               .sel2(swap_keep_value[1]));
   mux3ds #(13) slot2_data_mux(.dout(next_slot2_data[12:0]),
                               .in0(swap_input_data[12:0]),
                               .in1(tlu_swap_data[12:0]),
                               .in2(swap_slot2_data[12:0]),
                               .sel0(swap_sel_input[2]),
                               .sel1(swap_sel_tlu[2]),
                               .sel2(swap_keep_value[2]));
   mux3ds #(13) slot3_data_mux(.dout(next_slot3_data[12:0]),
                               .in0(swap_input_data[12:0]),
                               .in1(tlu_swap_data[12:0]),
                               .in2(swap_slot3_data[12:0]),
                               .sel0(swap_sel_input[3]),
                               .sel1(swap_sel_tlu[3]),
                               .sel2(swap_keep_value[3]));

   // Muxes for slot state.
   // There are 2 possible states:
   // No swap done (01)
   // Swap locals/ins done (10)
   mux4ds #(2) slot0_state_mux(.dout(next_slot0_state[1:0]),
                               .in0(2'b10),
                               .in1({1'b0, valid_tlu_swap_w}),
                               .in2(swap_slot0_state_valid[1:0]),
                               .in3({swap_slot0_state_valid[0], 1'b0}),
                               .sel0(swap_sel_input[0]),
                               .sel1(swap_sel_tlu[0]),
                               .sel2(swap_keep_state[0]),
                               .sel3(swap_next_state[0]));
   mux4ds #(2) slot1_state_mux(.dout(next_slot1_state[1:0]),
                               .in0(2'b10),
                               .in1({1'b0, valid_tlu_swap_w}),
                               .in2(swap_slot1_state_valid[1:0]),
                               .in3({swap_slot1_state_valid[0], 1'b0}),
                               .sel0(swap_sel_input[1]),
                               .sel1(swap_sel_tlu[1]),
                               .sel2(swap_keep_state[1]),
                               .sel3(swap_next_state[1]));
   mux4ds #(2) slot2_state_mux(.dout(next_slot2_state[1:0]),
                               .in0(2'b10),
                               .in1({1'b0, valid_tlu_swap_w}),
                               .in2(swap_slot2_state_valid[1:0]),
                               .in3({swap_slot2_state_valid[0], 1'b0}),
                               .sel0(swap_sel_input[2]),
                               .sel1(swap_sel_tlu[2]),
                               .sel2(swap_keep_state[2]),
                               .sel3(swap_next_state[2]));
   mux4ds #(2) slot3_state_mux(.dout(next_slot3_state[1:0]),
                               .in0(2'b10),
                               .in1({1'b0, valid_tlu_swap_w}),
                               .in2(swap_slot3_state_valid[1:0]),
                               .in3({swap_slot3_state_valid[0], 1'b0}),
                               .sel0(swap_sel_input[3]),
                               .sel1(swap_sel_tlu[3]),
                               .sel2(swap_keep_state[3]),
                               .sel3(swap_next_state[3]));

   // The kill is only assessed in w1 because back to back swaps are not allowed.
   // This means that a swap cannot start in the M or W stage.
   assign     kill_swap_slot_w = rml_kill_w & full_swap_w;

   assign     swap_slot0_state_valid[1:0] = {(swap_slot0_state[1] & ~(kill_swap_slot_w & ecl_rml_thr_w[0])),
                                             (swap_slot0_state[0])};
   assign     swap_slot1_state_valid[1:0] = {(swap_slot1_state[1] & ~(kill_swap_slot_w & ecl_rml_thr_w[1])),
                                             (swap_slot1_state[0])};
   assign     swap_slot2_state_valid[1:0] = {(swap_slot2_state[1] & ~(kill_swap_slot_w & ecl_rml_thr_w[2])),
                                             (swap_slot2_state[0])};
   assign     swap_slot3_state_valid[1:0] = {(swap_slot3_state[1] & ~(kill_swap_slot_w & ecl_rml_thr_w[3])),
                                             (swap_slot3_state[0])};
   
   // Flops for cwp_swap data
   dffr_s #(15) slot0_data_dff(.din({next_slot0_state[1:0], next_slot0_data[12:0]}), .clk(clk), 
                            .q({swap_slot0_state[1:0], swap_slot0_data[12:0]}), .rst(reset),
                            .se(se), .si(), .so());
   dffr_s #(15) slot1_data_dff(.din({next_slot1_state[1:0], next_slot1_data[12:0]}), .clk(clk), 
                            .q({swap_slot1_state[1:0], swap_slot1_data[12:0]}), .rst(reset),
                            .se(se), .si(), .so());
   dffr_s #(15) slot2_data_dff(.din({next_slot2_state[1:0], next_slot2_data[12:0]}), .clk(clk), 
                            .q({swap_slot2_state[1:0], swap_slot2_data[12:0]}), .rst(reset),
                            .se(se), .si(), .so());
   dffr_s #(15) slot3_data_dff(.din({next_slot3_state[1:0], next_slot3_data[12:0]}), .clk(clk), 
                            .q({swap_slot3_state[1:0], swap_slot3_data[12:0]}), .rst(reset),
                            .se(se), .si(), .so());

   ////////////////////////////
   // Control for queue output
   //	==========================
   //	The queue results go into a flop
   //	so that they can meet timing.
   ////////////////////////////
   assign     swap_req_vec[0] = (swap_slot0_state[1] | swap_slot0_state[0]);
   assign     swap_req_vec[1] = (swap_slot1_state[1] | swap_slot1_state[0]);
   assign     swap_req_vec[2] = (swap_slot2_state[1] | swap_slot2_state[0]);
   assign     swap_req_vec[3] = (swap_slot3_state[1] | swap_slot3_state[0]);
   
   sparc_exu_rndrob cwp_output_queue(// Outputs
                                     .grant_vec(next_swap_thr[3:0]),
                                     // Inputs
                                     .clk(clk),
                                     .reset(reset),
                                     .se(se),
                                     .req_vec(swap_req_vec[3:0]),
                                     .advance(can_swap));
   dff_s #(4) dff_swap_thr(.din(next_swap_thr[3:0]), .clk(clk), .q(swap_thr[3:0]),
                         .se(se), .si(), .so());
   assign     swap_tid[1] = swap_thr[3] | swap_thr[2];
   assign     swap_tid[0] = swap_thr[3] | swap_thr[1];

   // make selects one hot
   wire [3:0] swap_sel;
   assign swap_sel[0] = ~(swap_thr[1] | swap_thr[2] | swap_thr[3]) | rst_tri_en;
   assign swap_sel[3:1] = swap_thr[3:1] & {3{~rst_tri_en}};

   mux4ds #(15) cwp_output_mux(.dout({swap_state[1:0], swap_data[12:0]}),
                               .in0({swap_slot0_state[1:0], swap_slot0_data[12:0]}),
                               .in1({swap_slot1_state[1:0], swap_slot1_data[12:0]}),
                               .in2({swap_slot2_state[1:0], swap_slot2_data[12:0]}),
                               .in3({swap_slot3_state[1:0], swap_slot3_data[12:0]}),
                               .sel0(swap_sel[0]),
                               .sel1(swap_sel[1]),
                               .sel2(swap_sel[2]),
                               .sel3(swap_sel[3]));

   // To prevent back to back swap requests on the same thread, the queue cannot swap
   // 2 cycles in a row.  Also swaps can't start in M or W to allow flush to be checked
   dffr_s can_swap_flop(.din(swapping), .clk(clk), .q(just_swapped), .rst(reset), .se(se), .si(), .so());
   assign     can_swap = ~(save_e | restore_e | ifu_exu_flushw_e | ecl_rml_cwp_wen_e | just_swapped);
   assign      swap_locals_ins = can_swap & swap_state[0];
   assign      swap_outs = can_swap & swap_state[1];
   assign      swapping = (can_swap & |swap_state[1:0]) | full_swap_e | full_swap_m;

   ///////////////////////////////////
   // Signals for completion of swaps
   ///////////////////////////////////
   assign spill_next = swap_data[6] & ~swap_data[7] & swap_outs;
   assign spill_tid_next[1:0] = swap_tid[1:0];
   //assign exu_tlu_spill_ttype[8:0] = {3'b010, swap_data[8], swap_data[11:9], 2'b00};
   assign spill_other_next = swap_data[8];
   assign spill_wtype_next[2:0] = swap_data[11:9];
   dff_s #(7) spill_dff(.din({spill_next,spill_tid_next[1:0], spill_other_next, spill_wtype_next[2:0]}),
                      .q({exu_tlu_spill,exu_tlu_spill_tid[1:0], exu_tlu_spill_other, exu_tlu_spill_wtype[2:0]}),
                      .clk(clk), .se(se), .si(), .so());
   assign spill_cwp[2:0] = swap_data[5:3];
/* -----\/----- EXCLUDED -----\/-----
   dff_s #(3) spill_cwp_dff(.din(swap_data[5:3]), .clk(clk), .q(spill_cwp[2:0]),
                          .se(se), .si(), .so());
 -----/\----- EXCLUDED -----/\----- */
   assign swap_done_next_cycle[3] = (swap_outs & ~swap_data[6] & ~swap_data[7] &
                                     swap_tid[1] & swap_tid[0]); 
   assign swap_done_next_cycle[2] = (swap_outs & ~swap_data[6] & ~swap_data[7] &
                                     swap_tid[1] & ~swap_tid[0]); 
   assign swap_done_next_cycle[1] = (swap_outs & ~swap_data[6] & ~swap_data[7] &
                                     ~swap_tid[1] & swap_tid[0]); 
   assign swap_done_next_cycle[0] = (swap_outs & ~swap_data[6] & ~swap_data[7] &
                                     ~swap_tid[1] & ~swap_tid[0]); 

   dff_s #(4) swap_done_dff(.din(swap_done_next_cycle[3:0]), .clk(clk),
                        .q(rml_ecl_swap_done[3:0]), .se(se), .si(), .so());

   dff_s #(4) cwp_cmplt_dff(.din({cwp_cmplt_next, cwp_cmplt_tid_next[1:0], cwp_retry_next}),
                          .q({exu_tlu_cwp_cmplt,exu_tlu_cwp_cmplt_tid[1:0], exu_tlu_cwp_retry}),
                          .clk(clk), .si(), .so(), .se(se));
   assign cwp_cmplt_next = swap_outs & swap_data[7];
   assign cwp_cmplt_tid_next[1:0] = swap_tid[1:0];
   assign cwp_retry_next = swap_data[12];

   assign tlu_cwp_xor[2:0] = trap_old_cwp_m[2:0] ^ tlu_exu_cwp_m[2:0];
   assign tlu_cwp_no_change = ~(tlu_cwp_xor[2] | tlu_cwp_xor[1] | tlu_cwp_xor[0]); 
   assign cwp_fastcmplt_m = tlu_exu_cwpccr_update_m & tlu_cwp_no_change;

   dff_s fastcmplt_dff(.din(cwp_fastcmplt_m), .clk(clk),
                     .q(cwp_fastcmplt_w), .se(se), .si(), .so());

   ///////////////////////////////////////////////////////////
   // Pipe along tlu_exu_done/retry so inst_vld can be caught
   ///////////////////////////////////////////////////////////
   dff_s #(5) tlu_data_dff(.q({cwpccr_update_w,tlu_exu_cwp_w[2:0],tlu_exu_cwp_retry_w}),
                         .din({tlu_exu_cwpccr_update_m,tlu_exu_cwp_m[2:0],tlu_exu_cwp_retry_m}),
                         .clk(clk), .se(se), .si(), .so());
   assign valid_tlu_swap_w = cwpccr_update_w & ~rml_kill_w & ~cwp_fastcmplt_w;
   
endmodule // sparc_exu_rml_cwp