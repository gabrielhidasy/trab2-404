.global _le_caracter
.type 	_le_caracter, %function
.global _le_string
.type _le_string, %function
_le_caracter:
	@gets an caracter from the input buffer
	ldrb	r4, [r2], #1
	@gets an adress to store the char from the stack
	ldr	r5, [r11], #4
	@store the character in the parameter
	strb	r4, [r5]
	mov 	pc, lr
_le_string:
	@get caracter from input buffer
	ldrb	r4, [r2], #1
	@load the adress to store it
	ldr	r5, [r11], #4
	@save the caracter to the string buffer
	strb	r4, [r5], #1
	@compare the caracter with 0
	@even an null string would store
	@the first 0, it is used to identify
	@the end of the string
	cmp	r4, #0
	bne	_le_string
	mov	pc, lr
