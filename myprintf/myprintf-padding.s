.global trata_paddin_const
.type 	trata_paddin_cons, %function
.global	trata_padding_0
.type	trata_padding_0, %function
.global trata_padding_p
.type	trata_padding_p, %function
.global trata_padding_m
.type  trata_padding_m, %function
.global trata_padding_const
.type  trata_padding_const, %function
trata_padding_const:
	mov	r8, #' '
	@quando se recebe uma constante, é preciso ler
	@o valor da constante
	@para isso ler ele em um buffer auxiliar,
	@assumindo que ele é um inteiro de base 10
	stmfd	sp!, {R4-R11, lr}
	mov	r6, #0
	mov	r7, #10
	@volta r0 para o parametro correto
	sub	r0, r0, #1
	@-----------------------------------------
	@le o numero a frente
le_width_pad_const: @le a width	
	ldrb 	r5, [r0], #1
	@assumindo que tem que ser um numero
	sub 	r5, r5, #48
	@assim ele cai no espaço de 0 a 9
	cmp	r5, #9
	bgt	_continua_padding_const
	cmp	r5, #0
	blt	_continua_padding_const
	@multiplicar o contador por 10
	mul	r6, r7, r6
	@somar o numero no contador
	add	r6, r6, r5
	b 	le_width_pad_const
_continua_padding_const:	
	@nesse ponto tem o valor da width em r6 e
	@o tipo a tratar é o proximo caracter de r0
	@gravar em r1 um buffer auxiliar
	mov	r10, r1
	ldr	r1, =buffer_aux_padding_const
	@volta a entrada para o caracter a ser impresso
	@e trata proxima mascara
	sub 	r0, r0, #1
	bl	trata_mascaras
	@no retorno, em r1 tem o buffer auxiliar já com o numero
	ldr	r4, =buffer_aux_padding_const
	sub	r5, r1, r4
	@em r5 temos o tamanho do buffer armazenado em r1
	sub	r5, r6, r5
	@agora temos em r5 o numero de ' 's a imprimir na string de
	@saida
	mov	r1, r10
	@nesse ponto, imprimir o valor
	mov	r9, #0
imprime_numero_padding_const:
	ldrb 	r6, [r4]
	strb	r9, [r4], #1
	cmp	r6, #0
	strneb	r6, [r1], #1
	bne	imprime_numero_padding_const
imprime_espacos_padding_const:
	cmp	r5, #0
	ldmeqfd	sp!, {R4-R11, pc}
	strb	r8, [r1], #1
	sub	r5, r5, #1
	b 	imprime_espacos_padding_const
	
trata_padding_0:
	@quando se recebe o 0, é preciso ler
	@o valor de largura a frente
	@para isso ler ele em um buffer auxiliar,
	@assumindo que ele é um inteiro de base 10
	stmfd	sp!, {R4-R11, lr}
	mov	r8, #'0'
	mov	r6, #0
	mov	r7, #10
	@-----------------------------------------
	@le o numero a frente
le_width_pad_0:
	ldrb 	r5, [r0], #1
	@assumindo que tem que ser um numero
	sub 	r5, r5, #48
	@assim ele cai no espaço de 0 a 9
	cmp	r5, #9
	bgt	_continua_padding_0
	cmp	r5, #0
	blt	_continua_padding_0
	@multiplicar o contador por 10
	mul	r6, r7, r6
	@somar o numero no contador
	add	r6, r6, r5
	b 	le_width_pad_0
_continua_padding_0:
	@nesse ponto tem o valor da width em r6 e
	@o tipo a tratar é o proximo caracter de r0
	@gravar em r1 um buffer auxiliar
	mov	r10, r1
	ldr	r1, =buffer_aux_padding_0
	@volta a entrada para o caracter a ser impresso
	@e trata proxima mascara
	sub 	r0, r0, #1
	bl	trata_mascaras
	@no retorno, em r1 tem o buffer auxiliar já com o numero
	ldr	r4, =buffer_aux_padding_0
	sub	r5, r1, r4
	@em r5 temos o tamanho do buffer armazenado em r1
	sub	r5, r6, r5
	@agora temos em r5 o numero de '0s' a imprimir na string de
	@saida
	mov	r1, r10
	@ver se existe um - na frente do numero
	ldrb	r9, [r4]
	@caso seja um -, imprimir um -
	cmp	r9, #'-'
	streqb	r9, [r1], #1
	@e remover um zero do loop
	sub	r5, r5, #1
_loop_padding0_zeros:
	cmp	r5, #0
	movle	r9, #0
	ble	_padding0_end
	strb	r8, [r1], #1
	sub	r5, r5, #1
	b _loop_padding0_zeros
