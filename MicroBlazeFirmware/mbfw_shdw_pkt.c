#include <stdlib.h>
#include <stdio.h>

#include <mb_interface.h>

#include "mbfw_types.h"
#include "mbfw_debug.h"
#include "mbfw_pcx_cpx.h"
#include "mbfw_shdw_pkt.h"


#define  SHDW_FSL_ID  2

#define  APPROX_ONE_SEC_COUNT    1200000
#define TIMEOUT 120

#ifdef  __cplusplus
extern "C" {
#endif

void shdw_cmd_pkt_init(struct shdw_cmd_pkt* shdw_cmd_pkt){
	shdw_cmd_pkt->cmd = 0x0;
}

void shdw_dd_pkt_init(struct shdw_dd_pkt* shdw_dd_pkt){
	shdw_dd_pkt->data = 0x0;
	shdw_dd_pkt->order = 0xFFFFFFFF;
}

void print_shdw_cmd_pkt(struct shdw_cmd_pkt* pkt){
	mbfw_printf("\r\n");
    mbfw_printf("MBFW_INFO: shdw_cmd_pkt: order 0x%08x \r\n", pkt->cmd);
    mbfw_printf("\r\n");
}

void print_shdw_dd_pkt(struct shdw_dd_pkt* pkt){
	mbfw_printf("\r\n");
    mbfw_printf("MBFW_INFO: shdw_dd_pkt: order 0x%08x \r\n", pkt->order);
    mbfw_printf("MBFW_INFO: shdw_dd_pkt: data  0x%08x \r\n", pkt->data);
    mbfw_printf("\r\n");
}

void send_shdw_cmd_pkt_to_fsl(struct shdw_cmd_pkt *shdw_cmd_pkt){
    int invalid;
    int send_error = 0;

    ncputfsl(shdw_cmd_pkt->cmd, SHDW_FSL_ID);
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

int recv_shdw_dd_pkt(struct shdw_dd_pkt *shdw_dd_pkt, int timeout_count){

    int fsl_invalid;
    int fsl_error;
    int count = 0;
	int i;
	for(i = 0; i < timeout_count; i++){
		ngetfsl(shdw_dd_pkt->data, SHDW_FSL_ID);
		fsl_isinvalid(fsl_invalid);
		fsl_iserror(fsl_error);
		if(!fsl_invalid)
			break;
	}
	
	if(fsl_invalid){
		if(fsl_error){
			return DD_DONE;
		}else{
			return DD_EMPTY;
		}
	}else{
		if(fsl_error){
			return DD_ERROR;
		}else{
			return DD_READ;
		}
	}
	return DD_ERROR;
}

void send_shdw_cmd_pkt(struct shdw_cmd_pkt *cmd_pkt){
	send_shdw_cmd_pkt_to_fsl(cmd_pkt);
}

void run_shdw_fsl(enum SH_STATE* state, int force_stop, int* data_valid, uint32_t* data){
	struct shdw_dd_pkt dd;
	struct shdw_cmd_pkt cmd;
	if(force_stop){
		cmd.cmd = CMD_VALID | CMD_RESET;
		send_shdw_cmd_pkt(&cmd);
		*state = IDLE;
	}
	switch(*state){
		case IDLE:
			if(!force_stop){
				cmd.cmd =  CMD_VALID | CMD_RESET;
				send_shdw_cmd_pkt(&cmd);
				*state = CAPTURING;
			}
			break;
		case CAPTURING:
			cmd.cmd = CMD_VALID | CMD_C_EN;
			send_shdw_cmd_pkt(&cmd);
			*state = DUMPING;
			break;
		case DUMPING:
			cmd.cmd = CMD_VALID | CMD_D_EN;
			send_shdw_cmd_pkt(&cmd);
			switch(recv_shdw_dd_pkt(&dd, TIMEOUT)){
				case DD_EMPTY:
					break;
				case DD_READ:
					*data_valid = 1;
					*data = dd.data;
					break;
				case DD_DONE:
					*state = DONE;
					break;
				case DD_ERROR:
					*state = IDLE;
					break;
				default:
					*state = IDLE;
					break;
			}
			break;
		case DONE:
			*state = IDLE;
			break;
		case ERROR:
			*state = IDLE;
			break;
		default:
			*state = ERROR;
			break;
	}
	
}


#ifdef  __cplusplus
}
#endif
