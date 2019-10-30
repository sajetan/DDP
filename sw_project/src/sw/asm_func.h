/*
 * asm_func.h
 *
 *  Created on: May 13, 2016
 *      Author: dbozilov
 */

#ifndef ASM_FUNC_H_
#define ASM_FUNC_H_

#include <stdint.h>

// a will be in register R0, b in R1, c in R2
// Result is stored in register r0
uint32_t add_3(uint32_t a, uint32_t b, uint32_t c);

//Adds all elements of array
uint32_t add_10(uint32_t *a, uint32_t n);

//Copies array a to array b
uint32_t arr_copy(uint32_t *a, uint32_t *b, uint32_t n);

// Function that calculates {t[i+1], t[i]} = a[0]*b[0] + m[0]*n[0]
// i is in R0, pointer to t array in R1, a array in R2, b array in R3
// pointer to m array is stored in [SP]
// pointer to n array is stored in [SP, #4] (one position above m)
void multiply(uint32_t i, uint32_t *t, uint32_t *a, uint32_t *b, uint32_t *m, uint32_t *n);

uint32_t test1();

uint32_t opt_basic_add(uint32_t a, uint32_t b,uint32_t carry);
uint32_t opt_multiply( uint32_t a, uint32_t b, uint32_t i, uint32_t *t, uint32_t c);
uint32_t basic_multiply( uint32_t a, uint32_t b);

//multiplication loop
uint32_t for1_opt(uint32_t size, uint32_t *a, uint32_t *b, uint32_t *t);
//reduction+carry propogation loop
uint32_t for2_opt(uint32_t size, uint32_t n_prime_zero, uint32_t *n, uint32_t *t);

#endif /* ASM_FUNC_H_ */
