`ifdef FPGA_SYN
`define FPGA_DEFINE
`else
`define ASIC_DEFINE
`endif

`ifdef FPGA_DEFINE

module blah(clk, one, two, three
,
//*****[ERROR CAPTURE MODULE INOUTS]*****
	err_en, // Error injection enable
	err_ctrl, // Error injection control

//*****[SHADOW CAPTURE MODULE INOUTS]*****
	sh_clk, // Shadow/data clock
	sh_rst, // Shadow/data reset
	c_en, // Capture enable
	dump_en, // Dump enable
	ch_out, // Chains out
	ch_out_vld, // Chains out valid
	ch_out_done // Chains done
);

//*****[ERROR CAPTURE MODULE INOUTS]*****
input	err_en; // Error injection enable
input	[0 : 0]err_ctrl; // Error injection control

//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****
input	sh_clk; // Shadow/data clock
input	sh_rst; // Shadow/data reset
input	c_en; // Capture enable
input	[63:0]	dump_en; // Dump enable
output	[63:0]	ch_out; // Chains out
output	[63:0]	ch_out_vld; // Chains out Valid
output	[63:0]	ch_out_done; // Chains done
input one;
input [1:0] two;
output [2:0] three;

`ifdef NOT_DEFINED
`else
dff_ns #(6) blahState(
     .err_en(lcl_err[0]),
	.clk(clk),
	.din({one, two}),
	.q(three)
);

assign  ld_sec_hit_thrd0 =  
(ld_pcx_pkt_g_tmp[`LMQ_AD_HI:`LMQ_AD_LO+4] == lmq0_pcx_pkt[`LMQ_AD_HI:`LMQ_AD_LO+4]) ;            

`ifdef FPGA_SYN_1THREAD
  assign load_pcx_pkt[`LMQ_WIDTH-1:0] = lmq0_pcx_pkt[`LMQ_WIDTH-1:0];
`else
// THREAD 1.
/*
dffe_s  #(`LMQ_WIDTH) lmq1 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq1_pcx_pkt[`LMQ_VLD:0]),
        .en     (lmq_enable[1]), .clk (clk),
        .se     (1'b0),       .si (),          .so ()
        );              
*/
wire lmq1_clk;   
`ifdef FPGA_SYN_CLK_EN
`else
clken_buf lmq1_clkbuf (
                .rclk   (clk),
                .enb_l  (~lmq_enable[1]),
                .tmb_l  (~se),
                .clk    (lmq1_clk)
                ) ;   
`endif

wire  [`LMQ_VLD:0]  lmq1_pcx_pkt_tmp;

`ifdef FPGA_SYN_CLK_DFF
dffe_s  #(`LMQ_WIDTH) lmq1 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq1_pcx_pkt_tmp[`LMQ_VLD:0]),
        .en (~(~lmq_enable[1])), .clk(clk),
        .se     (1'b0),       .si (),          .so ()
        ); 
`else
dff_s  #(`LMQ_WIDTH) lmq1 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq1_pcx_pkt_tmp[`LMQ_VLD:0]),
        .clk    (lmq1_clk),
        .se     (1'b0),       .si (),          .so ()
        ); 
`endif

`endif


//[Error Injector Instantiation here]
error_injector #(.UPB(0), .LWB(0), .LCL(1)) error_injector_blah(
      .err_en(err_en),
		.err_ctrl(err_ctrl),
      .lcl_err(lcl_err)
);



//[Shadow Module Instantiation here]
shadow_capture #(.DFF_BITS(6), .USE_DCLK(1), .CHAINS_IN(0), .CHAINS_OUT(64), .DISCRETE_DFFS(1), .DFF_WIDTHS({32'd6})) shadow_capture_blah (
      .clk(sh_clk), 
		.rst(sh_rst), 
		.capture_en(c_en), 
      .dclk({clk}), 
		.din({three}),
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
`endif
`else

module blah(clk, one, two);
	input one;
	input [1:0] two;
	
	wire temp;
	dff_ns #(1) blahState(
		.clk(clk),
		.din(one),
		.q(temp)
	);

	assign two = {2{temp}};

	assign  ld_sec_hit_thrd0 =  
(ld_pcx_pkt_g_tmp[`LMQ_AD_HI:`LMQ_AD_LO+4] == lmq0_pcx_pkt[`LMQ_AD_HI:`LMQ_AD_LO+4]) ;            

`ifdef FPGA_SYN_1THREAD
  assign load_pcx_pkt[`LMQ_WIDTH-1:0] = lmq0_pcx_pkt[`LMQ_WIDTH-1:0];
`else
// THREAD 1.
/*
dffe_s  #(`LMQ_WIDTH) lmq1 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq1_pcx_pkt[`LMQ_VLD:0]),
        .en     (lmq_enable[1]), .clk (clk),
        .se     (1'b0),       .si (),          .so ()
        );              
*/
wire lmq1_clk;   
`ifdef FPGA_SYN_CLK_EN
`else
clken_buf lmq1_clkbuf (
                .rclk   (clk),
                .enb_l  (~lmq_enable[1]),
                .tmb_l  (~se),
                .clk    (lmq1_clk)
                ) ;   
`endif
endmodule

`endif
