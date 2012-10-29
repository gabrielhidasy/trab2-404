.global myscanf
.type myprintf, %function
.global _myscanf_real_error
myscanf:
	@a função myscanf recebe em r0 um buffer a ler
	@e em r1, r2, r3 e pilha lugares para armazenar
	@coisas que virão da entrada padrão
	@primeira coisa a fazer, empilhar os 3 endereços
	@restantes
	@stackinit e lr init serao usados para funcoes de erro
	ldr 	ip, =stackinit
	str	sp, [ip]
	ldr	ip, =lrinit
	str	lr, [ip]
	stmfd sp!, {r3}
	stmfd sp!, {r2}
	stmfd sp!, {r1}
	@guarda em r11 o parametro atual
	@r11 apontara sempre para o proximo parametro
	@a usar
	mov 	r1, sp
	@r2 - string de entrada
	@r3 - string de controle
	@r10 - numero de parametros lidos
	stmfd 	sp!, {R4-R11, lr}
	mov	r11, r1
	sub	r11, r11, #4
	mov 	r3, r0
	ldr 	r2, =bufferin
	@inicializa o contador de parametros lidos em 0
	mov r10, #0
	@carrega entrada em r2
	mov 	r0, r2
	mov 	r1, #2000
	bl 	syscallr
	@syscallr retorna em r0 numero de caracteres lidos
	mov 	r9, r0
_myscanf_loop:
	@carrega um caracter da string
	@de formatação
	ldrb 	r4, [r3], #1
	@se ele for zero - final da string -, sai
	cmp	r4, #0
	beq 	_myscanf_out
	@compara string de formatação
	@com caracter especial
	cmp	r4, #'%'
	addeq	r11, r11, #4
	addeq 	r10, r10, #1
	bleq 	_trata_mascaras_scanf
	@proximo argumento
	@se era caracter especial, o
	@na volta o usuario já digitou
	@voltar para o loop
	beq 	_myscanf_loop
	@carrega caracter da string de entrada
	ldrb	r5, [r2], #1
	@compara com caracter da string de formato
	cmp 	r4, r5
	bne	_myscanf_error
	@avança ambas as strings se igual
	b 	_myscanf_loop
_myscanf_out:
	ldr 	r10, =bufferin
	sub	r0, r3, r10
	mov 	r0, r9
	@deixar a pilha limpa, gravar o numero
	@de caracteres lidos em r0, e retornar
	@ao programa principal
	ldmfd sp!, {R4-R11, lr}
	ldmfd sp!, {R1-R3}
	mov pc, lr
	
_myscanf_error:	
	@quando o usuario digita, ele encerra a
	@string com \n, não é motivo para erro nesse
	@caso, mas o \n é problemativo, o usuario tem
	@tendencia ou o a digitar ele demais, ou só
	@no final da string, para evitar problema,
	@ignorar o caracter \n exceto no final
	@além disso, é preciso voltar a string de
	@formato para o caracter a ser lido
_myscanf_real_error:	
	mov	r0, #-1
	ldr r0, =error
	bl myprintf
	@limpa a pilha e sai em caso de erro
	ldr	sp, =stackinit
	ldr	sp, [sp]
	ldr	lr, =lrinit
	ldr	pc, [lr]

