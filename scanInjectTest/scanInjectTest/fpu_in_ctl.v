// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: fpu_in_ctl.v
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
///////////////////////////////////////////////////////////////////////////////
//
//      FPU input control logic.
//
///////////////////////////////////////////////////////////////////////////////
 
module fpu_in_ctl (
	pcx_fpio_data_rdy_px2,
	pcx_fpio_data_px2,
	fp_op_in,
        fp_op_in_7in,
	a1stg_step,
	m1stg_step,
	d1stg_step,
	add_pipe_active,
	mul_pipe_active,
	div_pipe_active,
	sehold,
	arst_l,
	grst_l,
	rclk,

        fp_data_rdy,
	fadd_clken_l,
	fmul_clken_l,
	fdiv_clken_l,
	
	inq_we,
	inq_wraddr,
	inq_read_en,
	inq_rdaddr,
	inq_bp,
	inq_bp_inv,
	inq_fwrd,
	inq_fwrd_inv,
	inq_add,
	inq_mul,
	inq_div,

	se,
	si,
	so

,
//*****[ERROR CAPTURE MODULE INOUTS]*****
	err_en, // Error injection enable
	err_ctrl // Error injection control
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

	//*****[ERROR CAPTURE MODULE INOUTS INSTANTIATIONS]*****
	input	err_en; // Error injection enable
	input	[5:0] err_ctrl; // Error injection control

	//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****
	input	sh_clk; // Shadow/data clock
	input	sh_rst; // Shadow/data reset
	input	c_en; // Capture enable
	input	[0:0]	dump_en; // Dump enable
	output	[0:0]	ch_out; // Chains out
	output	[0:0]	ch_out_vld; // Chains out Valid
	output	[0:0]	ch_out_done; // Chains done

	//*****[ERROR WIRE INSTANTIATIONS]******
	wire [34:0] lcl_err;


input		pcx_fpio_data_rdy_px2;	// FPU request ready from PCX
input [123:118]	pcx_fpio_data_px2;	// FPU request data from PCX
input [3:2]	fp_op_in;		// request opcode
input         	fp_op_in_7in;		// request opcode
input		a1stg_step;		// add pipe load
input		m1stg_step;		// multiply pipe load
input		d1stg_step;		// divide pipe load
input 		add_pipe_active;        // add pipe is executing a valid instr
input 		mul_pipe_active;        // mul pipe is executing a valid instr
input 		div_pipe_active;        // div pipe is executing a valid instr
input sehold; // hold sram output MUX (for inq_data[155:0] in fpu_in_dp) for macrotest
input		arst_l;			// global asynchronous reset- asserted low
input		grst_l;			// global synchronous reset- asserted low
input		rclk;		// global clock

output          fp_data_rdy;

output		fadd_clken_l;		// add      pipe clk enable - asserted low
output		fmul_clken_l;		// multiply pipe clk enable - asserted low
output		fdiv_clken_l;		// divide   pipe clk enable - asserted low

output		inq_we;			// input Q write enable
output [3:0]	inq_wraddr;		// input Q write address
output          inq_read_en;            // input Q read enable
output [3:0]	inq_rdaddr;		// input Q read address
output		inq_bp;			// bypass the input Q SRAM
output		inq_bp_inv;		// don't bypass the input Q SRAM
output		inq_fwrd;		// input Q is empty
output		inq_fwrd_inv;		// input Q is not empty
output		inq_add;		// add pipe request
output		inq_mul;		// multiply pipe request
output		inq_div;		// divide pipe request

input           se;                     // scan_enable
input           si;                     // scan in
output          so;                     // scan out


wire		reset;
wire		fp_data_rdy;
wire		fp_vld_in;
wire [4:0]	fp_type_in;
wire  		fadd_clken_l;
wire 		fmul_clken_l;
wire 		fdiv_clken_l;
wire		fp_op_in_7;
wire		fp_op_in_7_inv;
wire		inq_we;
wire            inq_read_en;
wire [3:0]	inq_wrptr_plus1;
wire		inq_wrptr_step;
wire [3:0]	inq_wrptr;
wire [3:0]	inq_div_wrptr_plus1;
wire		inq_div_wrptr_step;
wire [3:0]	inq_div_wrptr;
wire [3:0]	inq_wraddr;
wire [3:0]	inq_wraddr_del;
wire		inq_re;
wire [3:0]	inq_rdptr_plus1;
wire [3:0]	inq_rdptr_in;
wire [3:0]	inq_rdptr;
wire		inq_div_re;
wire [3:0]	inq_div_rdptr_plus1;
wire [3:0]	inq_div_rdptr_in;
wire [3:0]	inq_div_rdptr;
wire		inq_div_rd_in;
wire		inq_div_rd;
wire [3:0]	inq_rdaddr;
wire [3:0]	inq_rdaddr_del;
wire		inq_bp;
wire		inq_bp_inv;
wire		inq_empty;
wire		inq_div_empty;
wire		inq_fwrd;
wire		inq_fwrd_inv;
wire		fp_add_in;
wire		fp_mul_in;
wire		fp_div_in;
wire [7:0]	inq_rdptr_dec_in;
wire [7:0]	inq_rdptr_dec;
wire [7:0]	inq_div_rdptr_dec_in;
wire [7:0]	inq_div_rdptr_dec;
wire [15:0]	inq_rdaddr_del_dec_in;
wire [15:0]	inq_rdaddr_del_dec;
wire		inq_pipe0_we;
wire		inq_pipe1_we;
wire		inq_pipe2_we;
wire		inq_pipe3_we;
wire		inq_pipe4_we;
wire		inq_pipe5_we;
wire		inq_pipe6_we;
wire		inq_pipe7_we;
wire		inq_pipe8_we;
wire		inq_pipe9_we;
wire		inq_pipe10_we;
wire		inq_pipe11_we;
wire		inq_pipe12_we;
wire		inq_pipe13_we;
wire		inq_pipe14_we;
wire		inq_pipe15_we;
wire [2:0]	inq_pipe0;
wire [2:0]	inq_pipe1;
wire [2:0]	inq_pipe2;
wire [2:0]	inq_pipe3;
wire [2:0]	inq_pipe4;
wire [2:0]	inq_pipe5;
wire [2:0]	inq_pipe6;
wire [2:0]	inq_pipe7;
wire [2:0]	inq_pipe8;
wire [2:0]	inq_pipe9;
wire [2:0]	inq_pipe10;
wire [2:0]	inq_pipe11;
wire [2:0]	inq_pipe12;
wire [2:0]	inq_pipe13;
wire [2:0]	inq_pipe14;
wire [2:0]	inq_pipe15;
wire [2:0]	inq_pipe;
wire		inq_div;
wire		inq_diva;
wire		inq_diva_dly;
wire		d1stg_step_dly;
wire		inq_mul;
wire		inq_mula;
wire		inq_add;
wire		inq_adda;
wire		valid_packet;
wire            valid_packet_dly;
wire		tag_sel;
wire sehold_inv;


dffrl_async #(1)  dffrl_in_ctl (
.err_en(lcl_err[0]),
  .din  (grst_l),
  .clk  (rclk),
  .rst_l(arst_l),
  .q    (in_ctl_rst_l),
	.se (se),
	.si (),
	.so ()
  );

