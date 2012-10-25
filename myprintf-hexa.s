.global _trata_hex_long
.global	_trata_hex_short
.type _trata_hex_long, %function
.type _trata_hex_short, %function
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

.data
auxbuffer:
	.skip 2000, 0
	