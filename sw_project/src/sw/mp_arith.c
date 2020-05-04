/*
 * mp_arith.c
 *
 */

#include <stdint.h>

// Calculates res = a + b.
// a and b represent large integers stored in uint32_t arrays
// a and b are arrays of size elements, res has size+1 elements
void mp_add1(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
	uint32_t carry=0;
	for (uint8_t i=0;i<size;i++){
		uint64_t sum=(uint64_t)a[i]+(uint64_t)b[i];
		res[i]=(uint32_t)sum+carry;
		carry = sum >>32 ;
		res[i+1]=carry;
	}
}

void mp_add(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
	uint32_t carry =0;
	for(uint8_t i=0;i<size;i++){
		res[i]=(a[i]+b[i]+carry) % (4294967296);
		if (((uint64_t)a[i]+(uint64_t)b[i]+carry) < 4294967296) carry=0;
		else carry=1;
		res[i+1]=carry;
	}
}


// Calculates res = a - b.
// a and b represent large integers stored in uint32_t arrays
// a, b and res are arrays of size elements

void mp_sub(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
	int carry =0;
	for(uint8_t i=0;i<size;i++){
		res[i]=(a[i]-b[i]+carry) ;
		if ((a[i])>=b[i]) carry=0;
		else {
			res[i]=4294967296+res[i] ;
			carry=-1;
		}
	}
}

// Calculates res = (a + b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_add(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
	uint32_t t[33]={0};
	mp_add1(a, b, t, size);

	if (t[32]>0 || t[31]>=N[31]){
		mp_sub(t,N,res, size);
	}
	else arr_copy(t, res, 32);

}



// Calculates res = (a - b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_sub(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
	uint32_t t[33];
	mp_sub(a, b, &t, size);
	if (b[31]>=a[31]){
		mp_add(&t,N,res, size);
	}
	else{
		memcpy(res, t,sizeof(t));
	}
}

