%define shift 20
global	draw_triangle
section	.text

; [ebp+20] - &c
; [ebp+16] - &b
; [ebp+12] - &a
; [ebp+8] - &info
; [ebp+4] - return address
; [ebp] - stack pointer

; [ebp-4] - x

; [ebp-8] - y
; [ebp-12] - y.min
; [ebp-16] - y.max
; [ebp-20] - xp

; [ebp-24] - xk
; [ebp-28] - Δxp
; [ebp-32] - Δxk
; [ebp-36] - Δend

; [ebp-40] - Ip (R)
; [ebp-44] - Ik (R)
; [ebp-48] - Ip (G)
; [ebp-52] - Ik (G)

; [ebp-56] - Ip (B) 
; [ebp-60] - Ik (B) 
; [ebp-64] - ΔIp (R)
; [ebp-68] - ΔIk (R)

; [ebp-72] - ΔI (R)
; [ebp-76] - ΔIp (G)
; [ebp-80] - ΔIk (G)
; [ebp-84] - ΔI (G)

; [ebp-88] - ΔIp (B)
; [ebp-92] - ΔIk (B)
; [ebp-96] - ΔI (B)
; [ebp-100] - width * 3

; [ebp-104] - flags
; [ebp-108] - I (R)
; [ebp-112] - I (G)
; [ebp-116] - I (B)

draw_triangle:
; prolog – stały dla wszystkich procedur
    push ebp                                        ; zapamiętanie wskaźnika ramki procedury wołającej
    mov ebp, esp                                    ; ustanowienie własnego wskaźnika ramki
    sub esp, 116    ; alokacja danych lokalnych
; zapamiętanie rejestrów zachowywanych (o ile są używane)
    push ebx
    push esi
    push edi

sort_vertices:
    mov ebx, [ebp+12]   ; &a
    mov ecx, [ebp+16]   ; &b
    mov edx, [ebp+20]   ; &c
    mov di, WORD [ecx+6]
    cmp di, WORD [ebx+6]
    jge sort_vertices_2
    xchg ebx, ecx

sort_vertices_2:
    mov di, WORD [edx+6]
    cmp di, WORD [ecx+6]
    jge sort_vertices_3
    xchg ecx, edx

sort_vertices_3:
    mov di, WORD [ecx+6]
    cmp di, WORD [ebx+6]
    jge check_if_a_b_equal
    xchg ebx, ecx

check_if_a_b_equal:
    mov di, WORD [ebx+6]
    cmp di, WORD [ecx+6]
    jne save_vertices
    xchg ebx, edx

sort_by_x:
    mov ax, WORD [edx+4]
    cmp ax, WORD [ecx+4]
    jge save_vertices
    xchg ecx, edx

save_vertices:
    mov [ebp+12], ebx
    mov [ebp+16], ecx
    mov [ebp+20], edx
    ; ebx, ecx i edx zostają

y_min_max:
    xor eax, eax
    mov ax, WORD [ebx+6]
    xor edi, edi
    mov di, WORD [edx+6]
    cmp di, ax
    jge y_min_max_save
    xchg eax, edi

y_min_max_save:
    mov [ebp-12], eax
    mov [ebp-16], edi 

delta_end:
    ; ebp-36 - Δend
    ; Δend = LINEBYTES - WIDTH * 3
    mov ecx, 0
    mov ecx, [ebp+8]
    mov eax, [ecx]
    lea eax, [2 * eax + eax]
    mov [ebp-100], eax
    mov edx, eax
    add eax, 3
    and eax, -4
    sub eax, edx
    mov [ebp-36], eax

loop_y_init:
    mov edi, [ecx+8]
    mov DWORD [ebp-8], 0

loop_y:
    mov esi, [ebp-8]
    cmp esi, [ebp-12]
    jl loop_y_skip

    cmp [ebp-16], esi
    jl loop_y_skip

    test DWORD [ebp-104], 1
    jz check_which_vertex

    mov ebx, [ebp+16]
    cmp si, WORD [ebx+6]
    je a_b_switch

    jmp loop_x_init

check_which_vertex:
    or DWORD [ebp-104], 1
    mov esi, [ebp+12]
    mov si, WORD [esi+6]
    cmp si, WORD [ebp-8]
    jnz not_a
    
is_a:
    mov eax, [ebp+12]
    mov ebx, [eax]
    mov ax, WORD [eax+4]
    and eax, 0x0000FFFF
    shl eax, shift
    mov [ebp-20], eax
    mov [ebp-24], eax

    mov eax, ebx
    shr eax, 16
    shl eax, shift
    mov [ebp-40], eax
    mov [ebp-44], eax

    mov eax, ebx
    and eax, 0x0000FF00
    shr eax, 8
    shl eax, shift
    mov [ebp-48], eax
    mov [ebp-52], eax

    mov eax, ebx
    and eax, 0x000000FF
    shl eax, shift
    mov [ebp-56], eax
    mov [ebp-60], eax
    jmp calculate

