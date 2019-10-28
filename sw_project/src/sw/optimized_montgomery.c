/*
 * optimized_montgomery.c
 *
 *  Created on: Oct 27, 2019
 *      Author: r0767980
 */


#include "montgomery.h"

#include "common.h"

void print_num2(uint32_t *in, uint32_t size)
{
    int32_t i;
    xil_printf("0x");
    for (i = size-1; i >= 0; i--) {
    	xil_printf("%08x", in[i]);
    }
    xil_printf("\n\r");
}



void cond_sub(uint32_t * a, uint32_t* b, uint32_t* res, uint32_t size){
	if(a[size]!=0) {arr_copy(a, res, 32); return;}
	for(uint32_t i=size-1; i>=0; i--)
	{
		if(a[i]<b[i]){arr_copy(a, res, 32); return;}
		else break;
	}

	uint32_t carry = 0;
	for(uint32_t i = 0; i < size ; i++ )
	{
		a[i] = a[i]-b[i]-carry;
		if( a[i]-carry >= b[i] )
			carry = 0;
		else
			carry = 1;
	}
}

// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements
void montMulOpt(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size)
{

	uint32_t t[65]={0x0};
	uint32_t s;
	uint32_t z[65]={0x0};
	uint32_t temp_res [32]={0x0};
	for1_opt(size, a, b, t);
	for2_opt(size, n_prime[0], n, t);
	memcpy(temp_res, &t[size],2*8*size );
	cond_sub(temp_res, n,res,size);

}



