.text

.global add_3
.func add_3, add_3
.type add_3, %function

add_3:
add r0, r0, r1
add r0, r0, r2
bx lr
.endfunc

.text

.global add_10
.func add_10, add_10
.type add_10, %function

add_10:
cmp r1, #0                           @compare (alter flag)
beq end_add                          @branch when equal, go to end
mov r2, #0
add_loop:
	ldr r3, [r0], #4                 @step1. read [r0] and give r3 (the address of r0) step2. r0 + 4
	add r2, r2, r3
	subs r1, r1, #1                  @change the zero flag (if r1 =0, z = 1)
	bne  add_loop                    @z = 0, go to add_loop
mov r0, r2
end_add:
bx lr @go back
.endfunc

/////////

.text

.global opt_basic_add
.func opt_basic_add, opt_basic_add
.type opt_basic_add, %function

opt_basic_add:
cmp r2,#0
add r0, r0,r1
beq LoopDone

ldr r3, [r0],#4
CMN r3,r2
adc r3,r3,r2
str r3, [r0]
//setc r2
LoopDone:

cmn r0,r1
adc r0, r0, r1

bx lr
.endfunc



.text

.global arr_copy
.func arr_copy, arr_copy
.type arr_copy, %function

arr_copy:
cmp r2, #0
beq end_add
copy_loop:
	ldr r3, [r0], #4
	str r3, [r1], #4
	subs r2, r2, #1
	bne  copy_loop
end_copy:
bx lr
.endfunc

.text

.global multiply
.func multiply, multiply
.type multiply, %function