assign reset= (!in_ctl_rst_l);


///////////////////////////////////////////////////////////////////////////////
//
//	Capture request and input control information.
//
///////////////////////////////////////////////////////////////////////////////

dffr_s #(1) i_fp_data_rdy (
.err_en(lcl_err[1]),
	.din	(pcx_fpio_data_rdy_px2),
	.rst    (reset),
        .clk    (rclk),

        .q      (fp_data_rdy),

	.se     (se),
        .si     (),
        .so     ()
);

dff_s #(1) i_fp_vld_in (
.err_en(lcl_err[2]),
	.din	(pcx_fpio_data_px2[123]),
	.clk    (rclk),

        .q      (fp_vld_in),

	.se     (se),
        .si     (),
        .so     ()
);

dff_s #(5) i_fp_type_in (
.err_en(lcl_err[3]),
	.din	(pcx_fpio_data_px2[122:118]),
        .clk    (rclk),
 
        .q      (fp_type_in[4:0]),

        .se     (se),
        .si     (),
        .so     ()
);


///////////////////////////////////////////////////////////////////////////////
//
//	Select lines- extract the two operands.
//
///////////////////////////////////////////////////////////////////////////////

assign fp_op_in_7= fp_op_in_7in;

assign fp_op_in_7_inv= (!fp_op_in_7);