_padding0_end:
	@agora grava o numero que começa em r4
	@e termina quando vier um caracter 0
	ldrb	r5, [r4]
	@limṕe o buffer que vc usou
	strb 	r9, [r4], #1
	cmp	r5, #0
	ldmeqfd sp!, {R4-R11, pc}
	cmp	r5, #'-'
	moveq	r5, #'0'
	strb	r5, [r1], #1
	b	_padding0_end



@--------------------------------------------------------
trata_padding_m:
	@quando se recebe o 0, é preciso ler
	@o valor de largura a frente
	@para isso ler ele em um buffer auxiliar,
	@assumindo que ele é um inteiro de base 10
	stmfd	sp!, {R4-R11, lr}
	mov	r8, #' '
	mov	r6, #0
	mov	r7, #10
	@-----------------------------------------
	@le o numero a frente
le_width_pad_m:
	ldrb 	r5, [r0], #1
	@assumindo que tem que ser um numero
	sub 	r5, r5, #48
	@assim ele cai no espaço de 0 a 9
	cmp	r5, #9
	bgt	_continua_padding_m
	cmp	r5, #0
	blt	_continua_padding_m
	@multiplicar o contador por 10
	mul	r6, r7, r6
	@somar o numero no contador
	add	r6, r6, r5
	b 	le_width_pad_m
_continua_padding_m:
	@nesse ponto tem o valor da width em r6 e
	@o tipo a tratar é o proximo caracter de r0
	@gravar em r1 um buffer auxiliar
	mov	r10, r1
	ldr	r1, =buffer_aux_padding_m
	@volta a entrada para o caracter a ser impresso
	@e trata proxima mascara
	sub 	r0, r0, #1
	bl	trata_mascaras
	@no retorno, em r1 tem o buffer auxiliar já com o numero
	ldr	r4, =buffer_aux_padding_m
	sub	r5, r1, r4
	@em r5 temos o tamanho do buffer armazenado em r1
	sub	r5, r6, r5
	@agora temos em r5 o numero de ' 's a imprimir na string de
	@saida
	mov	r1, r10
_loop_paddingm_esp:	
	cmp	r5, #0
	movle	r9, #0
	ble	_paddingm_end
	strb	r8, [r1], #1
	sub	r5, r5, #1
	b _loop_paddingm_esp
_paddingm_end:
	@agora grava o numero que começa em r4
	@e termina quando vier um caracter 0
	ldrb	r5, [r4]
	@limpe o buffer que vc usou
	strb 	r9, [r4], #1
	cmp	r5, #0
	ldmeqfd sp!, {R4-R11, pc}
	strb	r5, [r1], #1
	b	_paddingm_end
		
trata_padding_p:
	stmfd	sp!, {R4 - R11, lr}
	@padding de +, se o numero é negativo otimo
	@se é positivo imprimo um + antes dele
	@usar um buffer auxiliar
	@tratar o proximo ponto
	mov	r10, r1
	ldr	r1, =buffer_aux_padding_p
	bl 	trata_mascaras
	@ler em r4 o começo do buffer auxiliar
	ldr 	r4, =buffer_aux_padding_p
	@agora recuperar o buffer r1
	mov	r1, r10
	mov 	r7, #1
	@se o primeiro caracter for um numero, imprimir
	@o ' ' logo de uma vez
	ldrb	r5, [r4]
	sub	r5, r5, #48
	cmp 	r5, #'9'
	blle	_sem_criatividade1
	@e zerar r7
	mov	r9, #0
trata_padding_p_loop:
	@ler um caracter de r4
	ldrb	r5, [r4], #1
	strb	r9, [r4, #-1]
	cmp	r5, #0
	ldmeqfd	sp!, {R4-R11, pc}
	cmp	r5, #'-'
	moveq	r7, #0
	@se for um '-', o r7 vira 0
	@se for um numero e r7 for 1
	@então gravar um + no anterior
	cmp	r7, #1
	bleq	_sem_criatividade0
	strb	r5, [r1], #1
	b 	trata_padding_p_loop
_sem_criatividade0:
	cmp	r5, #' '
	movne	r7, #'+'
	strneb	r7, [r1, #-1]
	movne	r7, #0
	mov	pc, lr
_sem_criatividade1:
	cmp	r5, #0
	movge	ip, #' '
	strgeb	ip, [r1], #1
	cmp	r5, #0
	addeq	r4, r4, #1
	mov	pc, lr
.data
.align 1
buffer_aux_padding_0:
	.skip	100, 0
buffer_aux_padding_p:
	.skip	100, 0
buffer_aux_padding_m:
	.skip	100, 0
buffer_aux_padding_const:
	.word 0x0
	