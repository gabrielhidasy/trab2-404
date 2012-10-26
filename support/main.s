	.text
	.align	4
	.global _start
	.global	main
	.type	main, %function
@sem _start na raspberry pi ao separar o arquivo em diretorios
@o programa se iniciava pela myprintf-hexa.s, não dava certo
@com ele não compila do simulador
_start:	
main:
	ldr	r0, =mystring
	mov	r1, #0x6
	mov 	r2, #0xD
	mov 	r3, #0xE
	stmfd	sp!, {r3}
	@ldr 	r3, =caracter3
	bl	myprintf
	ldmfd 	sp!, {r3}
	ldr	r0, =mystring
	ldr	r1, =caracter1
	ldrb	r1, [r1]
	ldr 	r2, =caracter2
	ldrb 	r2, [r2]
	ldr 	r3, =caracter4
	ldrb	r3, [r3]
	stmfd	sp!, {r3}
	ldr 	r3, =caracter3
	ldrb 	r3, [r3]
	@bl 	myprintf
__mainend:
	mov	r7, #1
	svc	0

	.data
	.align	4
mystring:
	.asciz	"ola fia duma ronca i fuca %lx %lx %lx\n"
	.asciz	"garbage"
mystring2:
	.asciz 	"Hello Garbage\n"

	@@!!!!!!LEMBRAR DE ZERAR BUFFER AUXILIAR DEPOIS DE USAR
	@@!!TRATAR CASO DO FALSO LONG QUE DEGENERA PRA SÓ USAR AS F DE NORMAL
	@@tá tratando tudo como unsigned
caracter1:
	.word 0xba
caracter2:
	.word 0xba
caracter3:
	.word 0xca
caracter4:
	.word 0x11
	
