.global _trata_hex_long
.global	_trata_hex_short
.type _trata_hex_long, %function
.type _trata_hex_short, %function

_trata_hex_long:
	stmfd sp!, {R4-R11,lr}
	mov	r6, r4
	@save r1 and r0  in a safe place
	mov	r9, r0 
	mov	r10, r1
	@r2 e r2+4 ou r2+4 e r2+8
	and 	r3, r2, #7
	cmp 	r3, #0
	addne	r2, r2, #4
	@r2 tem o endereço do parametro
	ldr	r0, [r2], #4	
	ldr	r1, [r2], #4
	@basta comparar com a mascara F
	@somar 48, se maior que 9 soma 39
	@por na pilha e deslocar
	mov 	r5, #0
_trata_hex_long_loop:
	and 	r4, r0, #0xF
	add 	r4, r4, #48
	cmp 	r4, #'9'
	addgt	r4, r4, #39
	cmp	r6, #'X'
	cmp	r6, #'X'
	bleq	HEXA_MAI
	stmfd	sp!, {r4}
	add	r5, r5, #1
	bl	long4lsr
	cmp 	r1, #0
	cmpeq	r0, #0
	@recuperate r1 e r0
	moveq	r1, r10
	moveq	r0, r9
	beq	_trata_hex_long_out
	b	_trata_hex_long_loop 
_trata_hex_long_out:
	ldmfd	sp!, {r4}
	strb	r4, [r1], #1
	sub 	r5, r5, #1
	cmp 	r5, #0
	bne	_trata_hex_long_out
	ldmfd	sp!,  {R4-R11, pc}

HEXA_MAI:
	cmp	r4, #'a'
	subge	r4, r4, #32
	mov	pc, lr
	
_trata_hex_short:
	stmfd sp!, {R4-R11,lr}
	@r2 tem o endereço do parametro
	ldr	r3, [r2], #4
	@basta comparar com a mascara F
	@somar 48, se maior que 9 somar
	@39 e por na pilha e deslocar
	mov 	r5, #0
_trata_hex_short_loop:
	and 	r4, r3, #0xF
	add 	r4, r4, #48
	cmp 	r4, #'9'
	addgt	r4, r4, #39
	cmp	r6, #'X'
	bleq	HEXA_MAI
	stmfd	sp!, {r4}
	add	r5, r5, #1
	mov	r3, r3, lsr #4
	cmp 	r3, #0
	beq	_trata_hex_short_out
	b	_trata_hex_short_loop 
_trata_hex_short_out:
	ldmfd	sp!, {r4}
	strb	r4, [r1], #1
	sub 	r5, r5, #1
	cmp 	r5, #0
	bne	_trata_hex_short_out
	ldmfd	sp!,  {R4-R11, pc}

	.data
auxbuffer:
	.skip 2000, 0
	
