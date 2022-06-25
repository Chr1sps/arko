section	.text
global  modify_string

modify_string:
; prolog – stały dla wszystkich procedur
    push ebp                                        ; zapamiętanie wskaźnika ramki procedury wołającej
    mov ebp, esp                                    ; ustanowienie własnego wskaźnika ramki

; zapamiętanie rejestrów zachowywanych (o ile są używane)
    push ebx

; ciało procedury
	xor eax, eax		;	licznik usuniętych znaków
	mov ebx, [ebp+8]	;	wskaźnik odczytu
	mov ecx, [ebp+8]	;	wskaźnik zapisu
	xor dl, dl			;	ostatni zapamiętany znak

modify_string_loop:
	mov dh, [ebx]
	inc ebx
	test dh, 0xFF		;	sprawdzenie, czy znak nie jest '\0'
	jz modify_string_end		;	skok na koniec w przypadku, kiedy tak jest
	cmp dh, dl			;	sprawdzenie, czy znak się powtarza
	je same_char				;	skok do procedury powtórzonego znaku
	mov dl, dh			;	zapis nowej litery do dl
	mov BYTE [ecx], dl			;	zapis nowej litery do stringa
	inc ecx						;	inkrementacja wskaźnika zapisu i odczytu
	jmp modify_string_loop		;	skok powrotny

same_char:
	inc eax						;	inkrementacja wskaźnika odczytu i rejestru ilości usuniętych znaków
	jmp modify_string_loop		;	skok powrotny

modify_string_end:
	mov BYTE [ecx], 0			;	dopisanie znaku '\0'
; odtworzenie rejestrów, które były zapamiętane
    pop ebx
; epilog – stały dla wszystkich procedur
;    mov esp, ebp	; dealokacja danych lokalnych
    pop ebp         ; odtworzenie wskaźnika ramki procedury wołającej
    ret             ; powrót