///////////////////////////////////////////////////////////////////////////////
//
//	Input queue control logic
//		- write enables
//		- write pointers
//		- read enables
//		- read pointers
//		- write address
//		- read address
//
///////////////////////////////////////////////////////////////////////////////

assign inq_we= fp_data_rdy && fp_vld_in
		&& (((fp_type_in[4:0]==5'h0a) && fp_op_in_7)
			|| ((fp_type_in[4:0]==5'h0b) && fp_op_in_7_inv));

assign inq_wrptr_plus1[3:0]= inq_wrptr[3:0] + 4'h1;

assign inq_wrptr_step= inq_we && (!fp_div_in);

dffre_s #(4) i_inq_wrptr (
.err_en(lcl_err[4]),
	.din	(inq_wrptr_plus1[3:0]),
	.en	(inq_wrptr_step),
	.rst	(reset),
	.clk    (rclk),

        .q      (inq_wrptr[3:0]),

        .se     (se),
        .si     (),
        .so     ()
);

assign inq_div_wrptr_plus1[3:0]= inq_div_wrptr[3:0] + 4'h1;

assign inq_div_wrptr_step= inq_we && fp_div_in;

dffre_s #(4) i_inq_div_wrptr (
.err_en(lcl_err[5]),
        .din    (inq_div_wrptr_plus1[3:0]),
        .en     (inq_div_wrptr_step),
        .rst    (reset),
        .clk    (rclk),
 
        .q      (inq_div_wrptr[3:0]),
 
        .se     (se),
        .si     (),
        .so     ()
);

assign inq_wraddr[3:0]= {fp_div_in,
		(({3{fp_div_in}}
			    & inq_div_wrptr[2:0])
		    | ({3{(!fp_div_in)}}
			    & inq_wrptr[2:0]))};

dff_s #(4) i_inq_wraddr_del (
.err_en(lcl_err[6]),
	.din	(inq_wraddr[3:0]),
	.clk	(rclk),

	.q	(inq_wraddr_del[3:0]),

	.se	(se),
	.si	(),
	.so	()
);

assign inq_read_en = ~inq_empty | ~inq_div_empty;

assign inq_re= (inq_adda && a1stg_step)
		|| (inq_mula && m1stg_step);

assign inq_rdptr_plus1[3:0]= inq_rdptr[3:0] + 4'h1;

assign inq_rdptr_in[3:0]= ({4{(inq_re && (!reset))}}
			    & inq_rdptr_plus1[3:0])
		| ({4{((!inq_re) && (!reset))}}
			    & inq_rdptr[3:0]);

dff_s #(4) i_inq_rdptr (
.err_en(lcl_err[7]),
	.din	(inq_rdptr_in[3:0]),
	.clk    (rclk),
 
        .q      (inq_rdptr[3:0]),
 
        .se     (se),
        .si     (),
        .so     ()
);

assign inq_div_re= (inq_diva && d1stg_step);

assign inq_div_rdptr_plus1[3:0]= inq_div_rdptr[3:0] + 4'h1;

assign inq_div_rdptr_in[3:0]= ({4{(inq_div_re && (!reset))}}
                            & inq_div_rdptr_plus1[3:0])
                | ({4{((!inq_div_re) && (!reset))}}
                            & inq_div_rdptr[3:0]);
 
dff_s #(4) i_inq_div_rdptr (
.err_en(lcl_err[8]),
        .din    (inq_div_rdptr_in[3:0]),
        .clk    (rclk),

        .q      (inq_div_rdptr[3:0]),

        .se     (se),
        .si     (),
        .so     ()
);

