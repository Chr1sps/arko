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
	mov ebx, DWORD [ebp+8]
	xor esi, esi
	

modify_string_loop:
	test BYTE [eax], 0xFF
	jz modify_string_return
	inc eax
	inc esi
	jnz modify_string_loop

modify_string_return:
	dec eax

modify_string_return_loop:
	mov dl, [ebx]
	mov cl, [eax]
	mov BYTE [ebx], cl
	mov BYTE [eax], dl
	dec eax
	inc ebx
	cmp eax, ebx
	jg modify_string_return_loop


fin:
	mov eax, esi
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
