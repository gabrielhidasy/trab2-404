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

_trata_lint:
	@para resolver o long signed int, primeiro
	@ler o bit mais significativo do argumento mais
	@significativo
	stmfd 	sp!, {R4-R11, lr}
	ldr 	r4, [r3, #8]
	mov 	r4, r4, lsr #31
	@se o resultado é 0, basta imprimir
	@o numero normalmente
	cmp 	r4, #0
	bleq	_pre_trata_luint
	ldmeqfd sp!, {R4-R11, pc}
	@se voce chegou aqui, é porque
	@es um negativo, imprimir um -
	mov 	r4, #'-'
	strb	r4, [r1], #1
	@agora negai sua origem
	ldr 	r4, [r3, #8]
	ldr 	r5, [r3, #4]
	rsb	r4, r4, #0
	rsb   	r5, r5, #0
	sub 	r4, r4, #1
	@como é um numero de 64 bits só
	str 	r4, [r3, #8]
	str 	r5, [r3, #4]
	bl 	_pre_trata_luint
	ldmfd sp!, {R4-R11, pc}
	
_pre_trata_luint:
	@essa função da um buffer auxiliar para a de inteiros
	@e faz o padding da string, alem disso é responsavel
	@por resolver o problema de carry
	stmfd sp!, {r4-r11, lr}
	@guarda o buffer r1
	mov 	r4, r1
	ldr 	r1, =auxbufferints
	bl 	_trata_luint
	sub 	r1, r1, #1
	@agora ler do buffer de saida ao contrario, tem
	@do final dele até o inicio para fazer carry
_trata_carry:
	@carrega em r10 o buffer original de inteiros
	ldr 	r10, =auxbufferints
	@coloca em r10 o tamanho da string final
	sub	r7, r1, r10
	mov 	r8, #0
_loop_t_carry:
	cmp	r1, r10
	beq	_loop_int_final
	@le do buffer em r1 o valor do bit na string
	ldrb	r9, [r1]
	@soma nele o carry
	add	r9, r8, r9
	mov	r8, #0
	@compara o caracter atual com 9
	cmp 	r9, #'9'
	subgt	r9, r9, #10
	@seta carry (r8) para 1)
	movgt	r8, #1
	@grava r1
	strb 	r9, [r1], #-1
	@ve se chegou no inicio do buffer
	sub	r7, r7, #1
	b	_loop_t_carry 	
	@volta o buffer certo para a saida
	@agora como r1 tem o valor correto, gravar ele no buffer de saida
_loop_int_final:
	cmp 	r8, #1
	moveq	r8, #49
	addeq	r1, r1, #1
	streqb	r8, [r4], #1
	ldrb	r9, [r1], #1
	cmp	r9, #0
	moveq 	r1, r4
	ldmeqfd sp!, {r4-r11, pc}
	strb	r9, [r4], #1
	b	_loop_int_final
_trata_luint:
	stmfd sp!, {R4-R11, lr}
	mov r7, #0
	@Esse não tem divisão magica,
	@subtrações sucessivas
	@como todo long aumenta r2
	add	r2, r2, #1
	@e aumenta mais se no caso impar
	and 	r4, r2, #1
	cmp 	r2, #0
	addne 	r2, r2, #1
	@alem disso, nesse caso r3 é o proximo 
	addne 	r3, r3, #4
	@carrega argumento em r5:r4
	ldr 	r5, [r3, #4]
	ldr 	r4, [r3]
	@caso argumento mais significativo = 0, basta imprimir como uint
	cmp 	r5, #0
	bleq	_trata_uint
	ldmeqfd	sp!, {R4-R11, pc}
	@teste do digito mais significativo
	mov r11, r5, lsr #31
	and r11, r11, #1
	cmp r11, #0
	@elimina o bit mais significativo se for 0
	movne r5, r5, lsl #1
	movne r5, r5, lsr #1
	@agora precisamos somar na string de resposta uma string adicional
	@para isso colocamos em r7 uma flag, 0 se não é preciso e o endereço
	@do buffer adicional se preciso
	ldrne r7, =stringmagica
	@----------------------------------------
	stmfd sp!, {R2-R11}
	@para fazer os long ints, iremos primeiro colocar o maior numero
	@multiplo de 10 que cabe um um long nos registradores r1:r0 e o argumento
	@nos registradores r3:r2, tambem guardamos r1 e r0 em r11 e r10
	@em r6 e r7 estão guardadas as potencias do numero atual (10 e 9)
	@(são usadas para gerar o bigint)
	mov 	r11, r1
	mov 	r10, r0
	mov 	r3, r5
	mov 	r2, r4
	mov 	r6, #10
_long_int_loop:
	cmp 	r6, #0
	beq 	_long_int_end
	sub 	r6, r6, #1
	mov 	r8, #0
	@primeiro gerar o bigint
	mov 	r0, #1
	mov 	r1, r6
	bl 	pow10
	mov 	r4, r0
	mov 	r5, r0
	@Nesse ponto temos 10^r6 em r4 e 10^r6 em em r5
	@agora reduzir r6 ate um
	@quando for igual a 0 termina
	@gerar o bigint propriamento dito e guardar em r1:r0
	umull 	r0,r1,r4,r5
	@a potencia de 10 atual esta em r1:r0
	@longsub vai fazer a subtração e colocar o resultado
	@em r1:r0, ela não toca em r3:r2
_long_int_loop_act:	
	bl	longsub
	@se r1 for menor que 0, a potencia é grande demais
	@imprimir valor atual do acumulador (um int até 100),
	@avançar para proxima potencia
	@------------------
	@da pau aqui quando o numero é muito grande, porque a
	@comparação da menor que 0 sempre, para resolver, sempre
	@remover o primeiro bit do numero no unsingned e se era 1
	@somar a string resultante
	cmp 	r1, #0
	blt 	_long_int_loop_p
_long_int_loop_p_ret:	
	add 	r8, r8, #1
	mov 	r3, r1
	mov 	r2, r0
	umull	r0, r1, r4, r5
	b	_long_int_loop_act
_long_int_loop_p:
	mov 	r0, r8
	bl	magic
	add	r1, r1, #48
	add 	r0, r0, #48
	@se o primeiro digito era um, 7 tem um buffer a mais
	@para somar na string
	cmp r7, #0
	bne _long_int_loop_g
	@o mais significativo pode ser
	@até 10, nesse caso
	cmp 	r0, #58
	moveq 	r0, #49
	streqb	r0, [r11], #1
	moveq 	r0, #48
	streqb	r0, [r11], #1
	strneb	r0, [r11], #1
	strb 	r1, [r11], #1
	b 	_long_int_loop
_long_int_loop_g:
	stmfd 	sp!, {r10}
	@adicionar a r0 r r1 coisas da string em r7
	ldrb	r10, [r7], #1
	sub	r10, r10, #48
	add	r0, r0, r10
	ldrb 	r10, [r7], #1
	sub	r10, r10, #48
	add	r1, r1, r10
	@o mais significativo pode ser
	@até 10, nesse caso
	cmp 	r0, #58
	moveq 	r0, #49
	streqb	r0, [r11], #1
	moveq 	r0, #48
	streqb	r0, [r11], #1
	strneb	r0, [r11], #1
	strb 	r1, [r11], #1
	ldmfd 	sp!, {r10}
	b 	_long_int_loop
_long_int_end:
	mov 	r0, r10
	mov 	r1, r11
	ldmfd sp!, {R2-R11}
	
	@----------------------------------------
	ldmfd	sp!, {R4-R11, pc}
_trata_int:
	@se o primeiro bit é 0
	@simplesmente chamar a _trata_uint
	stmfd 	sp!, {R4-R11,lr}
	mov 	r4, #1
	mov	r4, r4, lsl #31
	ldr 	r5, [r3]
	and 	r4, r4, r5
	cmp 	r4, #0
	bleq 	_trata_uint
	ldmeqfd sp!, {R4-R11,pc}
	@se voce chegou aqui, é porque
	@es um negativo, imprimir um -
	mov 	r4, #'-'
	strb	r4, [r1], #1
	@agora negai sua origem
	rsb	r5, r5, #0
	@em r5 tem o inteiro negado
	str 	r5, [r3]
	bl	_trata_uint
	ldmfd	sp!, {R4-R11, pc}
	
_trata_uint:
	stmfd 	sp!, {R4-R11,lr}
	mov 	r11, r0
	mov 	r10, r1
	mov 	r5, #0
	ldr 	r0, [r3]
	@dividir por 10, jogar na pilha o modulo
_trata_uint_loop:	
	cmp 	r0, #0
	moveq 	r1, r10
	moveq 	r0, r11
	beq 	_trata_uint_end
	bl	 magic
	stmfd 	sp!, {r1}
	add 	r5, r5, #1
	b	_trata_uint_loop
_trata_uint_end:
	@pega da pilha, poe no buffer de saida
	cmp r5, #0
	ldmeqfd sp!, {R4-R11, pc}
	ldmfd 	sp!, {r9}
	@corrige o numero para asci
	add 	r9, r9, #48
	strb	r9, [r1], #1
	sub	 r5, r5, #1
	b 	_trata_uint_end
	
	
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
	
_trata_hex_long:
	stmfd sp!, {R4-R11,lr}
	@numeros longs tem 2 argumentos de 4 bytes, logo
	@alem do incremento padrão há mais um incremento
	@em r2
	add r2, r2, #1
	@O numero long é armazenado sempre
	@começando em um par, porem como o argumento
	@0 é o buffer de entrada, é preciso somar
	@1 quando r2 é par
	and 	r4, r2, #1
	cmp 	r2, #0
	addne 	r2, r2, #1
	@alem disso, nesse caso r3 é o proximo 
	addne 	r3, r3, #4
	@carrega o mais significativo e avança
	@Salva r3 antes
	mov 	r4, r3
	add 	r3, r3, #4
	@trata o long falso
	@--------------------------
	ldr 	r3, [r3]
	cmp 	r3, #0
	moveq 	r3, r4
	beq 	_trata_hex_short
	ldmeqfd sp!, {R4-R11, lr}
	@----------------------------
	mov 	r3, r4
	add 	r3, r3, #4
	bl 	_trata_hex_short
	mov 	r3, r4
	@usa um buffer auxiliar
	mov 	r10, r1
	ldr 	r1, =auxbuffer
	bl 	_trata_hex_short
	@no auxbuffer tem a parte menos significativa
	@copiar com padding 8 para a saida
	@carrega o valor original do buffer
	ldr r5, =auxbuffer
	@acha o tamanho do buffer
	sub r6, r1, r5
	@carrega o valor do padding em r5
	mov r5, #8
	@acha o valor do padding
	sub r5, r5, r6
	@e o numero de inteiros
	mov r7, #8
	sub r7, r7, r5
	@recupera o buffer de escrita original
	mov r1, r10
	mov r6, #'0'
_trata_hex_long_loop:
	cmp r5, #0
	strneb r6, [r1], #1
	subne r5, r5, #1
	bne _trata_hex_long_loop
	@grava o numero
	ldr 	r6, =auxbuffer
_trata_hex_long_loop2:
	ldrb 	r5, [r6], #1
	cmp 	r7, #0
	strneb 	r5, [r1], #1
	sub r7, r7, #1
	bne _trata_hex_long_loop2
	mov r3, r4
	@Zera o buffer auxiliar
	@preenche de zeros o buffer auxbuffer
	@pelo numero de bytes usados
	mov r7, #8
	mov r8, #0
	ldr r6, =auxbuffer
_loop_hex_long_zerar:	
	strneb	r8, [r6], #1
	sub r7, r7, #1
	cmp r7, #0
	bne _loop_hex_long_zerar
	ldmfd sp!, {R4-R11, lr}
	mov pc, lr
	
_trata_hex_short:
	stmfd sp!, {R4-R11,lr}
	@r11 é o contador de digitos colocados
	@no buffer, será usado para padding
	mov r11, #0
	ldr r3, [r3]
	mov r5, #0xF0000000
	mov r6, #28
_inner_trthxs_loop:
	cmp r6, #0
	strltb r4, [r1], #1
	ldmltfd sp!, {R4-R11, pc}
	and r4, r3, r5
	cmp r4, #0
	moveq r5, r5, lsr #4
	subeq r6, r6, #4
	beq _inner_trthxs_loop
	@em r3 está o valor do hexa a imprimir
_tr_hx_sh_loop:
	cmp r6, #0
	ldmltfd sp!, {R4-R11, pc}
	and r4, r3, r5
	mov r5, r5, lsr #4
	mov r4, r4, lsr r6
	sub r6, r6, #4
	bl _hextochar
	strb r4, [r1], #1
	add r11, r11, #1
	b _tr_hx_sh_loop
_hextochar:
	add r4, r4, #48
	cmp r4, #57
	addgt r4, r4, #39
	mov pc, lr
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
	bl	_octtochar
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
	bl 	_octtochar
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
	ldr r3, [r3]
	@pré tratamento dos primeiros 2 bits da sequencia
	mov r5, #0xC0000000
	mov r6, #30
	and r4, r3, r5
	mov r4, r3, lsr #30
	cmp r4, #0
	blne _octtochar 
	strneb r4, [r1], #1
	movne r5, #0x38000000
	movne r6, #27
	bne _tr_oc_sh_loop
	@Acha o char deles e se diferente de 0 poe no buffer
	mov r5, #0x38000000
	mov r6, #27
_inner_trtocs_loop:
	cmp r6, #0
	strltb r4, [r1], #1
	ldmltfd sp!, {R4-R11, pc}
	and r4, r3, r5
	cmp r4, #0
	moveq r5, r5, lsr #3
	subeq r6, r6, #3
	beq _inner_trtocs_loop
	@em r3 está o valor do hexa a imprimir
_tr_oc_sh_loop:
	cmp r6, #0
	ldmltfd sp!, {R4-R11, pc}
	and r4, r3, r5
	mov r5, r5, lsr #3
	mov r4, r4, lsr r6
	sub r6, r6, #3
	bl _octtochar
	strb r4, [r1], #1
	b _tr_oc_sh_loop

_octtochar:
	add r4, r4, #48
	mov pc, lr
.data
buffer:
	.skip 2000, 0

auxbuffer:
	.skip 2000, 0
auxbufferints:
	.skip 2000, 0
.align 1
stringmagica:
	.asciz "09223372036854775808"

	