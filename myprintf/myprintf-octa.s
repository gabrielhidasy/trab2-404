.global	_trata_oct_long
.type _trata_oct_long, %function
.global	_trata_oct_short
.type 	_trats_oct_short, %function
	
_trata_oct_long:	
	@Para imprimir o octal long, primeiro
	@imprimir o mais significativo, porem
	@começando com a mascara '1 lsl 31'
	stmfd sp!, {R4 - R11, lr}
	@numeros longs, gastam 2 argumentos
	add 	r2, r2, #1
	and 	r4, r2, #1
	cmp 	r2, #0
	addne 	r2, r2, #1
	@avança para o argumento correto
	addne	r3, r3, #4
	@salva argumento original
	mov 	r4, r3
	mov 	r9, r3
	add 	r4, r4, #4
	@acha primeiro caracter
	ldr 	r4, [r4]
	mov 	r5, #1
	mov 	r5, r5, lsl #31
	and 	r4, r4, r5
	mov 	r4, r4, lsr #31
	cmp 	r4, #0
	@r4 pode ser 0 ou 1
	@pode ser impresso 1 se for
	@1 ou ignorar se 0
	strneb 	r4, [r1], #1
	@mascara para os longs
	mov 	r5, #0x7
	mov 	r5, r5, lsl #28
	@recarregar o numero
	mov 	r4, r3
	@na parte mais significativa
	add 	r3, r3, #4
	@----------------------------
	@grava parte mais significativa no buffer
	ldr 	r3, [r3]
	cmp	r3, #0
	moveq 	r3, r4
	beq	_trata_oct_short
	ldmeqfd sp!, {R4-R11,lr}
	@numero de deslocamentos da resposta do and
	mov 	r6,  #28
	
_trata_oct_long_loop_zeros_da_frente:
	@trata o long com parte mais
	@significativa = 0
	cmp 	r6, #0
	strltb 	r4, [r1], #1
	ldmltfd sp!, {R4-R11, pc}
	and 	r4, r3, r5
	cmp	r4, #0
	moveq 	r5, r5, lsr #3
	subeq 	r6, r6, #3
	beq	_trata_oct_long_loop_zeros_da_frente
_trata_oct_long_loop:
	cmp 	r6, #1
	blt	_finaliza_loop
	and	r4, r3, r5
	mov 	r5, r5, lsr #3
	mov	r4, r4, lsr r6
	sub 	r6, r6, #3
	add	r4, r4, #48
	strb	r4, [r1], #1
	add	r11, r11, #1
	b	_trata_oct_long_loop
	@o ultimo digito faz um bitshift << 2 e
	@recebe os 2 mais significativos do outro
_finaliza_loop:	
	and 	r4, r3, #1
	mov 	r4, r4, lsl #2
	@carrega em r10 a parte mais sig da menos significativa
	ldr 	r10, [r9]
	mov 	r10, r10, lsr #30
	and 	r10, r10, #3
	add 	r4, r4, r10
	add	r4, r4, #48
	strb	r4, [r1], #1
	@--------------------------------
	@carrega a parte menos significativa do numero
	ldr 	r3, [r9]
	@elimina os 2 primeiros bits
	mov 	r3, r3, lsl #2
	mov 	r3, r3, lsr #2
	@regrava o numero
	str	r3, [r9]
	mov 	r3, r9
	@grava buffer de saida padrão
	mov 	r10, r1
	@carrega buffer auxiliar
	ldr 	r1, =auxbuffer
	bl 	_trata_oct_short
	@acha tamanho do buffer de octal
	ldr 	r6, =auxbuffer
	sub 	r6, r1, r6
	@calcula padding
	mov 	r7, #10
	sub 	r6, r7, r6
	sub	r7, r7, r6
	@grava padding
	mov	r1, r10
	ldr 	r10, =auxbuffer
	mov 	r9, #'0'
	mov 	r5, #10
	mov 	r4, #0
_grava_padding_octa:
	cmp 	r6, #0
	ldreq	r6, =auxbuffer
	beq 	_trata_oct_long_end
	strb	r9, [r1], #1
	sub 	r6, r6, #1
	b	_grava_padding_octa
_trata_oct_long_end:
	cmp 	r7, #0
	beq 	_zera_buffer_octa
	sub 	r7, r7, #1
	ldrb	r8, [r6], #1
	strb	r8, [r1], #1
	b	_trata_oct_long_end
_zera_buffer_octa:
	cmp 	r5, #0
	ldmeqfd	sp!, {R4-R11, pc}
	strb	r4, [r10], #1
	sub	r5, r5, #1
	b	_zera_buffer_octa 
	
_trata_oct_short:
	stmfd sp!, {R4-R11,lr}
	@r3 tem o endereço do parametro
	ldr	r3, [r3]
	@basta comparar com a mascara 7
	@somar 48, se maior que 7 erro
	@por na pilha e deslocar
	mov 	r5, #0
_trata_oct_short_loop:
	and 	r4, r3, #0x7
	add 	r4, r4, #48
	cmp 	r4, #'7'
	bgt	myprintf_error
	cmp	r4, #'0'
	blt	myprintf_error
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
	