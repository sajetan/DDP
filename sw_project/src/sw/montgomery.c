/*
 * montgomery.c
 *
 */
#if 1

#include "montgomery.h"

void add_fun(uint32_t *t, uint32_t i, uint32_t c){
	uint64_t sum;
	while(c!=0){
		sum =(uint64_t)t[i]+(uint64_t)c;
		c=(uint32_t)(sum>> 32);
		t[i]=sum;
		i++;
	}
}


void cond_sub(uint32_t * a, uint32_t* b,  uint32_t size){
	if(a[size]!=0) return;
	for(uint32_t i=size-1; i>=0; i--)
	{
		if(a[i]<b[i])return;
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
	cond_sub(temp_res, n,size);
	memcpy(res, temp_res,8*size);

}



// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements
//Optimized montgomery multiplication
void montMulOpt(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size)
{

	uint32_t t[65]={0x0};
	uint32_t s;
	uint32_t z[65]={0x0};
	uint32_t temp_res [32]={0x0};
	for1_opt(size, a, b, t);
	for2_opt(size, n_prime[0], n, t);
	memcpy(temp_res, &t[size],2*8*size);
	cond_sub(temp_res, n, size);
	memcpy(res, temp_res,8*size);

}

#endif

