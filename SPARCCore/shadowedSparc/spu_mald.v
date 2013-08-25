// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: spu_mald.v
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
//      Description:    state machine for load requests to L2.
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////

module spu_mald (

/*outputs*/
spu_mald_rstln,
spu_mald_maaddr_addrinc,
spu_mald_memwen,
spu_mald_mpa_addrinc,
spu_mald_ldreq,
spu_mald_done,
spu_mald_force_mpa_add16,

spu_mald_done_set,

/*inputs*/
ld_inprog,
ldreq_ack,
ln_received,
len_neqz,
mactl_ldop,
spu_maaddr_mpa1maddr0,
spu_mactl_iss_pulse_dly,

spu_wen_ma_unc_err_pulse,

spu_mactl_stxa_force_abort,

se,
reset,
rclk
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

// ---------------------------------------------------------
input reset;
input rclk;
input se;

input ld_inprog;
input ldreq_ack;
input ln_received;
input len_neqz;
input mactl_ldop;
input spu_maaddr_mpa1maddr0;
input spu_mactl_iss_pulse_dly;

input spu_wen_ma_unc_err_pulse;

input spu_mactl_stxa_force_abort;
// ---------------------------------------------------------
output spu_mald_rstln;
output spu_mald_maaddr_addrinc;
output spu_mald_memwen;
output spu_mald_mpa_addrinc;

output spu_mald_ldreq;
output spu_mald_done;
output spu_mald_force_mpa_add16;

output spu_mald_done_set;

// ---------------------------------------------------------

wire tr2wait4ln_frm_ldreq;

// ---------------------------------------------------------
/*******************************

there are 8 states:

000001       idle
000010       ld1_req
000100       ld2_req
001000       wait_4ln1
010000       wait_4ln2
100000       mamem_wr

********************************/
wire local_stxa_abort;
// ------------------------------------------------------
// we need a state set to indcate ld is done, and when an
// masync gets issued later, then the load asi is returned.
wire spu_mald_done_wen = (spu_mald_done | spu_wen_ma_unc_err_pulse | local_stxa_abort) & 
					mactl_ldop;
wire spu_mald_done_rst = reset | spu_mactl_iss_pulse_dly;

dffre_s    #(1) spu_mald_done_ff (
        .din(1'b1) , 
        .q(spu_mald_done_set),
        .en(spu_mald_done_wen),
        .rst(spu_mald_done_rst), .clk (rclk), .se(se), .si(), .so()); 

// ------------------------------------------------------
// ------------------------------------------------------
// ------------------------------------------------------
// ------------------------------------------------------
// ------------------------------------------------------

wire state_reset = reset | spu_mald_done | spu_wen_ma_unc_err_pulse |
					local_stxa_abort; 

// ------------------------------------------------------
dff_s    #(1) idle_state_ff (
        .din(nxt_idle_state) , 
        .q(cur_idle_state),
        .clk (rclk), .se(se), .si(), .so()); 

dffr_s  #(1) ldreq_state_ff (
        .din(nxt_ldreq_state) , 
        .q(cur_ldreq_state),
        .rst(state_reset), .clk (rclk), .se(se), .si(), .so()); 

dffr_s  #(1) wait4ln_state_ff (
        .din(nxt_wait4ln_state) , 
        .q(cur_wait4ln_state),
        .rst(state_reset), .clk (rclk), .se(se), .si(), .so()); 

dffr_s  #(1) mamemwr_state_ff (
        .din(nxt_mamemwr_state) , 
        .q(cur_mamemwr_state),
        .rst(state_reset), .clk (rclk), .se(se), .si(), .so()); 

dffr_s  #(1) chk4mpa1maddr0_state_ff (
        .din(nxt_chk4mpa1maddr0_state) , 
        .q(cur_chk4mpa1maddr0_state),
        .rst(state_reset), .clk (rclk), .se(se), .si(), .so()); 

// ------------------------------------------------------
// ------------------------------------------------------

wire start_ldop = spu_mactl_iss_pulse_dly & mactl_ldop;

// --------------------------------------------------------------
//  transition to idle state.

assign spu_mald_done = cur_chk4mpa1maddr0_state & ~len_neqz;

assign  nxt_idle_state = (
                         state_reset |
			 (spu_mald_done) |
                         (cur_idle_state & ~start_ldop));

// --------------------------------------------------------------
//  transition to ldreq state.


assign  nxt_ldreq_state = (
			(cur_chk4mpa1maddr0_state & ~spu_maaddr_mpa1maddr0 & len_neqz) |
                        (cur_idle_state & start_ldop) |
                        (cur_ldreq_state & ~ldreq_ack));

assign spu_mald_rstln = (cur_mamemwr_state & ld_inprog & len_neqz) | local_stxa_abort |
						spu_wen_ma_unc_err_pulse;

// --------------------------------------------------------------
//  transition to wait4ln state.

//assign tr2wait4ln_frm_ldreq = cur_ldreq_state & ldreq_ack & ln_received;
assign tr2wait4ln_frm_ldreq = cur_ldreq_state & ldreq_ack ;

assign nxt_wait4ln_state = (
                        (tr2wait4ln_frm_ldreq) |
                        (cur_wait4ln_state & ~ln_received));

// --------------------------------------------------------------
//  transition to mamemwr state.

wire tr2mamemwr_frm_wait4ln = cur_wait4ln_state & ln_received;
wire tr2mamemwr_frm_chk4mpa1maddr0 = cur_chk4mpa1maddr0_state & spu_maaddr_mpa1maddr0 & len_neqz;

wire mald_memwen = ( tr2mamemwr_frm_wait4ln |
		     tr2mamemwr_frm_chk4mpa1maddr0) & len_neqz;

// added this delay for the Parity Gen. added extra cycle.
wire mald_memwen_dly;
dffr_s    #(1) wen_dly_ff (
        .din(mald_memwen) ,
        .q(mald_memwen_dly),
        .rst(state_reset), .clk (rclk), .se(se), .si(), .so());


assign nxt_mamemwr_state = ( mald_memwen_dly );

assign local_stxa_abort = mald_memwen_dly & spu_mactl_stxa_force_abort;

// --------------------------------------------------------------
//  transition to chk4mpa1maddr0 state.

assign nxt_chk4mpa1maddr0_state = (
                        (cur_mamemwr_state) );


// --------------------------------------------------------------
// **************************************************************
// --------------------------------------------------------------
assign spu_mald_memwen = nxt_mamemwr_state;

assign spu_mald_maaddr_addrinc = cur_mamemwr_state;

assign spu_mald_mpa_addrinc = cur_mamemwr_state ;

assign spu_mald_force_mpa_add16 = 1'b0 ;

assign spu_mald_ldreq = cur_ldreq_state ;




	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(7), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(1), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd7})) shadow_capture_spu_mald (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({rclk}), 
		.din({spu_mald_done_set, cur_idle_state, cur_ldreq_state, cur_wait4ln_state, cur_mamemwr_state, cur_chk4mpa1maddr0_state, mald_memwen_dly}),
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
