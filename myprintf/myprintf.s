.global myprintf
.type	myprintf, %function
.global	myprintf_error
.type 	myprintf_error, %function
.global trata_mascaras
.type 	trata_mascaras, %function
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
	bleq 	_trata_char
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

	cmp 	r4, #'i'
	bleq 	_trata_int
	ldmfd sp, {r4}
	cmp	r4, #'i'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	
	cmp 	r4, #'s'
	bleq 	_trata_str
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

	cmp 	r4, #'X'
	bleq 	_trata_hex_short
	ldmfd 	sp, {r4}
	cmp	r4, #'X'
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

	cmp 	r4, #'h'
	@beq 	trata_mascaras
	bleq	_trata_h
	ldmfd 	sp, {R4}
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
	bl	trata_padding_const
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	mov 	pc, lr
	
_trata_hd:
	ldr	r4, [r2]
	and	r5, r4, #0x8000
	cmp	r5, #0
	rsbne	r4, r4, #0
	str	r4, [r2]
	bl 	_trata_int
	ldmfd	sp!, {r4}
	ldmfd sp!, {R4-R12, pc}
_trata_h:
	stmfd	sp!, {R4-R12, lr}
	@le o tipo de halfword
	ldrb	r4, [r0], #1
	stmfd	sp!, {r4}
	
	cmp	r4, #'d'
	@se o bit n 15 for 1, rsb
	@o parametro bem em R2
	beq 	_trata_hd

	cmp	r4, #'u'
	bleq 	_trata_int
	ldmfd	sp, {r4}
	cmp	r4, #'u'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp	r4, #'x'
	bleq	_trata_hex_short
	ldmfd	sp, {r4}
	cmp	r4, #'x'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp	r4, #'X'
	bleq	_trata_hex_short
	ldmfd	sp, {r4}
	cmp	r4, #'X'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp	r4, #'o'
	bleq	_trata_oct_short
	ldmfd	sp, {r4}
	cmp	r4, #'o'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	
_trata_hh:
	ldrb	r4, [r0, #2]
	cmp	r4, #'d'
	add	r0, r0, #1
	ldreqsb	r5, [r2]
	streqb	r5, [r2]
	b	trata_mascaras
	
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

	cmp 	r4, #'X'
	bleq	 _trata_hex_short @nomes infelizes
	ldmfd sp, {r4}
	cmp 	r4, #'X'
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

	cmp	r4, #'i'
	bleq	_trata_int
	ldmfd sp, {r4}
	cmp 	r4, #'i'
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

	cmp 	r4, #'X'
	bleq	 _trata_hex_long
	ldmfd sp, {r4}
	cmp	r4, #'X'
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
	ldmfd 	sp, {r4}
	cmp	r4, #'d'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}

	cmp	r4, #'i'
	bleq	_trata_lint
	ldmfd 	sp, {r4}
	cmp	r4, #'i'
	ldmeqfd	sp!, {r4}
	ldmeqfd sp!, {R4-R12, pc}
	b	myprintf_error
	
	
myprintf_error:
	@limpa pilha
	ldr	sp, =stack_init
	ldr	sp, [sp]
	ldmfd 	sp!, {R4-R11, lr}
	@desempilhar os registradores usados
	ldmfd 	sp!, {R1-R3}
	mov	r0, #-1
	ldr	lr, =lr_point
	ldr	pc, [lr]

.data
buffer:
	.skip 2000,0
.align 4
stack_init:
	.word 0x0
lr_point:
	.word 0x0
