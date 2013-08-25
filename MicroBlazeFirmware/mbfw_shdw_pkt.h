/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_pcx_cpx.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
#include "mbfw_types.h"

/* Data dump conditions */
#define DD_EMPTY 	0
#define DD_READ		1
#define DD_DONE		2
#define DD_ERROR	3

/* SHadow FSL conditions */
#define SH_IDLE 		0
#define SH_CAPTURING	1
#define SH_DUMPING		2
#define	SH_DONE			3
#define SH_ERROR		4

#define CMD_VALID	1
#define CMD_ERR_EN 	2
#define CMD_ERR_CTRL_SHFT	2
#define CMD_ERR_CTRL_MASK	0x3FFC
#define CMD_RESET	0x4000
#define CMD_C_EN	0x8000
#define CMD_D_EN	0x10000
#define CMD_MASK	0x1FFFF

#ifdef  __cplusplus
extern "C" {
#endif

enum SH_STATE{
	IDLE	  = 0,
	CAPTURING = 1,
	DUMPING	  = 2,
	DONE	  = 3,
	ERROR	  = 4
} ;

/*
 * Shadow Command Packet Format
 */

struct shdw_cmd_pkt {
    uint32_t  cmd;	 
	 /**************************
	 |BIT	|		PURPOSE		|
	  0		-	Valid Packet
	  1		-	Error Enable
	  2-13	-	Error Control
	  14	-	Shadow Reset
	  15	-	Shadow Capture Enable
	  16	-	Shadow Dump Enable
	  17-31	-	Unused
	 ***************************/
};


/*
 * Shadow Data Dump Packet Format
 */

struct shdw_dd_pkt {
    uint32_t  data;
    uint32_t  order;
};


void shdw_cmd_pkt_init(struct shdw_cmd_pkt* shdw_cmd_pkt);
void shdw_dd_pkt_init(struct shdw_dd_pkt* shdw_dd_pkt);
void print_shdw_cmd_pkt(struct shdw_cmd_pkt* pkt);
void print_shdw_dd_pkt(struct shdw_dd_pkt* pkt);
void send_shdw_cmd_pkt(struct shdw_cmd_pkt *cmd_pkt);
int  recv_shdw_dd_pkt(struct shdw_dd_pkt* shdw_dd_pkt, int timeout_count);
void run_shdw_fsl(enum SH_STATE* state, int force_stop, int* data_valid, uint32_t* data);

#ifdef  __cplusplus
}
#endif