a_b_switch:
    mov ecx, [ebp+20]
    cmp si, WORD [ecx+6]
    je loop_y_skip

a_change:
    ; b w ebx
    ; c w ecx
    mov eax, [ebp+12]

    mov edx, [ebp-24]
    add edx, 1 << (shift - 1)
    shr edx, shift
    mov WORD [eax+4], dx

    mov dx, WORD [ebx+6]
    mov WORD [eax+6], dx

    mov edx, [ebp-44]
    shr edx, shift
    mov BYTE [eax+2], dl

    mov edx, [ebp-52]
    shr edx, shift
    mov BYTE [eax+1], dl

    mov edx, [ebp-60]
    shr edx, shift
    mov BYTE [eax], dl

a_c_swap:
    mov [ebp+12], ecx
    mov [ebp+20], eax

    ; Δk = 1 / (a.y - c.y)
    mov ebx, [ebp+12]
    mov ecx, [ebp+20]
    mov si, WORD [ebx+6]
    sub si, WORD [ecx+6]
    sal esi, 16
    sar esi, 16
    mov eax, 1
    sal eax, shift
    xor edx, edx
    idiv esi
    mov esi, eax

    jmp calculate_reverse

not_a:
    mov eax, [ebp+16]
    mov ecx, [eax]
    mov ax, WORD [eax+4]
    and eax, 0x0000FFFF
    shl eax, shift

    mov ebx, [ebp+20]
    mov edx, [ebx]
    mov bx, WORD [ebx+4]
    and ebx, 0x0000FFFF
    shl ebx, shift

    mov [ebp-20], eax
    mov [ebp-24], ebx

    mov eax, ecx
    shr eax, 16
    shl eax, shift
    mov [ebp-40], eax

    mov eax, ecx
    and eax, 0x0000FF00
    shr eax, 8
    shl eax, shift
    mov [ebp-48], eax

    mov eax, ecx
    and eax, 0x000000FF
    shl eax, shift
    mov [ebp-56], eax

    mov eax, edx
    shr eax, 16
    shl eax, shift
    mov [ebp-44], eax

    mov eax, edx
    and eax, 0x0000FF00
    shr eax, 8
    shl eax, shift
    mov [ebp-52], eax

    mov eax, edx
    and eax, 0x000000FF
    shl eax, shift
    mov [ebp-60], eax

calculate:

    ; Δk = 1 / (a.y - c.y)
    mov ebx, [ebp+12]
    mov ecx, [ebp+20]
    mov si, WORD [ebx+6]
    sub si, WORD [ecx+6]
    sal esi, 16
    sar esi, 16
    mov eax, 1 << shift
    xor edx, edx
    idiv esi
    mov esi, eax

    ; Δxk = Δk * (a.x - c.x)
    mov ax, WORD [ebx+4]
    sub ax, WORD [ecx+4]
    sal eax, 16
    sar eax, 16 
    imul eax, esi
    mov [ebp-32], eax

calculate_reverse:

    ; ΔIk = Δk * (Ia - Ic)
    ; R
    mov eax, [ebx]
    mov edx, [ecx]
    shl eax, 8
    shr eax, 24
    shl edx, 8
    shr edx, 24
    sub eax, edx
    imul eax, esi
    mov [ebp-68], eax

    ; G
    mov eax, [ebx]
    mov edx, [ecx]
    shl eax, 16
    shr eax, 24
    shl edx, 16
    shr edx, 24
    sub eax, edx
    imul eax, esi
    mov [ebp-80], eax

    ; B
    mov eax, [ebx]
    mov edx, [ecx]
    and eax, 0x000000FF
    and edx, 0x000000FF
    sub eax, edx
    imul eax, esi
    mov [ebp-92], eax

    ; Δp = 1 / (a.y - b.y)
    mov ecx, [ebp+16]
    mov si, WORD [ebx+6]
    sub si, WORD [ecx+6]
    sal esi, 16
    sar esi, 16
    mov eax, 1 << shift
    xor edx, edx
    idiv esi
    mov esi, eax

    ; Δxp = Δp * (a.x - b.x)
    mov ax, WORD [ebx+4]
    sub ax, WORD [ecx+4]
    sal eax, 16
    sar eax, 16 
    imul eax, esi
    mov [ebp-28], eax

    ; ΔIp = Δp * (Ia - Ib)
    ; R
    mov eax, [ebx]
    mov edx, [ecx]
    shl eax, 8
    shr eax, 24
    shl edx, 8
    shr edx, 24
    sub eax, edx
    imul eax, esi
    mov [ebp-64], eax

    ; G
    mov eax, [ebx]
    mov edx, [ecx]
    shl eax, 16
    shr eax, 24
    shl edx, 16
    shr edx, 24
    sub eax, edx
    imul eax, esi
    mov [ebp-76], eax

    ; B
    mov eax, [ebx]
    mov edx, [ecx]
    and eax, 0x000000FF
    and edx, 0x000000FF
    sub eax, edx
    imul eax, esi
    mov [ebp-88], eax


