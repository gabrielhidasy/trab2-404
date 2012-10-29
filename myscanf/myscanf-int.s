.global _le_int
.type 	_le_int, %function
.global _le_uint
.type	_le_uint, %function
.global _le_lint
.type	_le_lint, %function
.global _le_luint
.type	_le_luint, %function
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
	addeq	r2, r2, #1
_le_int_loop:
	@get character from input buffer
	ldrb	r0, [r2]
	@if its an space or \n its the end
	cmp	r0, #' '
	beq _le_int_loop_out
	cmp	r0, #'\n'
	beq _le_int_loop_out
	@multiply the acumulator *10
	mov	r7, r6
	mov	ip, #10
	mul	r6, r7,	ip

	@next char
	add	r2, r2, #1
	@transforms in number
	sub	r0, r0, #48
	@if its less than zero or greater then 9
	@its not valid, error
	cmp	r0, #0
	blt	_myscanf_real_error
	cmp	r0, #9
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r6, r6, r0
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
	sub	r0, r0, #48
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

_le_luint:
	@not much different, but the multiplication use a function in
	@mathlib.s
	stmfd	sp!, {R4-R11, lr}
	@load the next pointer
	ldr	r5, [r11], #4
	@acummulator = r1:r0 = 0
	mov 	r1, #0
	mov 	r0, #0
_le_luint_loop:	
	@get character from input buffer
	ldrb	r4, [r2]
	@if its an space or \n its the end
	@------------------------------------
	cmp	r4, #' '
	beq	_le_uint_loop_out
	cmp	r4, #'\n'
	beq	_le_uint_loop_out
	@-----------------------------------
	@transforms in number
	sub	r4, r4, #48
	@if its less than zero or greater then 9
	@its not valid, error
	cmp	r4, #0
	blt	_myscanf_real_error
	cmp	r4, #9
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r0, r0, r4
	@and multiply by 10
	bl 	mult6410
	b 	_le_luint_loop
_le_uint_loop_out:
	str	r0, [r5], #1
	str	r1, [r5]
	ldmfd 	sp!, {R4 - R11, pc}

_le_lint:
	stmfd	sp!, {r4-r11, lr}
	@first get the first char, if its an - then set an flag (r8)
	@and go to luint, else just go to uints
	ldrb	r4, [r2]
	@load the next pointer
	ldr	r5, [r11], #4
	mov 	r8, #0
	ldrb	r0, [r2]
	cmp 	r0, #'-'
	@if the result is an -, set the flag
	moveq	r8, #1
	@and next char
	addeq	r2, r2, #1
	@now repeat the _le_luint_loop
_le_lint_loop:	
	@get character from input buffer
	ldrb	r4, [r2], #1
	@if its an space or \n its the end
	@------------------------------------
	cmp	r4, #' '
	beq	_le_lint_loop_out
	cmp	r4, #'\n'
	beq	_le_lint_loop_out
	@-----------------------------------
	@transforms in number
	sub	r4, r4, #48
	@if its less than zero or greater then 9
	@its not valid, error
	cmp	r4, #0
	blt	_myscanf_real_error
	cmp	r4, #9
	bgt	_myscanf_real_error
	@else add it to accumulator
	add 	r0, r0, r4
	@and multiply by 10
	bl 	mult6410
	b 	_le_lint_loop
_le_lint_loop_out:
	@invert the number, if needed
	@remembering that to invert an
	@64 bits you do rsb in both and
	@then subtract one in the most
	@significative part
	cmp 	r8, #0
	rsbne	r0, r0, #0
	rsbne	r1, r1, #0
	addne	r1, r1, #1
	str	r0, [r5], #4
	str	r1, [r5]
	ldmfd sp!, {R4 - R11, pc}

	