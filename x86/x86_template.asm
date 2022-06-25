myproc:
; prolog – stały dla wszystkich procedur
    push ebp                                        ; zapamiętanie wskaźnika ramki procedury wołającej
    mov ebp, esp                                    ; ustanowienie własnego wskaźnika ramki
    sub esp, (ROZMIAR_DANYCH_LOKALNYCH + 3) & ~3    ; alokacja danych lokalnych

; zapamiętanie rejestrów zachowywanych (o ile są używane)
    push ebx
    push esi
    push edi

; ciało procedury
	; ...

; odtworzenie rejestrów, które były zapamiętane
	pop edi
    pop esi
    pop ebx
; epilog – stały dla wszystkich procedur
    mov esp, ebp	; dealokacja danych lokalnych
    pop ebp         ; odtworzenie wskaźnika ramki procedury wołającej
    ret             ; powrót