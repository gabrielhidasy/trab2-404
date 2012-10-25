.global myprintf
.type myprintf, %function

	@myprintf recebe em r0 um buffer com uma string
	@que pode conter modificadores que por sua vez
	@requerem parametros a frente
	
myprintf:
	@empilha r1, r2 e r3 para uniformizar o uso do programa
	@(ler todos os parametros da pilha)
	stmfd sp!, {r3}
	stmfd sp!, {r2}
	stmfd sp!, {r1} 
	mov ip, sp
	@salvar registradores na pilha
	stmfd sp!, {r4-r11, lr}
	mov fp, ip
	mov r1, #0
	mov r2, #-1
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
	@em r1 o buffer de escrita, em r2 o num do argumento atual
	@(r2 tera permanentemente o atual) e em r3 o fp, de onde
	@os argumentos podem ser acessados como fp+numarg*4
	@se não, gravar
	beq _mask
	strb r10, [r4], #1
	add r6, r6, #1
	b _loop

_mask:
	add r2, r2, #1
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
	mov ip, #0
	strb ip, [r4], #1
	@calcula comprimento da string
	mov r0, r5
	bl comp
	@envia em r0 um buffer a imprimir e em
	@r1 o comprimento dele
	mov r1, r0
	mov r0, r5 
	bl syscallw
	@e sair de volta para main
	ldmfd sp!, {R4-R11, lr}
	@desempilhar os registradores usados
	ldmfd sp!, {R1-R3}
	mov pc, lr

comp:
	@recebe um buffer em r0 e retorna o comprimento em r0
	stmfd sp!, {r4-r11, lr}
	mov r4, #0
_comploop:
	ldrb r5, [r0], #1
	cmp r5, #0
	moveq r0, r4
	ldmeqfd sp!, {r4-r11, pc}
	add r4, r4, #1
	b _comploop

	
trata_mascaras:
	stmfd 	sp!, {R4-R12, lr}
	add 	fp, sp, #36
	mov 	r4, #4
	mul 	r4, r2, r4
	add 	r3, r3, r4
	@r3 tem o endereço de memoria do argumento 
	@carrega o proximo caracter depois da mascara em r4
	ldrb 	r4, [r0], #1
	cmp 	r4, #'c'
	bleq 	_trata_char
	cmp 	r4, #'d'
	bleq 	_trata_int
	cmp 	r4, #'s'
	bleq 	_trata_str
	cmp 	r4, #'x'
	bleq 	_trata_hex_short
	cmp 	r4, #'o'
	bleq 	_trata_oct_short
	cmp 	r4, #'l'
	bleq 	_trata_longs
	cmp	r4, #'u'
	bleq	_trata_uint
	@half trata como normal
	cmp 	r4, #'h'
	beq	trata_mascaras
	ldmfd 	sp!, {R4-R12, lr}
	mov 	pc, lr

_trata_char:
	ldr 	r3, [r3] 
	strb 	r3, [r1], #1
	mov 	pc, lr
	
_trata_str:
	ldr 	r3, [r3]
_tr_str_loop:	
	ldrb 	r4, [r3], #1
	cmp 	r4, #0
	moveq 	pc, lr
	strb 	r4, [r1], #1
	b 	_tr_str_loop

	
	
_trata_longs:
	stmfd 	sp!, {R4-R11,lr}
	@le que tipo de long tratar
	ldrb 	r4, [r0], #1
	cmp 	r4, #'x'
	bleq	 _trata_hex_short @nomes infelizes
	cmp 	r4, #'o'
	bleq	_trata_oct_short 
	cmp 	r4, #'u'
	bleq	_trata_uint
	cmp	r4, #'d'
	bleq	_trata_int
	cmp	r4, #'l'
	bleq	_trata_long_longs
	ldmfd 	sp!, {R4-R11, lr}
	mov 	pc, lr
	
_trata_long_longs:
	stmfd 	sp!, {R4-R11,lr}
	ldrb 	r4, [r0], #1
	cmp 	r4, #'x'
	bleq	 _trata_hex_long
	cmp 	r4, #'o'
	bleq	_trata_oct_long
	cmp 	r4, #'u'
	bleq	_pre_trata_luint
	cmp	r4, #'d'
	bleq	_trata_lint
	ldmfd 	sp!, {R4-R11, pc}
.data
buffer:
	.skip 2000, 0

	