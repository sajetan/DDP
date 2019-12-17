#ifndef _HW_ACCEL_H_
#define _HW_ACCEL_H_

void init_HW_access(void);
void example_HW_accelerator(void);

void compute_decrypt(uint32_t *ciphertext, uint32_t *keymod, uint32_t *r2rmod, uint32_t* decrypt_res);

#endif