multiply:
	push {r4-r9}       @push original value from registors to memory
	// If more registers are used in the function make sure to do push them on the stack to preserve them
	ldr r4, [sp, #24]		@m pointer is stored in R4
	ldr r5, [sp, #28]		@n pointer is stored in R5
	add r1, r1, r0, lsl #2
	ldr r6, [r4]            @read the value of r4
	ldr r7, [r5]
	umull r8, r9, r6, r7
	ldr r6, [r2]
	ldr r7, [r3]
	umull r4, r5, r6, r7
	adds r8, r8, r4
	adc r9, r9, r5
	stmia r1, {r8, r9}  @r1:the address in memory
	pop {r4-r9}       @take back the original value
	bx lr
.endfunc


//opt_multiply
.text

.global opt_multiply
.func opt_multiply, opt_multiply
.type opt_multiply, %function

opt_multiply:
	push {r4-r9}
	ldr r5, [sp, #24]
	add r3, r3, r2, lsl #2
	ldr r4, [r3]
	umull r8, r9, r0,r1
	adds r8 , r8,r4
	adc  r9 ,r9,#0
	adds r8 , r8,r5
	adc  r9 ,r9 ,#0

	str r8, [r3]
	mov r0, r9
	pop {r4-r9}

	bx lr
.endfunc


.text

.global basic_multiply
.func basic_multiply, basic_multiply
.type basic_multiply, %function

basic_multiply:
	mul r0,  r0,r1
	bx lr
.endfunc



/////////////

.text

.global for1_opt
.func for1_opt, for1_opt
.type for1_opt, %function

for1_opt:
	push {r4-r12}				@push original value from registors to memory
	mov r4 , #0					@ r4 = i = size         //r0 r1 r5
outerloop:
	cmp r4, r0					@if i = 0 ??
	beq outerloopDone
	mov r12 , #0                @ r14 = C = 0
	mov r5 , #0					@ j = size = r5   for inner loop

innerloop:
	cmp r5, r0                  @ r5 =j = 0
	beq innerloopDone
	
//	add r7, r1, r5, lsl #2      @ a[j]
//	add r8, r2, r4, lsl #2		@ b[i]
	ldr r7, [r1, r5, lsl #2]				@ r7=a[j]
	ldr r8, [r2, r4, lsl #2]				@r8 = b[i]
	add r6, r4, r5 			 	@ r6=i+j

//	add r6, r3, r6, lsl #2      @ t[i+j]

	ldr r10, [r3, r6, lsl #2]				@r9 = t[i+j]
	mov r11, #0

	umlal r10, r11, r7,r8       @ r10, r11 = r7*r8 = a[j]*b[i]+t[i+j]
	//adds r10 , r10,r9			@r10 = r10+r9 == a[j]+b[i]+t[i+j] only LSB
	//adc  r11 ,r11,#0			@r11 = r11+0+Carry
	adds r10 , r10, r12			@r10 = r10+C
	adc  r11 ,r11 ,#0			@r11 = r11+0+Carry
	str r10, [r3, r6, lsl #2]				@t[i+j]=r10
	mov r12, r11				@C=r11
	add r5 ,r5, #1				@ j = j+1
	b innerloop
innerloopDone:
	add r9, r4, r0
	//add r9, r3, r9, lsl #2		@ t[i+size]
	str r12, [r3, r9, lsl #2]				@ t[i+size]=C
	add r4,r4, #1 				@ i=i+1
	b outerloop
outerloopDone:
	pop {r4-r12}     			@take back the original value
	//mov r0, r3
	bx lr 						@go back
.endfunc

/////////////////for second nexted loop
.text

.global for2_opt
.func for2_opt, for2_opt
.type for2_opt, %function

for2_opt:
	push {r4-r12}				@push original value from registors to memory
	mov r4 , #0					@ r4 = i = size         //r0 r1 r5
outerloop2:
	cmp r4, r0					@if i = 0 ??
	beq outerloopDone2
	mov r12 , #0                @ r12 = C = 0
	//add r7, r3, r4, lsl #2		@t[i]
	ldr r7, [r3, r4, lsl #2]
	mul r6, r7, r1				@r6 = z= n_prime*t[i]
	mov r5 , #0					@ j = size = r5   for inner loop

innerloop2:
	cmp r5, r0                  @ r5 =j = 0
	add r7, r4, r0
	beq add_fun
	
	//add r10, r2, r5, lsl #2     @ n[j]
	ldr r9, [r2, r5, lsl #2] 				@ load r10=n[j]
	
	add r8, r4, r5 			 	@ r8=i+j
	//add r8, r3, r8, lsl #2      @ r8=t[i+j]
	ldr r10, [r3, r8, lsl #2]				@r9 = t[i+j]
	mov r11, #0
	umlal r10, r11, r6,r9      @ r10, r11 = r6*r10 = z*n[j]
//	adds r10 , r10, r9			@r10 = r10+r9 == z+n[j]+t[i+j] only LSB
//	adc  r11 ,r11,#0			@r11 = r11+0+Carry
	adds r10 , r10, r12			@r10 = r10+C
	adc  r11 ,r11 ,#0			@r11 = r11+0+Carry
	str r10, [r3, r8, lsl #2]				@t[i+j]=r10

	mov r12, r11				@C=r11

	add r5 ,r5, #1				@ j = j+1
	b innerloop2
add_fun:
	cmp r12, #0

    beq add_funDone
//	add r10, r3, r7, lsl #2		@r7=t[i+size]
	ldr r9, [r3, r7, lsl #2]
	adds r9, r9, r12
	str r9, [r3, r7, lsl #2]
	mov r12,#0
	adc r12, r12, #0
	add r7, r7, #1
	b add_fun

add_funDone:
	add r4,r4, #1 				@ i=i+1
	b outerloop2

outerloopDone2:
	pop {r4-r12}     			@take back the original value
	//mov r0, r3
	bx lr 						@go back
.endfunc

/////////////////////




@USEFUL FUNCTIONS

@ add Rx, Ry, Rz	//Rx = Ry + Rz  second operand can be constant
@ sub Rx, Ry, Rz	//Rx = Ry - Rz second operand can be constant
@ addc Rx, Ry, Rz	//Rx = Ry + Rz + CARRY   one operand can be constant
@ cmp Rx, Ry		//compares Rx and Ry and if they are equal sets Z flag, otherwise resets Z flag (works by subtracting two values and checks if result is zero)
@ b{cond} <label>		//Jumps to given label in the code if given condition is satisfied
@ umull Rn, Rm, Rx, Ry 	//{Rm, Rn} = Rx * Ry Multiplies unsigned 32bit values in Rx and Ry. Stores the higher 32 bits in Rm, and lower in Rn
@ ldr Rx, [Ry]		//Loads from memory pointed by Ry to register Rx, see addressing modes for post increment, pre decrement
@ str Rx, [Ry]		//Stores to memory pointed by Ry value in register Rx, see addressing modes for post increment, pre decrement
@ pop {}			//Pops values from stack to specified registers in order they are specified
@ push {}			//Push registers to stack in orded they are specified
@ ldmia rx, {set of registers} //Loads to specified set of registers memory values, starting from rx. Increasing addresses
@ stmia rx, {set of registers} //Stores specified set of registers in memory, starting from address pointed by rx. Increasing addresses
