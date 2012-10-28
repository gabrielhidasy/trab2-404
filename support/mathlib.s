.global pow10			
.type 	pow10, %function
.global magic
.type 	magic, %function
.global longsub
.type 	longsub, %function
.global long4lsl
.type 	long4lsl, %function
.global long4lsr
.type 	long4lsr, %function
.global long3lsl
.type 	long3lsl, %function
.global long3lsr
.type 	long3lsl, %function
.global mult6410
.type 	mult6410, %function
pow10:
	@recebe um numero em r0, retorna esse numero
	@x 10 r1 vezes
	stmfd sp!, {r4,r5}
	mov r4, #1
	mov r5, #10
_pow10loop:
	cmp 	r1, #0
	beq 	_pow10end
	sub 	r1, r1, #1
	mul 	r0, r5, r0
	b	_pow10loop 
_pow10end:
	ldmfd 	sp!, {r4, r5}
	mov 	pc, lr

magic:
	@magically divide an 32 bits number by 10
	@its made by multipling the number for a
	@constant ((2^33)/10) then getting only the
	@most significant part of the number, and
	@bitshifting it todivide it by 2
	stmfd 	sp!, {R4-R11, lr}
	ldr 	r4, =magicconstant
	ldr 	r4, [r4]
	mov 	r5, r0
	umull 	r6,r7,r4,r5
	mov 	r6, r0
	mov 	r7, r7, lsr #1
	mov 	r0, r7
	@res em r0
	mov 	r5, #10
	mul 	r7, r0, r5
	sub 	r1, r6, r7
	@mod in r1
	ldmfd 	sp!, {R4-R11, pc}
longsub:
	@essa função recebe em r1:r0 um long e em r3:r2 outro long
	@e retorna em r1:r0 a subtração deles (r3:r2-r1:r0)
	stmfd 	sp!, {R4-R5, lr}
	subs r4, r2, r0
	sbc r5, r3, r1
	mov r0, r4
	mov r1, r5
	ldmfd sp!, {R4-R5, pc}

longlsr: @em teste
	@recebe em r1:r0 um numero long
	@devolve em r1:r0 esse numero/2
	stmfd	sp!, {R4}
	@desloca a parte menos significativa
	mov 	r0, r0, lsr #1
	@o bit menos significativo da parte mais
	@significativa é somado deslocado 31x nele
	and 	r4, r1, #1
	mov	r4, r4, lsl #31
	add	r0, r0, r4
	@agora deslocar r1
	mov	r1, r1, lsr #1
	ldmfd	sp!, {R4}
	mov	pc, lr
long3lsr:
	stmfd 	sp!, {lr}
	bl 	longlsr
	bl 	longlsr
	bl 	longlsr
	ldmfd	sp!, {pc}
long4lsr:
	stmfd 	sp!, {lr}
	bl 	longlsr
	bl 	longlsr
	bl 	longlsr
	bl 	longlsr
	ldmfd	sp!, {pc}

longlsl: @em teste
	@recebe em r1:r0 um numero long
	@devolve em r1:r0 esse numero/2
	stmfd	sp!, {R4}
	@descobre numero mais significativo da parte menos significativa
	mov 	r4, #1
	mov 	r4, r4, lsl #31
	and	r4, r4, r0
	mov	r4, r4, lsr #31
	@desloca parte mais significativa, lsl
	mov	r1, r1, lsl #1
	@adiciona a ela o bit mais significativo da parte menos significativa
	add	r1, r1, r4
	@desloca a parte menos significativa
	mov	r0, r0, lsl #1
	ldmfd	sp!, {R4}
	mov	pc, lr
long3lsl:
	stmfd 	sp!, {lr}
	bl 	longlsl
	bl 	longlsl
	bl 	longlsl
	ldmfd	sp!, {pc}
long4lsl:
	stmfd 	sp!, {lr}
	bl 	longlsl
	bl 	longlsl
	bl 	longlsl
	bl 	longlsl
	ldmfd	sp!, {pc}
chartonumber:
	@gets an character in r0 and
	@returns its hexa, octa or,
	@decimal,  assumes its a digit
	@(the octa is contained in dec
	@and dec in hexa)
	sub 	r0, r0, #48
	cmp	r0, #'9'
	subgt	r0, r0, #39
mult6410:
	@multiply an 64 bits number in r1:r0 * 10
	stmfd 	sp!, {r4-r6, lr}
	@first multiply the bigger part for 10
	mov 	r6, #10
	mul	r1, r6, r1
	@now an long multiplication in the least
	@significant part
	umull	r4, r5, r0, r6
	@mov the least significant of them (r4)
	@to the awser less significative
	mov	r0, r4
	@and add the most significatives (r1, r5)
	add	r1, r1, r5
	@the awser is in R1:R0
	ldmfd sp!, {r4-r6, pc}
.data
magicconstant:
	.int 858993460
	
