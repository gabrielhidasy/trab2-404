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
	ldr	r1, =caracter4
	ldr 	r2, =caracter2
	ldr 	r3, =caracter3
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
	@ldr	r1, [r1]
	@ldr	r3, [r1, #4]
	@mov	r1, #0
	@mov 	r1, #0xF000
	ldr	r1, =caracter4
	ldr	r1, [r1]
	ldr	r2, =caracter4
	ldr	r2, [r2]
	ldr	r3, =caracter4
	ldr	r3, [r3,#4]
	@ldr	r1, [r1]
	@stmfd	sp!, {R3}
	@stmfd	sp!, {r3}
	bl 	myprintf
__mainend:
	mov	r7, #1
	svc	0

.data
	.align	4
mystring:
	.asciz	"%llX"
mystring2:
	.asciz 	"Olha meu int %llX\n"


caracter1:
	.word 0x0
caracter2:
	.word 0x0
caracter3:
	.word 0xca
caracter4:
	.word 0x0
	.word 0x0
	.skip 2000, 0
	