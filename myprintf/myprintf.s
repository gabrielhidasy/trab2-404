.global myprintf
.type	myprintf, %function
.global	myprintf_error
.type 	myprintf_error, %function
	@myprintf recebe em r0 um buffer com uma string
	@que pode conter modificadores que por sua vez
	@requerem parametros a frente
	
myprintf:
	@empilha r1, r2 e r3 para uniformizar o uso do programa
	@(ler todos os parametros da pilha)
	ldr	ip, =lr_point
	str	lr, [ip]
	stmfd sp!, {r3}
	stmfd sp!, {r2}
	stmfd sp!, {r1} 
	mov ip, sp
	@salvar registradores na pilha
	stmfd sp!, {r4-r11, lr}
	mov 	fp, ip
	@grava o valor inicial da pilha na  memoria
	ldr	r2, =stack_init
	str	sp, [r2]
	mov 	r1, #0
	@em r2 fica o endereço do parametro atual
	mov 	r2, sp
	add	r2, r2, #36
	@(9 regs) 
	mov r3, #0
	@guarda no fp o valor original da pilha
	@em r4 guardo o endereço do buffer em uso, r5 o inicio dele
	ldr r4, =buffer
	mov r5, r4
	@em r6 guardo o numero de caracteres atual da string
	mov r6, #0
	@muda o buffer de entrada para r9
	mov r9, r0

_loop:
	@em r10 o caracter auxiliar
	ldrb r10, [r9], #1
	@se for igual ao fim da string
	cmp r10, #0
	@ir para o final - imprimir o buffer
	beq _end
	@se for uma mascara, ir para
	@tratador de mascaras
	cmp r10, #'%'
	@O tratador de mascaras recebe em r0 o buffer de leitura
	@se não, gravar
	beq _mask
	strb r10, [r4], #1
	add r6, r6, #1
	b _loop

_mask:
	@add r2, r2, #1
	stmfd sp!, {r0}
	mov r0, r9
	mov r1, r4
	mov r3, fp
	bl trata_mascaras
	mov r9, r0
	mov r4, r1
	ldmfd sp!, {r0}
	b _loop
_end:
	@coloca um caracter de finalização
	@no buffer de escrita
	@mov ip, #0
	@strb ip, [r4], #1
	@calcula comprimento da string
	ldr	r0, =buffer
	sub	r1, r4, r0
	@envia em r0 um buffer a imprimir e em
	@r1 o comprimento dele
	@mov r1, r5 
	bl syscallw
	mov	r1, r0
	@ldr	sp, =stack_init
	@ldr	sp, [sp]
	@ldmfd sp!, {R4-R11, lr}
	ldmfd sp!, {R4- R11,lr}
	@desempilhar os registradores usados
	ldmfd	sp!, {R3}
	ldmfd	sp!, {R2}
	ldmfd	sp!, {R1}
	@bugs demais aqui, a pilha parece
	@certa mas sempre da erro, desisto por hj
	ldr	lr, =lr_point
	ldr	pc, [lr]
	mov pc, lr

trata_mascaras:
	stmfd 	sp!, {R4-R12, lr}
	add 	fp, sp, #36
	@@mov 	r4, #4
	@@mul 	r4, r2, r4
	@@add 	r3, r3, r4
	@@r3 tem o endereço de memoria do argumento
	@r2 tem o endereço de memoria do argumento
	@carrega o proximo caracter depois da mascara em r4
	ldrb 	r4, [r0], #1
	stmfd	sp!, {r4}
	cmp 	r4, #'c'
	@bleq 	_trata_char
	ldmfd sp, {r4}
	cmp	r4, #'c'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp 	r4, #'d'
	bleq 	_trata_int
	ldmfd sp, {r4}
	cmp	r4, #'d'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp 	r4, #'s'
	@bleq 	_trata_str
	ldmfd sp, {r4}
	cmp	r4, #'s'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp 	r4, #'x'
	bleq 	_trata_hex_short
	ldmfd sp, {r4}
	cmp	r4, #'x'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp 	r4, #'o'
	bleq 	_trata_oct_short
	ldmfd sp, {r4}
	cmp	r4, #'o'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp 	r4, #'l'
	bleq 	_trata_longs
	ldmfd sp, {r4}
	cmp	r4, #'l'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp	r4, #'u'
	bleq	_trata_uint
	ldmfd sp, {r4}
	cmp	r4, #'u'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	
	@half trata como normal
	cmp 	r4, #'h'
	bleq	trata_mascaras
	ldmfd sp, {r4}
	cmp	r4, #'h'	
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	@flag de padding 0
	cmp 	r4, #'0'
	bleq	trata_padding_0
	ldmfd 	sp, {r4}
	cmp	r4, #'0'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	@flag de padding +
	cmp 	r4, #'+'
	bleq	trata_padding_p
	ldmfd 	sp, {r4}
	cmp	r4, #'+'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	@flag de padding -
	cmp 	r4, #'-'
	bleq	trata_padding_m
	ldmfd 	sp, {r4}
	cmp	r4, #'-'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	@se não for nada disso é a constante maior que 0
	@e o comportamento é como o do -, mas com os esp
	@do outro lado
	bleq	trata_padding_const
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	mov 	pc, lr
	
