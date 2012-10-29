.global	_trata_char
.global _trata_str
.type 	_trata_char, %function
.type 	_trata_str, %function
_trata_char:
	ldr 	r3, [r2], #4 
	strb 	r3, [r1], #1
	mov 	pc, lr
	
_trata_str:
	ldr 	r3, [r2], #4
_tr_str_loop:	
	ldrb 	r4, [r3], #1
	cmp 	r4, #0
	moveq 	pc, lr
	strb 	r4, [r1], #1
	b 	_tr_str_loop
