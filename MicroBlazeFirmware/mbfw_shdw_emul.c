
#include <stdlib.h>
#include <stdio.h>

#include "mbfw_shdw_pkt.h"
#include "mbfw_l2_emul.h"

#define DD_EMPTY 	0
#define DD_READ		1
#define DD_DONE		2
#define DD_ERROR	3

#define TIMEOUT_COUNT 4

void run_shdw_fsl(int FSL_ID, struct shdw_cmd_pkt* cmd_pkt, struct shdw_dd_pkt* dd_pkt){
	int dd_fsl_state = recv_shdw_dd_pkt(dd_pkt, TIMEOUT_COUNT);
	switch(dd_fsl_state){
		case DD_EMPTY:
			break;
		case DD_READ:
			// STORE READ DD PACKET
			break;
		case DD_DONE:
			// SEND CMD PACKET TO RECAPTURE
			break;
		case DD_ERROR:
			// SEND CMD PACKET TO RECAPTURE
			// DISCARD PACKET
			break;
		default:
			// SEND CMD PACKET TO RECAPTURE
			// DISCARD PACKET
			break;
	}
}