trata_padding_const:
	mov	r8, #' '
	@quando se recebe uma constante, é preciso ler
	@o valor da constante
	@para isso ler ele em um buffer auxiliar,
	@assumindo que ele é um inteiro de base 10
	stmfd	sp!, {R4-R11, lr}
	mov	r6, #0
	mov	r7, #10
	@-----------------------------------------
	@le o numero a frente
le_width_pad_const:	
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
	@ver se existe um - na frente do numero
	ldrb	r9, [r4]
	@caso seja um -, imprimir um -
	cmp	r9, #'-'
	streqb	r9, [r1], #1
	@nesse ponto, imprimir o valor
imprime_numero_padding_const:
	
trata_padding_0:
	mov	r8, #'0'
	@quando se recebe o 0, é preciso ler
	@o valor de largura a frente
	@para isso ler ele em um buffer auxiliar,
	@assumindo que ele é um inteiro de base 10
	stmfd	sp!, {R4-R11, lr}
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
_loop_padding0_zeros:
	cmp	r5, #0
	ble	_padding0_end
	strb	r8, [r1], #1
	sub	r5, r5, #1
	b _loop_padding0_zeros
_padding0_end:
	@agora grava o numero que começa em r4
	@e termina quando vier um caracter 0
	ldrb	r5, [r4], #1
	cmp	r5, #0
	ldmeqfd sp!, {R4-R11, pc}
	cmp	r5, #'-'
	moveq	r5, #'0'
	strb	r5, [r1], #1
	b	_padding0_end
	
trata_padding_m:
	@é exatamente igual ao padding com 0, mas com ' '
	@em r8 fica gravado o que colocar no padding
	stmfd	sp!, {R4-R11, lr}
	mov	r6, #0
	mov	r7, #10
	mov	r8, #' '
	b	le_width_pad_0		
trata_padding_p:
	stmfd	sp!, {R4 - R11, lr}
	@padding de +, se o numero é negativo otimo
	@se é positivo imprimo um +
	@usar um buffer auxiliar
	mov	r10, r1
	ldr	r1, =buffer_aux_padding_p
	@tratar o proximo ponto
	bl 	trata_mascaras
	@ler em r4 o começo do buffer auxiliar
	ldr 	r4, =buffer_aux_padding_p
	@agora recuperar o buffer r1
	mov	r1, r10
	@ler em r5 o primeiro caracter
	ldrb 	r5, [r4]
	cmp	r5, #'-'
	movne	r5, #'+'
	strneb	r5, [r1], #1
	@agora copiar o buffer auxiliar para a saida
_trata_padding_p_loop:
	ldrb	r10, [r4], #1
	cmp	r10, #0
	beq	_tmpout
	strb	r10, [r1], #1
	b	_trata_padding_p_loop
_tmpout:
	ldmfd	sp!, {R4 - R11, pc}
_trata_longs:
	stmfd 	sp!, {R4-R12,lr}
	@le que tipo de long tratar
	ldrb 	r4, [r0], #1
	stmfd	sp!, {r4}	
	cmp 	r4, #'x'
	bleq	 _trata_hex_short @nomes infelizes
	ldmfd sp, {r4}
	cmp 	r4, #'x'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp 	r4, #'o'
	bleq	_trata_oct_short
	ldmfd sp, {r4}
	cmp 	r4, #'o'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp 	r4, #'u'
	bleq	_trata_uint
	ldmfd sp, {r4}
	cmp 	r4, #'u'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp	r4, #'d'
	bleq	_trata_int
	ldmfd sp, {r4}
	cmp 	r4, #'d'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp	r4, #'l'
	bleq	_trata_long_longs
	ldmfd sp, {r4}
	cmp 	r4, #'l'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	b 	myprintf_error	

_trata_long_longs:
	stmfd 	sp!, {R4-R12,lr}
	ldrb 	r4, [r0], #1
	stmfd	sp!, {r4}
	
	cmp 	r4, #'x'
	bleq	 _trata_hex_long
	ldmfd sp, {r4}
	cmp	r4, #'x'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	
	cmp 	r4, #'o'
	bleq	_trata_oct_long
	ldmfd sp, {r4}
	cmp	r4, #'o'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp 	r4, #'u'
	bleq	_pre_trata_luint
	ldmfd sp, {r4}
	cmp	r4, #'u'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp	r4, #'d'
	bleq	_trata_lint
	ldmfd sp, {r4}
	cmp	r4, #'d'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	b	myprintf_error
	
myprintf_error:
	@limpa pilha
	ldr	sp, =stack_init
	ldr	sp, [sp]
	ldmfd sp!, {R4-R11, lr}
	@desempilhar os registradores usados
	ldmfd sp!, {R1-R3}
	mov	r0, #-1
	mov pc, lr

.data
buffer:
	.skip 2000,0
.align 4
stack_init:
	.word 0x0
buffer_aux_padding_0:
	.skip	100, 0
buffer_aux_padding_p:
	.skip	100, 0
lr_point:
	.word 0x0
