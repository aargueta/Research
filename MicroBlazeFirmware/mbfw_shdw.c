/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: 
* 
* ========== Copyright Header End ============================================
*/
#include <stdlib.h>
#include <stdio.h>

#include <mb_interface.h>

#include "mbfw_types.h"
#include "mbfw_debug.h"
#include "mbfw_pcx_cpx.h"



#define  FSL_ID  0



#define  APPROX_ONE_SEC_COUNT    1200000
#define  FSL_PCX_RECV_TIMEOUT    (60 * APPROX_ONE_SEC_COUNT)

#ifdef  __cplusplus
extern "C" {
#endif


static void
recv_pcx_pkt_data_word(uint_t *buffer)
{
    int fsl_invalid;
    int fsl_error;
    int count = 0;

    do {
#if (MBFW_DEBUG > 0)
	if (count >= FSL_PCX_RECV_TIMEOUT) {
	    mbfw_printf("MBFW_WARN: timed out waiting for pcx_pkt data word "
									"\r\n");
	    count = 0;
	}
	count++;
#endif

        ngetfsl(*(buffer), FSL_ID);
        fsl_isinvalid(fsl_invalid);
        fsl_iserror(fsl_error);
    } while (fsl_invalid || fsl_error);

    return;
}


static int
recv_pcx_pkt_ctrl_word(uint_t *buffer, int timeout_count)
{
    int fsl_invalid;
    int fsl_error;
    int count = 0;

    do {
		if (timeout_count > 0) {
			timeout_count--;
		}
        ncgetfsl(*(buffer), FSL_ID);
        fsl_isinvalid(fsl_invalid);
        fsl_iserror(fsl_error);
    } while ((fsl_invalid || fsl_error) && (timeout_count != 0));

    if (fsl_invalid || fsl_error) {
	return -1;
    }

    return 0;
}



int
recv_pcx_pkt(struct pcx_pkt *pcx_pkt, int timeout_count)
{

    if (recv_pcx_pkt_ctrl_word(&pcx_pkt->addr_hi_ctrl, timeout_count) < 0) {
        return -1;
    }

    recv_pcx_pkt_data_word(&pcx_pkt->addr_lo);
    recv_pcx_pkt_data_word(&pcx_pkt->data1);
    recv_pcx_pkt_data_word(&pcx_pkt->data0);
    return;
}



void send_shdw_cmd_pkt_to_fsl(int core_id, struct shdw_cmd_pkt* shdw_cmd_pkt){
    int invalid;
    int send_error = 0;

    ncputfsl(shdw_cmd_pkt->ctrl, FSL_ID);
    fsl_isinvalid(invalid);
    send_error |= invalid;

    if (send_error) {
		mbfw_printf("MBFW_ERROR: Encountered FSL FIFO full condition while "
						    "sending shadow command packet \r\n");
		print_shdw_cmd_pkt(shdw_cmd_pkt);
		mbfw_exit(1);
    }

    return;
}

void print_shdw_cmd_pkt(struct shdw_cmd_pkt *pkt){
    mbfw_printf("\r\n");
    mbfw_printf("MBFW_INFO: shdw_cmd_pkt: ctrl  0x%08x \r\n", pkt->ctrl);
    mbfw_printf("\r\n");
}

#ifdef  __cplusplus
}
#endif