_trata_mascaras_scanf:
	@salvar registradores na pilha
	stmfd 	sp!, {R4-R10, lr}
	@ler o proximo caracter da string de
	@controle para definir o que ler
	ldrb	r4, [r3], #1
	stmfd	sp!, {r4}
	
	cmp 	r4, #'d'
	bleq	_le_int
	ldmfd 	sp, {r4}
	cmp	r4, #'d'
	ldmeqfd sp!, {r4}
	ldmeqfd	sp!, {R4 - R10, pc}
	
	cmp 	r4, #'x'
	bleq	_le_hexa
	ldmfd 	sp, {r4}
	cmp	r4, #'x'
	ldmeqfd sp!, {r4}
	ldmeqfd	sp!, {R4 - R10, pc}
	
	cmp 	r4, #'o'
	bleq	_le_octa
	ldmfd 	sp, {r4}
	cmp	r4, #'o'
	ldmeqfd sp!, {r4}
	ldmeqfd	sp!, {R4 - R10, pc}

	cmp 	r4, #'u'
	bleq	_le_uint
	ldmfd 	sp, {r4}
	cmp	r4, #'u'
	ldmeqfd	sp!, {r4}
	ldmeqfd	sp!, {R4 - R10, pc}

	cmp 	r4, #'c'
	bleq	_le_caracter
	ldmfd 	sp, {r4}
	cmp	r4, #'c'
	ldmeqfd sp!, {r4}
	ldmeqfd	sp!, {R4 - R10, pc}

	cmp	r4, #'s'
	bleq	_le_string
	ldmfd 	sp, {r4}
	cmp	r4, #'s'
	ldmeqfd sp!, {r4}
	ldmeqfd	sp!, {R4 - R10, pc}

	cmp	r4, #'l'
	bleq	_le_long
	ldmfd 	sp, {r4}
	cmp	r4, #'l'
	ldmeqfd sp!, {r4}
	ldmeqfd	sp!, {R4 - R10, pc}

	cmp 	r4, #'h'
	beq	_trata_short
	ldmeqfd	sp!, {R4 - R10, pc}
	@de um jeito ou de outro os argumentos
	@são gravados em registradores ou em palavras
	@mas ao ler o h, a função deve retornar erro
	@se o valor a ser escrito for maior que a palavra

_le_long_long:
	@ler o proximo caracter para definir
	@tipo de long long a ser lido
	stmfd 	sp!, {R4, lr}
	stmfd	sp!, {R4}

	cmp 	r4, #'d'
	bleq	_le_lint
	ldmfd	sp, {R4}
	cmp	r4, #'d'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}
	
	cmp 	r4, #'x'
	bleq	_le_lhexa
	ldmfd	sp, {R4}
	cmp		r4, #'x'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}
	
	cmp 	r4, #'o'
	bleq	_le_locta
	ldmfd	sp, {R4}
	cmp	r4, #'o'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}

	cmp 	r4, #'u'
	bleq	_le_luint
	ldmfd	sp, {R4}
	cmp	r4, #'u'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}

	ldmeqfd	sp!, {R4, pc}
_le_long:	
	@ler o proximo caracter para definir
	@tipo de long a ser lido
	@longs comuns são iguais a inteiros
	stmfd 	sp!, {R4, lr}
	ldrb	r4, [r3], #1
	stmfd	sp!, {R4}
	
	cmp 	r4, #'d'
	bleq	_le_int
	ldmfd	sp, {R4}
	cmp 	r4, #'d'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}

	cmp 	r4, #'x'
	bleq	_le_hexa
	ldmfd	sp, {R4}
	cmp 	r4, #'x'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}

	cmp 	r4, #'o'
	bleq	_le_octa
	ldmfd	sp, {R4}
	cmp 	r4, #'o'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}

	cmp 	r4, #'u'
	bleq	_le_uint
	ldmfd	sp, {R4}	
	cmp 	r4, #'u'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}

	cmp	r4, #'l'
	bleq	_le_long_long
	ldmfd	sp, {R4}
	cmp 	r4, #'l'
	ldmeqfd	sp!, {R4}
	ldmeqfd	sp!, {R4, pc}

	ldmfd	sp!, {R4}
	ldmfd	sp!, {R4, pc}
_trata_short:
	@dar um valor parametro novo para a função
	@escrever
	mov	r10, r11
	

.data
error:	
	.asciz "Deu pau\n"
nerror:
	.asciz "Não deu erro"
bufferin:
	.skip 2000, 0
bufferh:
	.word 0x0
bufferhh:
	.word 0x0
stackinit:
	.word 0x0
lrinit:
	.word 0x0
