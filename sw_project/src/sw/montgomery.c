/*
 * montgomery.c
 *
 */

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


void add_fun(uint32_t *t, uint32_t i, uint32_t c){
	uint64_t sum;
	while(c!=0){
		sum =(uint64_t)t[i]+(uint64_t)c;
		c=(uint32_t)(sum>> 32);
		t[i]=sum;
		i++;
	}
}



void cond_sub(uint32_t * a, uint32_t* b, uint32_t* res, uint32_t size){
	if(a[size]!=0)  return;
	for(uint32_t i=size-1; i>=0; i--)
	{
		if(a[i]<b[i]) return;
		else break;
	}

	uint32_t carry = 0;
	for(uint32_t i = 0; i < size ; i++ )
	{
		res[i] = a[i]-b[i]-carry;
		if( a[i]-carry >= b[i] )
			carry = 0;
		else
			carry = 1;
	}
}

// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements
void montMul(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size)
{

	uint32_t t[65]={0x0};
	uint32_t s;
	uint32_t z [65]={0x0};
	uint32_t temp_res [32]={0x0};

	for(uint32_t i=0;i<size;i++){
		uint32_t c=0;
		for(uint32_t j=0;j<size;j++){

			uint64_t sum =  (uint64_t) t[i+j]+(uint64_t)a[j]*(uint64_t)b[i]+(uint64_t)c;
			c=(uint32_t)(sum>>32);
			s=(uint32_t)sum;
			t[i+j]=s;
		}
		t[i+size]=c;
	}



	for(uint32_t i=0;i<size;i++){
		//xil_printf("--debug 1\n\r");
		uint32_t c=0;
		uint32_t z = (uint32_t)((uint64_t) t[i]*(uint64_t)n_prime[0]);
		for (uint32_t j=0;j<size;j++){
			uint64_t sum =  (uint64_t) t[i+j]+(uint64_t)z*(uint64_t)n[j]+(uint64_t)c;
			c=sum>>32;
			t[i+j]=(uint32_t)sum;
			//xil_printf("i=%d j=%d sum [0x%x] carry[0x%x]\n\r", i,j,a[j],b[i], sum, c);

		}
		//xil_printf("--debug 2\n\r");
		//ADDa(t,i+size,c);
		add_fun(t,i+size,c);
		//xil_printf("--debug 3\n\r");
		//xil_printf("%x", t[i]);
	}
	xil_printf(" Res lol");
	print_num1(res, 32);

	xil_printf(" t ");
	print_num1(t, 65);

	for(uint32_t i=0;i<=size;i++){
		temp_res[i]=t[i+size];
	}

	xil_printf(" Res ");
	print_num1(temp_res, 32);
	xil_printf("\n\r");

	xil_printf("n =");
	print_num1(n, 32);
	xil_printf("\n\r");

	cond_sub(temp_res, n,res,size);


//	uint32_t i=size-1;
//	uint32_t done=0;
//	while(done!=1){
//		xil_printf("res 0x%x  0x%x \n", temp_res[i] ,n[i]);
//		//if (temp_res[size+1]==1){done=1;xil_printf("size+1 = 1\r\n");}
//		if (temp_res[i]>n[i]){ done=1;xil_printf("temp is greater than n %d \r\n",i);}
//		if (done==1){
//			xil_printf("Doing subtraction\r\n");mp_sub(temp_res, n,res,size );
//
//
//			xil_printf("Res = 0x");
//			for (uint32_t i = 0; i <size; i++){
//				xil_printf("%x", res[i]);
//			}
//			xil_printf("\n\r");
//
//			break;}
//		i--;
//	}
//


}
