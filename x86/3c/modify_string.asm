section	.text
global  modify_string


modify_string:
; prolog – stały dla wszystkich procedur
    push ebp                                        ; zapamiętanie wskaźnika ramki procedury wołającej
    mov ebp, esp                                    ; ustanowienie własnego wskaźnika ramki


; zapamiętanie rejestrów zachowywanych (o ile są używane)
    push ebx
    push esi
    push edi

	;	CIAŁO
	mov eax, DWORD [ebp+8]	;	read pointer
	mov ebx, DWORD [ebp+8]	;	write pointer
	xor esi, esi			;	letter counter
	

modify_string_loop:
	test BYTE [eax], 0xFF
	jz print_digits
	cmp BYTE [eax], ' '
	je print_digits
	inc eax
	inc esi
	jmp modify_string_loop

print_digits:
	mov edi, esi

modulo:
	cmp edi, 10
	jl	set_digit_char
	sub edi, 10
	jmp modulo

set_digit_char:
	add edi, '0'	;	ASCII code for zero is 48

print_digits_loop:
	cmp BYTE eax, 0
	je fin
	cmp eax, ebx
	je print_digits_end
	mov BYTE[ebx], edi
	inc ebx
	jmp modify_string_loop

print_digits_end:
	xor esi, esi
	

fin:
; odtworzenie rejestrów, które były zapamiętane
	pop edi
    pop esi
    pop ebx
; epilog – stały dla wszystkich procedur
    mov esp, ebp	; dealokacja danych lokalnych
    pop ebp         ; odtworzenie wskaźnika ramki procedury wołającej
    ret             ; powrót

	
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
