// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_ifu_thrfsm.v
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
//  Module Name: sparc_ifu_swlthrfsm
//  Description:	
//  The switch logithrfsm contains the thread state machine.  
*/

`include "ifu.h"

module sparc_ifu_thrfsm(/*AUTOARG*/
   // Outputs
   so, thr_state, 
   // Inputs
   completion, schedule, spec_ld, ldhit, stall, int_activate, 
   start_thread, thaw_thread, nuke_thread, rst_thread, switch_out, 
   halt_thread, sw_cond, clk, se, si, reset

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

   // thread specific input
   input  completion,   // the op this thread was waiting for is complete
	        schedule,     // this thread was just switched in
	        spec_ld,      // speculative switch in
	        ldhit,        // speculation was correct
	        stall,        // stall thread for ldmiss, imiss or trap
	        int_activate, // activate this thread
          halt_thread,
	        start_thread,    // wake up this thread from dead state
	        nuke_thread,
          thaw_thread,
	        rst_thread;      // reset this thread

   // common inputs
   input  switch_out,   // this thread was just switched out
	        sw_cond;	// wait until completion signal is received

   input       clk, se, si, reset;

   output      so;

   output [4:0] thr_state;

   // local signals
   reg [4:0]    next_state;
   
   //
   // Code Begins Here
   //
   
//   assign       spec_rdy     = thr_state[`TCR_READY];

   always @ (/*AUTOSENSE*/ completion
             or halt_thread or int_activate or ldhit or nuke_thread
             or rst_thread or schedule or spec_ld or stall
             or start_thread or sw_cond or switch_out or thaw_thread 
             or thr_state)
     begin
	      case (thr_state[4:0])
          `THRFSM_IDLE:  // 5'b00000
	          begin
	             if (rst_thread | thaw_thread)
		             next_state = `THRFSM_WAIT;
	             else if (start_thread)    
		             next_state = `THRFSM_RDY;
	             else  // all other interrupts ignored
		             next_state = thr_state[4:0];
	          end

	        `THRFSM_HALT:  // 5'b00010
	          begin
	             if (nuke_thread)
		             next_state = `THRFSM_IDLE;
	             else if (rst_thread | thaw_thread)
		             next_state = `THRFSM_WAIT;
	             else if (int_activate | start_thread) 
		             next_state = `THRFSM_RDY;
	             else
		             next_state = thr_state[4:0];
	          end
	        
	        `THRFSM_RDY:       // 5'b11001
	          begin
	             if (stall)     
		             // trap also kills inst_s2 and nir
		             // Ldmiss should not happen in this state
		             next_state = `THRFSM_WAIT;
	             else if (schedule)
		             next_state = `THRFSM_RUN;
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_RDY

	        `THRFSM_RUN:       // 5'b00101
	          begin
	             if (stall | sw_cond)
		             // trap also kills inst_s2 and nir
		             // ldmiss should not happen in this state		 
		             next_state = `THRFSM_WAIT;
	             else if (switch_out)
	               // on an interrupt or thread stall, the fcl has to
	               // switch out the thread and inform the fsm 
		             next_state = `THRFSM_RDY;
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_RUN

	        `THRFSM_WAIT:       // 5'b00001
	          begin
	             if (nuke_thread) 
		             next_state = `THRFSM_IDLE;
	             else if (halt_thread) // exclusive with above
		             next_state = `THRFSM_HALT;
	             else if (stall) // excl. with above
		             next_state = `THRFSM_WAIT;
	             else if (spec_ld) // exclusive with above
		             next_state = `THRFSM_SPEC_RDY;
	             else if (completion & ~halt_thread)
		             next_state = `THRFSM_RDY;
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_WAIT
	        
	        `THRFSM_SPEC_RDY:       // 5'b10011
	          begin
	             if (stall)
		             next_state = `THRFSM_WAIT;
	             else if (schedule & ~ldhit) // exclusive
		             next_state = `THRFSM_SPEC_RUN;
	             else if (schedule & ldhit)  // exclusive
		             next_state = `THRFSM_RUN;
	             else if (ldhit)
		             next_state = `THRFSM_RDY;
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_SPEC_RDY

	        `THRFSM_SPEC_RUN:       // 5'b00111
	          begin
	             if (stall | sw_cond)
		             next_state = `THRFSM_WAIT;
	             else if ((ldhit) & switch_out)
		             next_state = `THRFSM_RDY;
	             else if ((ldhit) & ~switch_out)
		             next_state = `THRFSM_RUN;
	             else if (~(ldhit) & switch_out)
		             next_state = `THRFSM_SPEC_RDY;
	             // on an interrupt or thread stall, the fcl has to
	             // switch out the thread and inform the fsm 
	             else
		             next_state = thr_state[4:0];
	          end // case: `THRFSM_SPEC_RUN

//VCS coverage off
	        default:
	          begin
               // synopsys translate_off
		     // 0in <fire -message "thrfsm.v: Error! Invalid State"
`ifdef DEFINE_0IN
`else           
		`ifdef MODELSIM
	             $display("ILLEGAL_THR_STATE", "thrfsm.v: Error! Invalid State %b\n", thr_state);
		`else
	             $error("ILLEGAL_THR_STATE", "thrfsm.v: Error! Invalid State %b\n", thr_state);
		`endif		 
`endif		     
               // synopsys translate_on
	             if (rst_thread)
		             next_state = `THRFSM_WAIT;
	             else if (nuke_thread)
		             next_state = `THRFSM_IDLE;		 
	             else 
		             next_state = thr_state[4:0];
	          end
//VCS coverage on
	      endcase // casex({thr_state[4:0]})
     end // always @ (...

   // thread config register (tcr)
   dffr_s #(5) tcr(.din  (next_state),
	             .clk  (clk),
	             .q    (thr_state),
	             .rst  (reset),
	             .se   (se), .so(), .si());



	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(5), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(1), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd5})) shadow_capture_sparc_ifu_thrfsm (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({clk}), 
		.din({thr_state}),
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
