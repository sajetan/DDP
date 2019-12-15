/*
 * montgomery.h
 *
 */

#ifndef MONTOGOMERY_H_
#define MONTOGOMERY_H_

#include <stdint.h>
#include <arm_neon.h>
// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements
void montMul(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size);
void montMulOpt(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size);
void montMulOptsq(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size);

uint32_t mont_exp(uint32_t *expres, uint32_t *message, uint32_t *n, uint32_t *n_prime, uint32_t *rmodn,uint32_t *r2modn,uint32_t *exp,uint32_t exp_len,uint32_t size);
uint32_t mont_exp_opt(uint32_t *expres, uint32_t *message, uint32_t *n, uint32_t *n_prime, uint32_t *rmodn,uint32_t *r2modn,uint32_t *exp,uint32_t exp_len,uint32_t size);

void add_fun(uint32_t *t, uint32_t i, uint32_t c);

#endif /* MONTOGOMERY_H_ */