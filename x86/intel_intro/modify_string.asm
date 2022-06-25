;=====================================================================
; ARKO - example Intel x86 assembly program
;
; author:      Rajmund Kozuszek
; date:        2022.03.29
; description: x86 (32-bit) - function modifying the input string 
;					int modify_string(char* nts_buffer);
;				changes all 'f' letters in the null terminated string to 'F'
;				returns the length of the string
;-------------------------------------------------------------------------------

section	.text
global  modify_string
global	modify_string_fixed

modify_string:
	push	ebp
	mov	ebp, esp
	mov	eax, [ebp+8]	; address of nts_buffer to eax
	mov	BYTE [eax], 'F'	; *eax = 'F'
	mov	eax, 7			; return length of the string
	pop	ebp
	ret
	


modify_string_fixed:
	push ebp
	mov ebp, esp
	
	mov eax, [ebp+8]
	mov eax, [eax+8]
	
	pop ebp
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