loop_x_init:
    mov DWORD [ebp-4], 0
    ; do obliczeń wszystko oprócz edi
    mov ecx, [ebp-20]
    mov ebx, [ebp-24]
    mov edx, 1 << (shift - 1)
    add ecx, edx
    add ebx, edx
    shr ecx, shift
    shr ebx, shift


loop_x:
    mov eax, [ebp-4]
    mov edx, ebx
    sub edx, eax
    sub eax, ecx

    test edx, edx
    jz calculate_x

    test eax, eax
    jz calculate_x

    shr eax, 31
    shr edx, 31
    xor eax, edx
    test eax, eax
    jnz loop_x_end

calculate_x:
    ; do obliczeń: eax, ebx, esi

    test DWORD [ebp-104], 2
    jnz write_pixel
    or DWORD [ebp-104], 2

    ; Δs = 1 / (xk - xp)
    mov esi, [ebp-24]
    mov edx, [ebp-20]
    sub esi, edx
    ; add esi, 1 << (shift - 1)
    sar esi, shift
    cmp esi, 0
    je single_point
    mov eax, 1 << shift
    xor edx, edx
    idiv esi
    mov esi, eax

    ; ΔIs = Δs * (Ik - Ip)
    ; R
    mov eax, [ebp-44]
    mov edx, [ebp-40]
    sub eax, edx
    add eax, 1 << (shift - 1)
    sar eax, shift
    imul eax, esi
    mov [ebp-72], eax 

    ; G
    mov eax, [ebp-52]
    mov edx, [ebp-48]
    sub eax, edx
    add eax, 1 << (shift - 1)
    sar eax, shift
    imul eax, esi
    mov [ebp-84], eax 

    ; B
    mov eax, [ebp-60]
    mov edx, [ebp-56]
    sub eax, edx
    add eax, 1 << (shift - 1)
    sar eax, shift
    imul eax, esi
    mov [ebp-96], eax 

    cmp esi, 0
    jl negative_gain

single_point:
    mov eax, [ebp-40]
    mov [ebp-108], eax
    
    mov eax, [ebp-48]
    mov [ebp-112], eax
    
    mov eax, [ebp-56]
    mov [ebp-116], eax

    jmp write_pixel

negative_gain:
    mov eax, [ebp-44]
    mov [ebp-108], eax
    
    mov eax, [ebp-52]
    mov [ebp-112], eax
    
    mov eax, [ebp-60]
    mov [ebp-116], eax

write_pixel:

    mov eax, [ebp-108]
    ;add eax, 1 << (shift - 1)
    shr eax, shift
    mov BYTE [edi+2], al

    mov eax, [ebp-112]
    ;add eax, 1 << (shift - 1)
    shr eax, shift
    mov BYTE [edi+1], al

    mov eax, [ebp-116]
    ;add eax, 1 << (shift - 1)
    shr eax, shift
    mov BYTE [edi], al

loop_x_end:

    mov eax, [ebp-72]
    add [ebp-108], eax

    mov eax, [ebp-84]
    add [ebp-112], eax
    
    mov eax, [ebp-96]
    add [ebp-116], eax

    add DWORD [ebp-4], 1
    add edi, 3
    mov eax, [ebp+8]
    mov eax, [eax]
    cmp eax, [ebp-4]
    jnz loop_x
    jmp loop_y_end

loop_y_skip:
    add edi, [ebp-100]

loop_y_end:
    mov eax, [ebp-28]
    add [ebp-20], eax

    mov eax, [ebp-32]
    add [ebp-24], eax

    mov eax, [ebp-64]
    add [ebp-40], eax

    mov eax, [ebp-68]
    add [ebp-44], eax

    mov eax, [ebp-76]
    add [ebp-48], eax

    mov eax, [ebp-80]
    add [ebp-52], eax

    mov eax, [ebp-88]
    add [ebp-56], eax

    mov eax, [ebp-92]
    add [ebp-60], eax

    and DWORD [ebp-104], -3

    add edi, [ebp-36]
    add DWORD [ebp-8], 1
    mov ebx, [ebp+8]
    mov ebx, [ebx+4] 
    cmp ebx, [ebp-8]
    jnz loop_y

draw_triangle_end:
	pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret