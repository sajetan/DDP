/*
 * montgomery.c
 *
 */

#include "montgomery.h"

// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements



void add_fun(uint32_t *t, uint32_t i, uint32_t c){
	while(c!=0){
		uint64_t sum =(uint64_t)t[i]+(uint64_t)c;
		t[i]=sum;
		i++;
	}
	xil_printf("addn fun = 0x");
	for(uint32_t i=0;i<65;i++){
			xil_printf("%x", t[i]);
		}
	xil_printf("\n\r");
}


// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements
void montMul(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size)
{

	uint32_t t[65]={0x0};
	uint32_t z [65]={0x0};

	for(uint32_t i=0;i<size;i++){
		uint32_t c=0;
		for(uint32_t j=0;j<size;j++){
			xil_printf("a=0x%x b=0x%x 0x%x  0x%x  0x%x\n\r", a[i],b[i],a[i]*b[i] , t[i+j], c);
			uint64_t sum =  (uint64_t) t[i+j]+(uint64_t)(a[i]*b[i])+(uint64_t)c;
			c=sum>>32;
			t[i+j]=(uint32_t)sum;
		}
		t[i+size]=c;
	}


	xil_printf("val = 0x");
	for(uint32_t i=0;i<65;i++){
		xil_printf("%x", t[i]);
	}
	xil_printf("\n\r");


	for(uint32_t i=0;i<size;i++){
		xil_printf("--debug 1\n\r");
		uint32_t c=0;
		uint32_t z = (uint32_t) t[i]+n_prime[0];
		for (uint32_t j=0;j<size;j++){
			uint64_t sum =  (uint64_t) t[i+j]+(uint64_t)(z*n[j])+(uint64_t)c;
						c=sum>>32;
						t[i+j]=(uint32_t)sum;

		}
		xil_printf("--debug 2\n\r");
		add_fun(&t,i,c);
		xil_printf("--debug 3\n\r");
		//xil_printf("%x", t[i]);
	}

	for(uint32_t i=0;i<=size;i++){
		res[i]=t[i+size];
	}


	xil_printf("Res = 0x");
	for(uint32_t i=0;i<32;i++){
		xil_printf("%x", t[i]);
	}
	xil_printf("\n\r");


}