assign inq_div_rd_in= (!inq_div_empty) && d1stg_step && (!inq_diva);

dff_s #(1) i_inq_div_rd (
.err_en(lcl_err[9]),
	.din	(inq_div_rd_in),
	.clk    (rclk),

        .q      (inq_div_rd),

        .se     (se),
        .si     (),
        .so     ()
);

assign inq_rdaddr[3:0]= {inq_div_rd_in,
		(({3{inq_div_rd_in}}
			    & (inq_div_rdptr[2:0] & {3{(!reset)}}))
		    | ({3{(!inq_div_rd_in)}}
			    & inq_rdptr_in[2:0]))};

dff_s #(4) i_inq_rdaddr_del (
.err_en(lcl_err[10]),
	.din	(inq_rdaddr[3:0]),
        .clk	(rclk),
 
        .q	(inq_rdaddr_del[3:0]),
 
        .se	(se),
        .si	(),
        .so	()
);


///////////////////////////////////////////////////////////////////////////////
//
//      Input queue empty and bypass signals.
//
///////////////////////////////////////////////////////////////////////////////

// Power management update

assign valid_packet = fp_data_rdy && fp_vld_in &&
                      ((fp_type_in[4:0]==5'h0a) || (fp_type_in[4:0]==5'h0b));

dffre_s #(1) i_valid_packet_dly (
.err_en(lcl_err[11]),
	.din	(valid_packet),
	.en     (1'b1),
        .rst    (reset),
        .clk    (rclk),

        .q      (valid_packet_dly),

        .se     (se),
        .si     (),
        .so     ()
);

// Never bypass/forward invalid packets to the execution pipes
// assign inq_bp= (inq_wraddr_del[3:0]==inq_rdaddr_del[3:0]);

// 11/11/03: macrotest (AND with sehold_inv) 
assign sehold_inv = ~sehold;

assign inq_bp= (inq_wraddr_del[3:0]==inq_rdaddr_del[3:0]) && valid_packet_dly && sehold_inv;

assign inq_bp_inv= (!inq_bp);

assign inq_empty= (inq_wrptr[3:0]==inq_rdptr[3:0]);

assign inq_div_empty= (inq_div_wrptr[3:0]==inq_div_rdptr[3:0]);

// Power management update
// Never bypass/forward invalid packets to the execution pipes
// assign inq_fwrd= (inq_empty && (!inq_div_rd))
//		|| (inq_div_empty && fp_div_in && fp_data_rdy && fp_vld_in
//			&& d1stg_step);

// 11/11/03: macrotest change (AND with sehold_inv) 
assign inq_fwrd= ((inq_empty && (!inq_div_rd))
  		|| (inq_div_empty && fp_div_in
  			&& d1stg_step)) && valid_packet && sehold_inv;

assign inq_fwrd_inv= (!inq_fwrd);


///////////////////////////////////////////////////////////////////////////////
//
//	FPU pipe selection flags.
//
///////////////////////////////////////////////////////////////////////////////

