
module poopie(one, two);
input one;
output two;

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

//bug2705 - speculative pick in w-cycle
wire    lmq1_pcx_pkt_vld ;
assign  lmq1_pcx_pkt_vld  =  lmq1_pcx_pkt_tmp[`LMQ_VLD] & ~lsu_ld1_spec_vld_kill_w2 ;

assign  lmq1_pcx_pkt[`LMQ_VLD:0]  =  {lmq1_pcx_pkt_vld,
                                      lmq1_pcx_pkt_tmp[`LMQ_VLD-1:44],
                                      lmq1_pcx_pkt_way[1:0],
                                      lmq1_pcx_pkt_tmp[41:0]};
   
assign  ld_sec_hit_thrd1 =  
(ld_pcx_pkt_g_tmp[`LMQ_AD_HI:`LMQ_AD_LO+4] == lmq1_pcx_pkt[`LMQ_AD_HI:`LMQ_AD_LO+4]) ;            

// THREAD 2.
/*
dffe_s  #(`LMQ_WIDTH) lmq2 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq2_pcx_pkt[`LMQ_VLD:0]),
        .en     (lmq_enable[2]), .clk (clk),
        .se     (1'b0),       .si (),          .so ()
        );              
*/
wire lmq2_clk;   
`ifdef FPGA_SYN_CLK_EN
`else
clken_buf lmq2_clkbuf (
                .rclk   (clk),
                .enb_l  (~lmq_enable[2]),
                .tmb_l  (~se),
                .clk    (lmq2_clk)
                ) ;   
`endif

wire  [`LMQ_VLD:0]  lmq2_pcx_pkt_tmp;

`ifdef FPGA_SYN_CLK_DFF
dffe_s  #(`LMQ_WIDTH) lmq2 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq2_pcx_pkt_tmp[`LMQ_VLD:0]),
        .en (~(~lmq_enable[2])), .clk(clk),
        .se     (1'b0),       .si (),          .so ()
        ); 
`else
dff_s  #(`LMQ_WIDTH) lmq2 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq2_pcx_pkt_tmp[`LMQ_VLD:0]),
        .clk    (lmq2_clk),
        .se     (1'b0),       .si (),          .so ()
        ); 
`endif

//bug2705 - speculative pick in w-cycle
wire    lmq2_pcx_pkt_vld ;
assign  lmq2_pcx_pkt_vld  =  lmq2_pcx_pkt_tmp[`LMQ_VLD] & ~lsu_ld2_spec_vld_kill_w2 ;

   
assign  lmq2_pcx_pkt[`LMQ_VLD:0]  =  {lmq2_pcx_pkt_vld,
                                      lmq2_pcx_pkt_tmp[`LMQ_VLD-1:44],
                                      lmq2_pcx_pkt_way[1:0],
                                      lmq2_pcx_pkt_tmp[41:0]};

assign  ld_sec_hit_thrd2 =  
(ld_pcx_pkt_g_tmp[`LMQ_AD_HI:`LMQ_AD_LO+4] == lmq2_pcx_pkt[`LMQ_AD_HI:`LMQ_AD_LO+4]) ;            

// THREAD 3.
/*
dffe_s  #(`LMQ_WIDTH) lmq3 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq3_pcx_pkt[`LMQ_VLD:0]),
        .en     (lmq_enable[3]), .clk (clk),
        .se     (1'b0),       .si (),          .so ()
        );              
*/
wire lmq3_clk;   
`ifdef FPGA_SYN_CLK_EN
`else
clken_buf lmq3_clkbuf (
                .rclk   (clk),
                .enb_l  (~lmq_enable[3]),
                .tmb_l  (~se),
                .clk    (lmq3_clk)
                ) ;   
`endif

wire  [`LMQ_VLD:0]  lmq3_pcx_pkt_tmp;

`ifdef FPGA_SYN_CLK_DFF
dffe_s  #(`LMQ_WIDTH) lmq3 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq3_pcx_pkt_tmp[`LMQ_VLD:0]),
        .en (~(~lmq_enable[3])), .clk(clk),
        .se     (1'b0),       .si (),          .so ()
        ); 
`else
dff_s  #(`LMQ_WIDTH) lmq3 (
        .din    (ld_pcx_pkt_g_tmp[`LMQ_VLD:0]),
        .q      (lmq3_pcx_pkt_tmp[`LMQ_VLD:0]),
        .clk    (lmq3_clk),
        .se     (1'b0),       .si (),          .so ()
        ); 
`endif

//bug2705 - speculative pick in w-cycle
wire    lmq3_pcx_pkt_vld ;
assign  lmq3_pcx_pkt_vld  =  lmq3_pcx_pkt_tmp[`LMQ_VLD] & ~lsu_ld3_spec_vld_kill_w2 ;

   
assign  lmq3_pcx_pkt[`LMQ_VLD:0]  =  {lmq3_pcx_pkt_vld,
                                      lmq3_pcx_pkt_tmp[`LMQ_VLD-1:44],
                                      lmq3_pcx_pkt_way[1:0],
                                      lmq3_pcx_pkt_tmp[41:0]};


assign  ld_sec_hit_thrd3 =  
(ld_pcx_pkt_g_tmp[`LMQ_AD_HI:`LMQ_AD_LO+4] == lmq3_pcx_pkt[`LMQ_AD_HI:`LMQ_AD_LO+4]) ;            

// Select 1 of 4 LMQ Contents.
// selection is based on which thread's load is chosen for pcx.
mux4ds  #(`LMQ_WIDTH) lmq_pthrd_sel (
  .in0  (lmq0_pcx_pkt[`LMQ_WIDTH-1:0]),
  .in1  (lmq1_pcx_pkt[`LMQ_WIDTH-1:0]),
  .in2  (lmq2_pcx_pkt[`LMQ_WIDTH-1:0]),
  .in3  (lmq3_pcx_pkt[`LMQ_WIDTH-1:0]),
  .sel0 (ld_pcx_rq_sel[0]),  
  .sel1   (ld_pcx_rq_sel[1]),
  .sel2 (ld_pcx_rq_sel[2]),  
  .sel3   (ld_pcx_rq_sel[3]),
  .dout (load_pcx_pkt[`LMQ_WIDTH-1:0])
);
`endif

endmodule
