#include "common.h"
#include "hw_accelerator.h"
#include <stdint.h>
#include <inttypes.h>

#include "mp_arith.h"
#include "montgomery.h"


void print_num(uint32_t *in, uint32_t size)
{
    int32_t i;

    xil_printf("0x");
    for (i = size-1; i >= 0; i--) {
    	xil_printf("%08x", in[i]);
    }
    xil_printf("\n\r");
}



int main()
{
    init_platform();
    init_performance_counters(1);

/*--------------------------------------------------------------------------------------------------------
 * RSA Implementation
--------------------------------------------------------------------------------------------------------*/

    uint32_t size = 32;

    uint32_t ciphertext[32]={0};
    uint32_t gp1[32]={0};
    uint32_t gp2[32]={0};

	uint32_t plaintext_q[32]={0};
	uint32_t plaintext_p[32]={0};
    uint32_t plaintext[32]={0};

    arr_copy(d_p, gp1, 16);
    arr_copy(p, &gp1[16], 16);

    arr_copy(Rp,  gp2, 16);
    arr_copy(R2p, &gp2[16], 16);

	xil_printf("MESSAGE     =  ");
	print_num(M, 32);
	xil_printf("\n\r");

	//COMPUTE CIPHERTEXT USING MONTGOMERY EXPONENTIATION
    START_TIMING //////////////////////////////////////////////////////////////////////
	mont_exp(ciphertext,  M, N, N_prime, R_1024,R2_1024,e,e_len, size);
    STOP_TIMING //////////////////////////////////////////////////////////////////////

	xil_printf("CIPHERTEXT =  ");
	print_num(ciphertext, 32);
	xil_printf("\n\r");

	//INITIATE HW ACCESS
    init_HW_access();

    START_TIMING //////////////////////////////////////////////////////////////////////
    //DECRYPT STAGE 1
	compute_decrypt(ciphertext, gp1, gp2,plaintext_p);

	memset(gp1,0x00,32);
	memset(gp2,0x00,32);
    arr_copy(d_q, gp1, 16);
    arr_copy(q, &gp1[16], 16);

    arr_copy(Rq,  gp2, 16);
    arr_copy(R2q, &gp2[16], 16);

    //DECRYPT STAGE 2

	compute_decrypt(ciphertext, gp1, gp2, plaintext_q);

	memset(gp1,0x00,32);
	memset(gp2,0x00,32);
	
	//COMPUTING INVERSE CRT
	compute_invcrt(&plaintext_p[16],x_p,gp1, size);

	compute_invcrt(&plaintext_q[16],x_q,gp2, size);

	mod_add(gp1, gp2, N, &plaintext, 32);

	montMulOpt(plaintext,R2_1024,N,N_prime,plaintext, size);
	STOP_TIMING //////////////////////////////////////////////////////////////////////

	xil_printf("PLAINTEXT    =  ");
	print_num(plaintext, 32);
	xil_printf("\n\r");

    cleanup_platform();

    return 0;
}