assign fp_add_in= fp_data_rdy && fp_vld_in && (fp_type_in[4:1]==4'h5)
		&& ((fp_op_in_7 && (!fp_type_in[0]))
			|| (fp_op_in_7_inv && (!fp_op_in[3]) && fp_type_in[0]));

assign fp_mul_in= fp_data_rdy && fp_vld_in && (fp_type_in[4:0]==5'h0b)
		&& fp_op_in_7_inv && (fp_op_in[3:2]==2'b10);

assign fp_div_in= fp_data_rdy && fp_vld_in && (fp_type_in[4:0]==5'h0b)
                && fp_op_in_7_inv && (fp_op_in[3:2]==2'b11);

assign inq_rdptr_dec_in[7:0]= ({8{reset}}
			    & 8'h01)
		| ({8{(inq_re && (!reset))}}
			    & {inq_rdptr_dec[6:0], inq_rdptr_dec[7]})
		| ({8{((!inq_re) && (!reset))}}
			    & inq_rdptr_dec[7:0]);

dff_s #(8) i_inq_rdptr_dec (
.err_en(lcl_err[12]),
	.din	(inq_rdptr_dec_in[7:0]),
	.clk	(rclk),

	.q	(inq_rdptr_dec[7:0]),

	.se     (se),
        .si     (),
        .so     ()
);

assign inq_div_rdptr_dec_in[7:0]= ({8{reset}}
                            & 8'h01)
                | ({8{(inq_div_re && (!reset))}}
                            & {inq_div_rdptr_dec[6:0], inq_div_rdptr_dec[7]})
                | ({8{((!inq_div_re) && (!reset))}}
                            & inq_div_rdptr_dec[7:0]);
 
dff_s #(8) i_inq_div_rdptr_dec (
.err_en(lcl_err[13]),
        .din    (inq_div_rdptr_dec_in[7:0]),
        .clk    (rclk),

        .q      (inq_div_rdptr_dec[7:0]),

        .se     (se),
        .si     (),
        .so     ()
);

assign inq_rdaddr_del_dec_in[15:0]= ({16{((!inq_div_empty) && d1stg_step
					&& (!inq_diva))}}
			    & {(inq_div_rdptr_dec[7:1] & {7{(!reset)}}),
				(inq_div_rdptr_dec[0] || reset), 8'b0})
		| ({16{(!((!inq_div_empty) && d1stg_step && (!inq_diva)))}}
			    & {8'b0, inq_rdptr_dec_in[7:0]});

dff_s #16 i_inq_rdaddr_del_dec (
.err_en(lcl_err[14]),
	.din	(inq_rdaddr_del_dec_in[15:0]),
	.clk	(rclk),

	.q	(inq_rdaddr_del_dec[15:0]),
 
        .se     (se),
        .si     (),
        .so     ()
);

assign inq_pipe0_we= inq_we && (!fp_div_in) && (inq_wrptr[2:0]==3'h0);
assign inq_pipe1_we= inq_we && (!fp_div_in) && (inq_wrptr[2:0]==3'h1);
assign inq_pipe2_we= inq_we && (!fp_div_in) && (inq_wrptr[2:0]==3'h2);
assign inq_pipe3_we= inq_we && (!fp_div_in) && (inq_wrptr[2:0]==3'h3);
assign inq_pipe4_we= inq_we && (!fp_div_in) && (inq_wrptr[2:0]==3'h4);
assign inq_pipe5_we= inq_we && (!fp_div_in) && (inq_wrptr[2:0]==3'h5);
assign inq_pipe6_we= inq_we && (!fp_div_in) && (inq_wrptr[2:0]==3'h6);
assign inq_pipe7_we= inq_we && (!fp_div_in) && (inq_wrptr[2:0]==3'h7);

assign inq_pipe8_we= inq_we && fp_div_in && (inq_div_wrptr[2:0]==3'h0);
assign inq_pipe9_we= inq_we && fp_div_in && (inq_div_wrptr[2:0]==3'h1);
assign inq_pipe10_we= inq_we && fp_div_in && (inq_div_wrptr[2:0]==3'h2);
assign inq_pipe11_we= inq_we && fp_div_in && (inq_div_wrptr[2:0]==3'h3);
assign inq_pipe12_we= inq_we && fp_div_in && (inq_div_wrptr[2:0]==3'h4);
assign inq_pipe13_we= inq_we && fp_div_in && (inq_div_wrptr[2:0]==3'h5);
assign inq_pipe14_we= inq_we && fp_div_in && (inq_div_wrptr[2:0]==3'h6);
assign inq_pipe15_we= inq_we && fp_div_in && (inq_div_wrptr[2:0]==3'h7);

dffre_s #(3) i_inq_pipe0 (
.err_en(lcl_err[15]),
	.din	({fp_div_in, fp_mul_in, fp_add_in}),
	.en	(inq_pipe0_we),
        .rst    (reset),
	.clk    (rclk),

        .q      (inq_pipe0[2:0]),
 
        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe1 (
.err_en(lcl_err[16]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe1_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe1[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe2 (
.err_en(lcl_err[17]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe2_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe2[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe3 (
.err_en(lcl_err[18]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe3_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe3[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe4 (
.err_en(lcl_err[19]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe4_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe4[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe5 (
.err_en(lcl_err[20]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe5_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe5[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe6 (
.err_en(lcl_err[21]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe6_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe6[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe7 (
.err_en(lcl_err[22]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe7_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe7[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe8 (
.err_en(lcl_err[23]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe8_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe8[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe9 (
.err_en(lcl_err[24]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe9_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe9[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe10 (
.err_en(lcl_err[25]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe10_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe10[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe11 (
.err_en(lcl_err[26]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe11_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe11[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe12 (
.err_en(lcl_err[27]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe12_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe12[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe13 (
.err_en(lcl_err[28]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe13_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe13[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe14 (
.err_en(lcl_err[29]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe14_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe14[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(3) i_inq_pipe15 (
.err_en(lcl_err[30]),
        .din    ({fp_div_in, fp_mul_in, fp_add_in}),
        .en     (inq_pipe15_we),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_pipe15[2:0]),

        .se     (se),
        .si     (),
        .so     ()
);

// Power management update
// 3-bit fifo pipe tags (div,mul,add) are not cleared after use.
// Now that inq_fwrd is qualified by valid_packet, inq_fwrd can't be
// used for inq_pipe[2:0] selection.

assign tag_sel = (inq_empty && (!inq_div_rd))
  		|| (inq_div_empty && fp_div_in && fp_data_rdy && fp_vld_in
  			&& d1stg_step);

assign inq_pipe[2:0]= ({3{tag_sel}}
                                // Austin update
                                // performance change: allow div to bypass FIFO (2 cyc latency reduction)
			    & {(inq_div_empty && fp_div_in && fp_data_rdy && fp_vld_in
				&& d1stg_step
				&& d1stg_step_dly && (!inq_diva_dly)),
                                fp_mul_in,
				fp_add_in})
		| ({3{(!tag_sel)}}
			    & (({3{inq_rdaddr_del_dec[0]}}
					& inq_pipe0[2:0])
				| ({3{inq_rdaddr_del_dec[1]}}
                                        & inq_pipe1[2:0])
                                | ({3{inq_rdaddr_del_dec[2]}}
                                        & inq_pipe2[2:0])
                                | ({3{inq_rdaddr_del_dec[3]}}
                                        & inq_pipe3[2:0])
                                | ({3{inq_rdaddr_del_dec[4]}}
                                        & inq_pipe4[2:0])
                                | ({3{inq_rdaddr_del_dec[5]}}
                                        & inq_pipe5[2:0])
                                | ({3{inq_rdaddr_del_dec[6]}}
                                        & inq_pipe6[2:0])
                                | ({3{inq_rdaddr_del_dec[7]}}
                                        & inq_pipe7[2:0])
                                | ({3{inq_rdaddr_del_dec[8]}}
                                        & inq_pipe8[2:0])
                                | ({3{inq_rdaddr_del_dec[9]}}
                                        & inq_pipe9[2:0])
                                | ({3{inq_rdaddr_del_dec[10]}}
                                        & inq_pipe10[2:0])
                                | ({3{inq_rdaddr_del_dec[11]}}
                                        & inq_pipe11[2:0])
                                | ({3{inq_rdaddr_del_dec[12]}}
                                        & inq_pipe12[2:0])
                                | ({3{inq_rdaddr_del_dec[13]}}
                                        & inq_pipe13[2:0])
                                | ({3{inq_rdaddr_del_dec[14]}}
                                        & inq_pipe14[2:0])
                                | ({3{inq_rdaddr_del_dec[15]}}
                                        & inq_pipe15[2:0])));

assign inq_div= inq_pipe[2];
assign inq_diva= inq_pipe[2];
assign inq_mul= inq_pipe[1];
assign inq_mula= inq_pipe[1];
assign inq_add= inq_pipe[0];
assign inq_adda= inq_pipe[0];


// Power management update
// Gate the clocks on a per pipe basis (add, mul, div independently)
// when a given pipe is not in use

dffre_s #(1) i_inq_adda_dly (
.err_en(lcl_err[31]),
	.din	(inq_adda),
	.en     (1'b1),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_adda_dly),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(1) i_inq_mula_dly (
.err_en(lcl_err[32]),
	.din	(inq_mula),
	.en     (1'b1),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_mula_dly),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(1) i_inq_diva_dly (
.err_en(lcl_err[33]),
	.din	(inq_diva),
	.en     (1'b1),
        .rst    (reset),
        .clk    (rclk),

        .q      (inq_diva_dly),

        .se     (se),
        .si     (),
        .so     ()
);

dffre_s #(1) i_d1stg_step_dly (
.err_en(lcl_err[34]),
	.din	(d1stg_step),
	.en     (1'b1),
        .rst    (reset),
        .clk    (rclk),

        .q      (d1stg_step_dly),

        .se     (se),
        .si     (),
        .so     ()
);

assign fadd_clken_l = !(add_pipe_active || inq_adda || inq_adda_dly || reset);
assign fmul_clken_l = !(mul_pipe_active || inq_mula || inq_mula_dly || reset);
assign fdiv_clken_l = !(div_pipe_active || inq_diva || inq_diva_dly || reset);



	//[Local Error Control Splitter Instantiation here]
	lclErrCtrlSplitter #(.INW(6), .LCL(35)) local_err_router_fpu_in_ctl(
		.err_en(err_en),
		.err_ctrl(err_ctrl),
		.lcl_err(lcl_err)
	);



	//[Shadow Module Instantiation here]
	shadow_capture #(.DFF_BITS(118), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(1), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd118})) shadow_capture_fpu_in_ctl (
		.clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
		.dclk({rclk}), 
		.din({in_ctl_rst_l, fp_data_rdy, fp_vld_in, fp_type_in[4:0], inq_wrptr[3:0], inq_div_wrptr[3:0], inq_wraddr_del[3:0], inq_rdptr[3:0], inq_div_rdptr[3:0], inq_div_rd, inq_rdaddr_del[3:0], valid_packet_dly, inq_rdptr_dec[7:0], inq_div_rdptr_dec[7:0], inq_rdaddr_del_dec[15:0], inq_pipe0[2:0], inq_pipe1[2:0], inq_pipe2[2:0], inq_pipe3[2:0], inq_pipe4[2:0], inq_pipe5[2:0], inq_pipe6[2:0], inq_pipe7[2:0], inq_pipe8[2:0], inq_pipe9[2:0], inq_pipe10[2:0], inq_pipe11[2:0], inq_pipe12[2:0], inq_pipe13[2:0], inq_pipe14[2:0], inq_pipe15[2:0], inq_adda_dly, inq_mula_dly, inq_diva_dly, d1stg_step_dly}),
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


