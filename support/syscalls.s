.global syscallw
.type 	syscallw, %function
.global syscallr
.type 	syscallr, %function
.global mygetchar
.type 	mygetchar, %function

mygetchar:
	@lê um caracter e coloca em r0
	@sei sobre calle-safe, mas vou fazer
	@essa ALL safe por hora
	stmfd 	sp!, {R4-R11, lr}
	@salva contador de caracteres lidos
	mov 	r10, r2
	@getchar, um caracter, 1
	mov 	r2, #1
	@a syscall imprime um buffer
	@carregar um buffer em r1
	ldr	r1, =buffgetchar
	@move para r0 o identificador de saida
	mov 	r0, #0
	@move para r7 o codigo da syscall
	mov 	r7, #3
	svc 	0
	ldrb	r0, [r1]
	@recupera numero de caracteres lidos e soma um
	add 	r2, r10, #1
	ldmfd 	sp!, {R4 - R11, lr}
	mov 	pc, lr
syscallw:
	stmfd 	sp!, {R4-R11, lr}
	@recebe em r0 o buffer a imprimir
	@em r1 o comprimento
	@acerta o comprimento em r2
	mov 	r2, r1
	@coloca o buffer em r1
	mov 	r1, r0
	@coloca o codigo de stdout em r0
	mov 	r0, #1
	mov 	r7, #4
	@chama a syscall
	@LR é NOTHING SAFE
	svc 	0
	@volta para a função principal
	ldmfd 	sp!, {R4 - R11, lr}
	mov 	pc, lr

syscallr:
	stmfd	sp!, {R4-R11, lr}
	@recebe em r0 um buffer onde armazenar a string,
	@em r1 o comprimento
	@acerta o comprimento em r2
	mov 	r6, r2
	mov	r2, r1
	@coloca o buffer em r1
	mov 	r1, r0
	@coloca stdin em r0
	mov 	r0, #0
	@guarda em r7 a syscall read
	mov 	r7, #3
	svc 	0
	mov 	r8, r0
	mov 	r0, r1
	mov	r1, r8
	mov	r2, r6
	ldmfd 	sp!, {R4 - R11, lr}
	mov 	pc, lr
.data
buffgetchar:
	.skip 1, 0
	