global init
global producer;
global consumer

extern malloc
extern produce  ; int produce(int64_t *);
extern consume  ; int consume(int64_t);
extern verhogen ; void verhogen(int32_t*);
extern proberen ; void proberen(int32_t*);

section .bss
    buffer_start: resq 1
    buffer_size: resq 1
    sem_free: resd 1
    sem_full: resd 1
    portion_producer: resq 1
    buffer_producer_index: resq 1

    portion_consumer: resq 1
    buffer_consumer_index: resq 1


section .text

INIT_MAX_SIZE equ 0x7FFFFFFF
INIT_ERROR_OVERFLOW equ -1
INIT_ERROR_ZERO equ -2
INIT_ERROR_MALLOC equ -3

init: ; (size_t rdi)
    push rdi

    ; zero all global variables, so that even if we run init twice
    ; everything will be ok
    mov qword [buffer_start], 0
    mov qword [buffer_size], 0
    mov dword [sem_free], 0
    mov dword [sem_full], 0
    mov qword [portion_producer], 0
    mov qword [buffer_producer_index], 0
    mov qword [portion_consumer], 0
    mov qword [buffer_consumer_index], 0


    cmp rdi, INIT_MAX_SIZE       ; if (rdi <= 2^31-1)
    jbe init_check_zero          ;     goto init_check_zero
    mov rax, INIT_ERROR_OVERFLOW ; return INIT_ERROR_OVERFLOW
    pop rdi
    ret

    init_check_zero:
    cmp rdi,0                    ; if (rdi == 0)
    jne init_alloc               ;     goto init_alloc
    mov rax, INIT_ERROR_ZERO     ; return INIT_ERROR_ZERO
    pop rdi
    ret

    init_alloc:
    imul rdi, 8                  ; rdi = n * sizeof(int64)
    call malloc                  ; rax = malloc(rdi)
    cmp rax, 0                   ; if (rax == 0)
    jnz init_ok
    mov rax, INIT_ERROR_MALLOC   ;     return INIT_ERROR_MALLOC
    pop rdi
    ret

    init_ok:                     ; else 
    pop rdi
    mov [buffer_start], rax      ;     buffer_start = rax
    mov [buffer_size], rdi       ;     buffer_size = rdi
    mov [sem_free], edi          ;     sem_free = edi
    mov rax, 0                   ;     return 0
    ret


producer:
    sub rsp, 8

    producer_loop:
    mov rdi, portion_producer     
    call produce                            ; rax = produce(&portion_producer)
    
    test rax, rax                           ; if rax == 0
    je producer_end                         ;   goto producer_end // return

    mov rdi, sem_free            
    call proberen                           ; proberen(&sem_free)

    mov r8, [portion_producer]         
    mov r9, [buffer_producer_index]
    mov r10, [buffer_start]
    mov [r10+r9*8], r8                    ; *(buffer_start + buffer_producer_index*8) = portion_producer

    mov rdi, sem_full            
    call verhogen                           ; verhogen(&sem_full)

    inc qword [buffer_producer_index]       ; buffer_producer_index++
    mov qword rax, [buffer_producer_index]
    cmp qword rax, [buffer_size]
    jl producer_loop                        ; if buffer_producer_index >= buffer_size 
    mov qword [buffer_producer_index], 0    ;   buffer_producer_index = 0
    jmp producer_loop                       ; repeat

    producer_end:
    add rsp, 8
    ret


consumer:
    sub rsp, 8

    consumer_loop:
    mov rdi, sem_full
    call proberen                           ; proberen(&sem_full)
       
    mov r8, [buffer_consumer_index]
    mov r9, [buffer_start]
    mov r10, [r9 + r8 * 8]                  ; portion_consumer = *(buffer_start + buffer_consumer_index*8)
    mov [portion_consumer], r10

    mov rdi,sem_free
    call verhogen                           ; verhogen(&sem_free)

    inc qword [buffer_consumer_index]       ; buffer_consumer_index++
    mov qword rax, [buffer_consumer_index]
    cmp qword rax, [buffer_size]
    jl consumer_continue                    ; if buffer_consumer_index >= buffer_size 
    mov qword [buffer_consumer_index], 0    ;   buffer_consumer_index = 0
    
    consumer_continue:
    mov rdi,[portion_consumer]
    call consume                            ; rax = consume(&portion_consumer)

    cmp rax, 0
    jne consumer_loop                       ; if rax == 0, repeat

    add rsp, 8
    ret
