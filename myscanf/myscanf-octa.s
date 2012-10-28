.global _le_locta
.type	_le_locta, %function
.global _le_octa
.type	_le_octa, %function
_le_octa:
	stmfd	sp!, {R4-R11, lr}
	@load the next pointer
	ldr	r5, [r11], #4
	@acummulator = r6 = 0
	mov 	r6, #0
_le_octa_loop:	
	@get character from input buffer
	ldrb	r0, [r2]
	@if its an space or \n its the end
	cmp	r0, #' '
	streq	r6, [r5]
	ldmeqfd 	sp!, {R4 - R11, pc}
	cmp	r0, #'\n'
	streq	r6, [r5]
	ldmeqfd 	sp!, {R4 - R11, pc}
	@next char
	add	r2, r2, #1
	@transforms in number
	sub	r0, r0, #48
	@if its less than zero or greater then 7
	@its not valid, error
	cmp	r0, #0
	blt	_myscanf_real_error
	cmp	r0, #7
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r6, r6, r0
	@and do the 3 - bitshift to left
	mov	r6, r6, lsl #3
	b 	_le_octa_loop
_le_locta:
	stmfd	sp!, {R4-R11, lr}
	@load the next pointer
	ldr	r5, [r11], #4
	@acummulator = r1:r0 = 0
	mov 	r1, #0
	mov	r0, #0
_le_locta_loop:	
	@get character from input buffer
	ldrb	r4, [r2]
        @---------------------------------------
	@if its an space or \n its the end
	cmp	r4, #' '
	streq	r1, [r5], #1
	streq	r0, [r5]
	ldmeqfd 	sp!, {R4 - R11, pc}
	cmp	r4, #'\n
	streq	r1, [r5], #1
	streq	r0, [r5]
	@--------------------------------------
	@next char
	add 	r2, r2, #1
	@transforms in number
	sub	r4, r4, #48
	@if its less than zero or greater then 7
	@its not valid, error
	cmp	r4, #0
	blt	_myscanf_real_error
	cmp	r4, #7
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r0, r0, r4
	@and do the 3 - bitshift to left
	bl 	long3lsl
	b 	_le_locta_loop
