.global _trata_int
.type _trata_int, %function
.global _trata_lint
.type _trata_lint, %function
.global _trata_uint
.type _trata_uint, %function
.global _pre_trata_luint
.type _pre_trata_luint, %function
trata_d0:
	ldr	r4, [r2, #4]
	cmp	r4, #0
	moveq	r4, #'0'
	streqb	r4, [r1], #1
	ldmeqfd sp!, {r4-r11, pc}
	mov	pc, lr
_trata_lint:
	@para resolver o long signed int, primeiro
	@ler o bit mais significativo do argumento mais
	@significativo
	stmfd 	sp!, {R4-R11, lr}
	@o problema do r2
	and 	r4, r2, #7
	cmp	r4, #0
	addne	r2, r2, #4
	ldr	r4, [r2]
	cmp	r4, #0
	bleq	trata_d0
	ldr 	r4, [r2, #4]
	mov 	r4, r4, lsr #31
	@se o resultado é 0, basta imprimir
	@o numero normalmente
	cmp 	r4, #0
	bleq	_padding_trata_lint
	ldmeqfd sp!, {R4-R11, pc}
	@se voce chegou aqui, é porque
	@es um negativo, imprimir um -
	mov 	r4, #'-'
	strb	r4, [r1], #1
	@agora negai sua origem
	ldr 	r5, [r2, #4]
	ldr 	r4, [r2]
	rsb	r4, r4, #0
	rsb   	r5, r5, #0
	sub 	r5, r5, #1
	@como é um numero de 64 bits só
	str 	r5, [r2, #4]
	str 	r4, [r2]
	bl 	_padding_trata_lint
	ldmfd sp!, {R4-R11, pc}

_padding_trata_lint:
	stmfd	sp!, {r4 - r11, lr}
	bl _pre_trata_luint
	sub 	r4, r1, #20
	mov	r6, #0
_padding_int_loop:
	@esse loop conta quantos zeros tem antes do numero
	ldrb	r5, [r4]
	cmp 	r5, #'0'
	addeq	r6, r6, #1
	addeq	r4, r4, #1
	beq	_padding_int_loop
	@volta r1
	sub	r1, r1, #20
	@coloca o numero de 1's em r6
	rsb	r6, r6, #20
_copy_int_to_exit:
	@esse loop tira os zeros
	ldrb	r5, [r4], #1
	strb	r5, [r1], #1
	sub	r6, r6, #1
	cmp	r6, #0
	bne	_copy_int_to_exit
	@moveq	r1, r4
	ldmeqfd	sp!, {r4 - r11, pc}

	
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
	@coloca em r7 o tamanho da string final
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
	@cmp	r7, #0
	@bleq	primeironumero
	b	_loop_t_carry 	
	@volta o buffer certo para a saida
_loop_int_final:
	cmp 	r8, #1
	moveq	r8, #49
	addeq	r1, r1, #1
	streqb	r8, [r4], #1
	moveq	r8, #3
	movne	r8, #2
	@cmp	r8, #0
	@subeq	r4, r4, #1
	@moveq	r8, #49
	ldrb	r9, [r1], #1
	cmp	r9, #0
	moveq 	r1, r4
	ldmeqfd sp!, {r4-r11, pc}
	cmp	r9, #'0'
	@remove os zeros da frente dos llu
	bleq	primeironumero
	strneb	r9, [r4], #1
	b	_loop_int_final
primeironumero:
	cmp	r8, #3
	streqb	r9, [r4], #1
	@retorna a flag ao eq que entrou
	cmp	r8, r8
	mov	pc, lr

_trata_luint:
	stmfd sp!, {R4-R11, lr}
	mov r7, #0
	@Esse não tem divisão magica,
	@subtrações sucessivas
	and	r4, r2, #8
	cmp	r4, #0
	addeq	r2, #4
	@carrega argumento em r5:r4
	ldr 	r5, [r2, #4]
	ldr 	r4, [r2]
	@caso argumento mais significativo = 0, 
	@basta imprimir como uint
	@cmp 	r5, #0
	@bleq	_trata_uint
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
	@-----------------------------------------
	

@32 bits ahead
_trata_int:
	@se o primeiro bit é 0
	@simplesmente chamar a _trata_uint
	stmfd 	sp!, {R4-R11,lr}
	mov 	r4, #1
	mov	r4, r4, lsl #31
	ldr 	r5, [r2]
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
	@sub	r2, r2, #4
	str 	r5, [r2]
	bl	_trata_uint
	ldmfd	sp!, {R4-R11, pc}
	
_trata_uint:
	stmfd 	sp!, {R4-R11,lr}
	mov 	r11, r0
	mov 	r10, r1
	mov 	r5, #0
	ldr 	r0, [r2], #4
	@dividir por 10, jogar na pilha o modulo
_trata_uint_loop:	
	cmp 	r0, #0
	moveq 	r1, r10
	moveq 	r0, r11
	beq 	_trata_uint_end_p
	bl	 magic
	stmfd 	sp!, {r1}
	add 	r5, r5, #1
	b	_trata_uint_loop
_trata_uint_end_p:
	cmp	r5, #0
	bne	_trata_uint_end
	stmfd	sp!, {r5}
	mov	r5, #1
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
.data
auxbufferints:
	.skip 2000, 0
.align 1
stringmagica:
	.asciz "09223372036854775808"
