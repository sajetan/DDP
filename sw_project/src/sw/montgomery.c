/*
 * montgomery.c
 *
 */
#if 1

#include "montgomery.h"
#include <string.h>
#include "common.h"
void add_fun(uint32_t *t, uint32_t i, uint32_t c){
	uint64_t sum;
	while(c!=0){
		sum =(uint64_t)t[i]+(uint64_t)c;
		c=(uint32_t)(sum>> 32);
		t[i]=sum;
		i++;
	}
}


void cond_sub(uint32_t * a, uint32_t* b, uint32_t *res,  uint32_t size){

	for(uint32_t i=size-1; i>=0; i--){
		if(a[i]<b[i]){arr_copy(a, res, 32); return;}
		else break;
	}

	uint32_t carry = 0;

	for(uint8_t i=0;i<size;i++){
		res[i]=(a[i]-b[i]+carry);
		if ((a[i])>=b[i]) carry=0;
		else {
			res[i]=4294967296+res[i] ;
			carry=-1;
		}
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
		uint32_t c=0;
		uint32_t z = (uint32_t)((uint64_t) t[i]*(uint64_t)n_prime[0]);
		for (uint32_t j=0;j<size;j++){
			uint64_t sum =  (uint64_t) t[i+j]+(uint64_t)z*(uint64_t)n[j]+(uint64_t)c;
			c=sum>>32;
			t[i+j]=(uint32_t)sum;
		}
		add_fun(t,i+size,c);
	}


	memcpy(temp_res, &t[size],2*8*size );
	cond_sub(temp_res, n,res,size);

}



// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements
//Optimized montgomery multiplication
void montMulOpt(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size)
{
	uint32_t t[65]={0x0};
	uint32_t temp_res [33]={0x0};
	uint32_t temp_n [33]={0x0};
	mult_loop(size, a, b, t);

	red_loop(size, n_prime[0], n, t);

	arr_copy(&t[size], temp_res, 33);

	if(temp_res[32]==1){
		arr_copy(n, temp_n, 32);
	    cond_sub(temp_res, temp_n, res,size+1);
	}
	else cond_sub(temp_res, n, res,size);
}


//inverse chinese remainder theorem implementation
void compute_invcrt(uint32_t *ptext, uint32_t *x, uint32_t *icrt, uint32_t size){
	uint32_t temp_cq[32]={0x0};
	arr_copy(ptext, temp_cq, 16);
	montMulOpt(temp_cq,x,N,N_prime,icrt, size);
}


//Montgomery exponentiation using Optimized montgomery multiplication
uint32_t mont_exp(uint32_t *expres, uint32_t *message, uint32_t *n, uint32_t *n_prime, uint32_t *rmodn,uint32_t *r2modn,uint32_t *exp,uint32_t exp_len,uint32_t size){
	uint32_t r=0;
	uint32_t temp_A[32]={0x0};
	uint32_t x_til[32]={0x0};
	uint32_t One[32] = {1,0};
	montMulOpt(message,r2modn,n,n_prime,x_til, size);
	arr_copy(rmodn, temp_A, 32);
	uint32_t i=exp_len;
	for(i;i>0;i--){

		montMulOpt(temp_A,temp_A,n,n_prime,temp_A, size);

		if ((exp[0]>>i-1)&1==1){
			montMulOpt(temp_A,x_til,n,n_prime,temp_A, size);
		}
	}

	montMulOpt(temp_A,One,n,n_prime,expres, size);

	return temp_A;

}




#endif

