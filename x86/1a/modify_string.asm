section	.text
global  modify_string

modify_string:
	;	PROLOG
	push	ebp
	mov	ebp, esp

	;	CIAŁO

	mov ecx, DWORD [ebp+8]
	xor eax, eax
	

modify_string_loop:
	inc ecx
	mov dl, [ecx-1]
	cmp dl, 'a'
	jl not_small_letter
	cmp dl, 'z'
	jg modify_string_loop
	mov BYTE [ecx-1], '*'
	inc eax
	jmp modify_string_loop

not_small_letter:
	test dl, dl
	jnz modify_string_loop

fin:
	;	EPILOG
	pop	ebp
	ret
	
;
;============================================
; THE STACK - thanks to Zbigniew Szymanski
;============================================
;
; larger addresses
; 
;  |                               |
;  | ...                           |
;  ---------------------------------
;  | function parameter - char *nts| EBP+8
;  ---------------------------------
;  | return address                | EBP+4
;  ---------------------------------
;  | saved ebp                     | EBP, ESP
;  ---------------------------------
;  | ... here local variables      | EBP-x
;  |     when needed               |
;
; \/                              \/
; \/ the stack grows in this      \/
; \/ direction                    \/
;
; lower addresses
;
;
;============================================
