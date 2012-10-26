.global	_trata_oct_long
.type _trata_oct_long, %function
.global	_trata_oct_short
.type 	_trats_oct_short, %function

_trata_oct_long:
	stmfd sp!, {R4-R11,lr}
	@save r1 and r0 in a safe place
	mov	r10, r1
	mov	r9, r0
	@r2 e r2+4 ou r2+4 e r2+8
	and 	r3, r2, #7
	cmp 	r3, #0
	addne	r2, #4
	@r2 tem o endereço do parametro
	ldr	r0, [r2], #4
	ldr	r1, [r2], #4
	@basta comparar com a mascara 7
	@somar 48, se maior que 7 erro
	@por na pilha e deslocar
	mov 	r5, #0
_trata_oct_long_loop:
	and 	r4, r0, #0x7
	add 	r4, r4, #48
	stmfd	sp!, {r4}
	add	r5, r5, #1
	bl	long3lsr
	cmp 	r1, #0
	cmpeq	r0, #0
	@get r1 and r0 back
	moveq	r1, r10
	moveq	r0, r9
	beq	_trata_oct_long_out
	b	_trata_oct_long_loop 
_trata_oct_long_out:
	ldmfd	sp!, {r4}
	strb	r4, [r1], #1
	sub 	r5, r5, #1
	cmp 	r5, #0
	bne	_trata_oct_long_out
	ldmfd	sp!,  {R4-R11, pc}

_trata_oct_short:
	stmfd sp!, {R4-R11,lr}
	@r2 tem o endereço do parametro
	ldr	r3, [r2], #4
	@basta comparar com a mascara 7
	@somar 48, se maior que 7 erro
	@por na pilha e deslocar
	mov 	r5, #0
_trata_oct_short_loop:
	and 	r4, r3, #0x7
	add 	r4, r4, #48
	cmp 	r4, #'7'
	stmfd	sp!, {r4}
	add	r5, r5, #1
	mov	r3, r3, lsr #3
	cmp 	r3, #0
	beq	_trata_oct_short_out
	b	_trata_oct_short_loop 
_trata_oct_short_out:
	ldmfd	sp!, {r4}
	strb	r4, [r1], #1
	sub 	r5, r5, #1
	cmp 	r5, #0
	bne	_trata_oct_short_out
	ldmfd	sp!,  {R4-R11, pc}

.data
auxbuffer:
	.skip 2000, 0
	