global proberen
global verhogen

section .text

proberen:
    testandcmp:
    cmp dword [rdi], 0
    jle testandcmp

    mov eax, -1
    lock xadd dword [rdi], eax  ; decrease semaphore
    
    test eax, eax
    jg proberen_ok
    lock inc dword [rdi]        ; semaphore was below 1, restore state
    jmp proberen                ; and repeat

    proberen_ok:
    ret


verhogen:
    lock inc dword [rdi]
    ret