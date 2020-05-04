
#include "common.h"
#include "platform/interface.h"

#include "hw_accelerator.h"

// Note that these tree CMDs are same as
// they are defined in montgomery_wrapper.v
#define CMD_READ_CIPHER    0
#define CMD_READ_PDP       1
#define CMD_READ_R2R       2
#define CMD_COMPUTE        3
#define CMD_WRITE          4

#define CMD_READ    0

void init_HW_access(void)
{
	interface_init();
}

void compute_decrypt(uint32_t *ciphertext, uint32_t *keymod, uint32_t *r2rmod, uint32_t* decrypt_res){

	//sending the ciphertext
	send_cmd_to_hw(CMD_READ_CIPHER);
	send_data_to_hw(ciphertext);
	while(!is_done());

	//sending private key and mod value
	send_cmd_to_hw(CMD_READ_PDP);
	send_data_to_hw(keymod);
	while(!is_done());

	//sending R2modN and RmodN
	send_cmd_to_hw(CMD_READ_R2R);
	send_data_to_hw(r2rmod);
	while(!is_done());

	//computing decryption
	send_cmd_to_hw(CMD_COMPUTE);
	while(!is_done());


	//reading plaintext data data from fpga
	send_cmd_to_hw(CMD_WRITE);
	read_data_from_hw(decrypt_res);
	while(!is_done());


}


void example_HW_accelerator(void)
{
	int i;

	//// --- Create and initialize a 1024-bit src array
	//       as 32 x 32-bit words.
	//       src[ 0] is the least significant word
	//       src[31] is the most  significant word

	uint32_t src[32]={
		0x89abcdef, 0x01234567, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000};

	// --- Send the read command and transfer input data to FPGA
	
	xil_printf("Sending read command\n\r");

START_TIMING
	send_cmd_to_hw(CMD_READ);
	send_data_to_hw(src);
	while(!is_done());
STOP_TIMING


	//// --- Perform the compute operation

	xil_printf("Sending compute command\n\r");

	send_cmd_to_hw(CMD_COMPUTE);
	while(!is_done());
	
	//// --- Clear the array

	for(i=0; i<32; i++)
		src[i] = 0;

	//// --- Send write command and transfer output data from FPGA

	xil_printf("Sending write command\n\r");

START_TIMING
	send_cmd_to_hw(CMD_WRITE);
	read_data_from_hw(src);
	while(!is_done());
STOP_TIMING


	//// --- Print the array contents

	xil_printf("Printing the output data\n\r");

	print_array_contents(src);
}
