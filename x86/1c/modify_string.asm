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
	mov eax, DWORD [ebp+8]
	xor ecx, ecx
	

modify_string_loop:
	inc eax
	cmp BYTE [eax-1], '0'
	jl not_small_letter
	cmp BYTE [eax-1], '9'
	jg modify_string_loop
	mov BYTE [eax-1], '*'
	inc ecx
	jmp modify_string_loop

not_small_letter:
	test BYTE [eax-1], 0xFF
	jnz modify_string_loop

fin:
	mov eax, ecx
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
