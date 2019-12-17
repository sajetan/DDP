/*
 * montgomery.h
 *
 */

#ifndef MONTOGOMERY_H_
#define MONTOGOMERY_H_

#include <stdint.h>
#include <arm_neon.h>


// These variables are defined in the testvector.c
// that is created by the testvector generator python script
extern uint32_t N[32],		// modulus
                e[32],		// encryption exponent
                e_len,		// encryption exponent length
                d[32],		// decryption exponent
                d_len,		// decryption exponent length
                M[32],		// message
                R_1024[32],	// 2^1024 mod N
                R2_1024[32],// (2^1024)^2 mod N
				N_prime[32],
				size ,
				expres[32],x_p[32],x_q[32], p[16], q[16],d_p[16],d_q[16], R2p[16],R2q[16],Rp[16],Rq[16];


// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements
void montMul(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size);
void montMulOpt(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size);
void montMulOptsq(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size);

uint32_t mont_exp(uint32_t *expres, uint32_t *message, uint32_t *n, uint32_t *n_prime, uint32_t *rmodn,uint32_t *r2modn,uint32_t *exp,uint32_t exp_len,uint32_t size);
uint32_t mont_exp_opt(uint32_t *expres, uint32_t *message, uint32_t *n, uint32_t *n_prime, uint32_t *rmodn,uint32_t *r2modn,uint32_t *exp,uint32_t exp_len,uint32_t size);

void add_fun(uint32_t *t, uint32_t i, uint32_t c);
void compute_invcrt(uint32_t *ptext, uint32_t *x, uint32_t *icrt,  uint32_t size);

#endif /* MONTOGOMERY_H_ */
