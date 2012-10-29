.global _le_hexa
.type _le_hexa, %function
.global _le_lhexa
.type _le_lhexa, %function
_le_hexa:
	stmfd	sp!, {R4-R11, lr}
	@load the next pointer
	ldr	r5, [r11], #4
	@acummulator = r6 = 0
	mov 	r6, #0
_le_hexa_loop:	
	@get character from input buffer
	ldrb	r0, [r2]
	@if its an space or \n its the end
	cmp	r0, #' '
	moveq	r6, r6, lsr #4
	streq	r6, [r5]
	ldmeqfd 	sp!, {R4 - R11, pc}
	cmp	r0, #'\n'
	moveq	r6, r6, lsr #4
	streq	r6, [r5]
	ldmeqfd 	sp!, {R4 - R11, pc}
	@next char
	add 	r2, r2, #1
	@transforms in number
	sub	r0, r0, #48
	cmp	r0, #'9'
	subgt	r0, r0, #39
	@if its less than zero or greater then F
	@its not valid, error
	cmp	r0, #0
	blt	_myscanf_real_error
	cmp	r0, #15
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r6, r6, r0
	@and do the 4 - bitshift to left
	@on acumulator
	mov	r6, r6, lsl #4
	b 	_le_hexa_loop
_le_lhexa:
	stmfd	sp!, {R4-R11, lr}
	@load the next pointer
	ldr	r5, [r11], #4
	@acummulator = r1:r0 = 0
	mov 	r1, #0
	mov	r0, #0
_le_lhexa_loop:	
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
	cmp 	r4, #'9'
	subgt	r4, #39
	@if its less than zero or greater then F
	@its not valid, error
	cmp	r4, #0
	blt	_myscanf_real_error
	cmp	r4, #15
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r0, r0, r4
	@and do the 4 - bitshift to left
	bl 	long4lsl
	b 	_le_lhexa_loop
