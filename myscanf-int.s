.global _le_int
.type 	_le_int, %function
.global _le_uint
.type	_le_uint, %function
.global _le_lint
.type	_le_lint, %function
.global _le_luint
.type	_le_luint, %function
.
_le_int:
	@just the same as luint but if the first char
	@is an - you need to do the rsb
	stmfd	sp!, {R4-R11, lr}
	@load the next pointer
	ldr	r5, [r11], #4
	@acummulator = r6 = 0
	mov 	r6, #0
	mov 	r8, #0
	@get the first char
	ldrb	r0, [r2]
	cmp	r0, #'-'
	@if it is an minus, the result will be the negative
	@set the flag r8 for this
	moveq	r8, #1
	@and next char
	add	r2, r2, #1
_le_int_loop:	
	@get character from input buffer
	ldrb	r0, [r2]
	@if its an space or \n its the end
	cmp	r0, #' '
	b _le_int_loop_out
	cmp	r0, #'\n'
	b _le_int_loop_out
	@next char
	add	r2, r2, #1
	@transforms in number
	bl 	chartonumber
	@if its less than zero or greater then F
	@its not valid, error
	cmp	r0, #0
	blt	_myscanf_real_error
	cmp	r0, #15
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r6, r6, r0
	@multiply by 10
	mov	r7, r6
	mov	ip, #10
	mul	r6, r7,	ip
	b 	_le_int_loop
_le_int_loop_out:
	cmp	r8, #0
	rsbne	r6, r6, #0
	str	r6, [r5]
	ldmfd 	sp!, {R4 - R11, pc}
_le_uint:
	stmfd	sp!, {R4-R11, lr}
	@load the next pointer
	ldr	r5, [r11], #4
	@acummulator = r6 = 0
	mov 	r6, #0
_le_uint_loop:	
	@get character from input buffer
	ldrb	r0, [r2]
	@if its an space or \n its the end
	cmp	r0, #' '
	streq	r6, [r5]
	ldmeqfd 	sp!, {R4 - R11, pc}
	cmp	r0, #'\n'
	streq	r6, [r5]
	ldmeqfd 	sp!, {R4 - R11, pc}
	@transforms in number
	bl 	chartonumber
	@if its less than zero or greater then 9
	@its not valid, error
	cmp	r0, #0
	blt	_myscanf_real_error
	cmp	r0, #9
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r6, r6, r0
	@and do multiply by 10
	mov 	r7, r6
	mov	ip, #10
	mul	r6, r7, ip
	b 	_le_uint_loop

_le_lint:
_le_luint:
	ldr 	r0, =notimp
	bl 	myprintf
	b	_myscanf_real_error
