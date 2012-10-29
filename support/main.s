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
	ldr	r1, =caracter1
	@ldr 	r2, =caracter2
	@ldr 	r3, =caracter4
	@stmfd	sp!, {r3}
	@ldr 	r3, =caracter3
	
	@mov	r3, r3, lsl #28
	@stmfd	sp!, {r1}
	@mov	r3, #0
	@stmfd	sp!, {r2}
	@stmfd	sp!, {r3}
	@ldr 	r3, =caracter3
	bl	myscanf
	@ldmfd 	sp!, {r3}
	ldr	r0, =mystring2
	ldr	r1, =caracter1
	ldr	r2, [r1]
	ldr	r3, [r1, #4]
	mov	r1, #0
	@mov 	r1, #0xF000
	@mov	r2, #0x22
	@mov	r3, #-44
	@ldr 	r2, =caracter2
	@stmfd	sp!, {R3}
	@stmfd	sp!, {r3}
	bl 	myprintf
__mainend:
	mov	r7, #1
	svc	0

	.data
	.align	4
mystring:
	.asciz	"%lld"
mystring2:
	.asciz 	"%0400lld"

	@@!!!!!!LEMBRAR DmE ZERAR BUFFER AUXILIAR DEPOIS DE USAR
	@@!!TRATAR CASO DO FALSO LONG QUE DEGENERA PRA SÓ USAR AS F DE NORMAL

caracter1:
	.word 0x0
caracter2:
	.word 0x0
caracter3:
	.word 0xca
caracter4:
	.word 0x11
	
