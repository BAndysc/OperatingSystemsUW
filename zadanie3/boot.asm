org 0x7c00

jmp 0:start          ; wyzerowanie rejestru cs

INTR_PRINT_CHAR_AH equ 0xE
INTR_PRINT_CHAR equ 0x10
INTR_KEYBOARD equ 16h
INTR_READ_KEY_PRESS equ 0h
INTR_WAIT equ 86h
INTR_OTHER equ 15h
INTR_DISK equ 13h
INTR_DISK_WRITE equ 03h
INTR_DISK_READ equ 02h
KEY_BACKSPACE equ 8
KEY_ENTER equ 13
KEY_CR equ 13
KEY_NL equ 10
KEY_a equ 97
KEY_A equ 65
KEY_Z equ 90
KEY_z equ 122
KEY_SPACE equ 32
MIN_NAME_LENGTH equ 3
ACCEPTED_LENGTH equ 11 ; pomniejszona o 1

print:               ; adres stringa w bx
    mov cl, [bx]
    test cl, cl
    jz print_koniec  ; gdy trafimy na bajt 0 -> koniec wypisywania
    mov ah, INTR_PRINT_CHAR_AH
    mov al, cl       ; aktualna literka
    int INTR_PRINT_CHAR
    inc bx
    jmp print
    print_koniec:
    ret    
    
label: DB "Enter your name", 0x0D, 0x0A, 0
hello: DB "Hello ", 0
newline: DB 0x0D, 0x0A, 0
buffer_count: DB 0
buffer_ptr: DW 0
buffer: times 13 DB 0

start:
    mov ax, cs      ; wyzerowanie pozostałych rejestrów segmentowych
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x8000  ; inicjacja stosu

    mov bx, label   ; wypisanie powitania
    call print

    mov ax, buffer
    mov [buffer_ptr], ax ; inicjalizacja wskaźnika bufora

take_char:
    mov ah, INTR_READ_KEY_PRESS
    int INTR_KEYBOARD
    ; read character in A

    cmp al, KEY_BACKSPACE
    je bckspace

    cmp al, KEY_ENTER
    je key_enter

    cmp al, KEY_A
    jl take_char  ; jeśli kod ascii < 'A' -> pobierz nowy znak

    cmp al, KEY_z
    jg take_char   ; jeśli kod ascii > 'z' -> pobierz nowy znak

    cmp al, KEY_Z
    jle take_char_ok   ; jeśli kod ascii < 'Z' -> znak jest ok

    cmp al, KEY_a
    jl take_char    ; jeśli kod ascii < 'a' -> pobierz nowy znak

take_char_ok:
    mov bl, [buffer_count]

    cmp bl, ACCEPTED_LENGTH
    jg take_char ; jeśli słowo ma już 12 liter -> pobierz nowy znak

    inc bl
    mov [buffer_count], bl  ; w przeciwnym razie zwiększami dłuość słowa

    mov ah, INTR_PRINT_CHAR_AH
    int INTR_PRINT_CHAR

    mov bx, [buffer_ptr]
    mov [bx], al         ; w miejsce wskaźnika wstawiamy wczytaną literę
    inc bx               ; zwiększamy wskaźnik
    mov [buffer_ptr], bx ; i zapisujemy

    jmp take_char

bckspace:   ; obsługa backspace
    mov bl, [buffer_count]
    cmp bl, 0
    je take_char   ; gdy nie wpisaliśmy słowa -> wczytaj nowy znak

    dec bl
    mov [buffer_count], bl ; wpp zmniejszamy długość słowa

    mov bx, [buffer_ptr]
    dec bx
    mov byte [bx], 0
    mov [buffer_ptr], bx  ; w miejsce wskaźnika wstawamy 0

    mov ah, INTR_PRINT_CHAR_AH
    mov al, KEY_BACKSPACE
    int INTR_PRINT_CHAR ; wyświetlamy backspace

    mov al, KEY_SPACE
    int INTR_PRINT_CHAR ; wyświetlamy spację

    mov al, KEY_BACKSPACE
    int INTR_PRINT_CHAR ; wyświetlamy backspace

    jmp take_char       ; pobieramy nowy znak

key_enter:    ; obsługa entera
    mov bl, [buffer_count]
    cmp bl, MIN_NAME_LENGTH
    jb take_char      ; jeśli słowo ma mniej liter niż powinno mieć, wczytaj kolejny znak

    mov ah, INTR_PRINT_CHAR_AH
    mov al, KEY_CR
    int INTR_PRINT_CHAR ; wyświetlamy znak powrotu karetki do początku wiersza

    mov al, KEY_NL
    int INTR_PRINT_CHAR ; wyświetlamy znak przeskoku do nowej linii

    mov bx, hello
    call print  ; wypisz hello

    mov bx, buffer
    call print  ; wypisz imię z bufora

    mov bx, newline
    call print  ; wypisz nową linię


    mov cx, 0x1e
    mov dx, 0x8480
    mov ah, INTR_WAIT
    int INTR_OTHER   ; sleep na 2s (2000000 = 0x001E8480)


    mov ah, INTR_DISK_WRITE
    mov al, 1   ; 1 sektor do zapisania
    mov ch, 0   ; cylinder zerowy
    mov cl, 3   ; sektor docelowy (trzeci, od 1024 bajta)
    mov dl, 80h ; pierwszy dysk
    mov dh, 0   ; głowica 0

    mov bx, 0
    mov es, bx
    mov bx, buffer ; adres źródłowy w es:bx
    int INTR_DISK  ; zapisujemy

    mov cx, startcopyhere   ; przenosimy pamięć od startcopyhere do stopcopyhere do pamięci pod adresem 0x0600
    mov si, 0x0600
    check:
    cmp cx, stopcopyhere
    jge 0x0600 ; jak skończymy kopiowanie, to skaczemy do przekopiowanej pamięci tzn 0x0600

    mov bx, cx
    mov al, [bx]
    mov [si], al

    inc si
    inc cx
    jmp check


startcopyhere:
    ; wczytujemy oryginalny bootloader z dysku
    mov ah, INTR_DISK_READ
    mov al, 1    ; 1 sektor
    mov ch, 0    ; z cylindra nr 0
    mov cl, 2    ; z sektora nr 2 (od 512 bajta)
    mov dl, 80h  ; z pierwszego dysku
    mov dh, 0    ; głowcica 0

    mov bx, 0
    mov es, bx
    mov bx, 0x7c00 ; pod adres 0x7c00
    int INTR_DISK

    jmp 0:0x7c00  ; skaczemy do przekopiowanego bootloadera

stopcopyhere:
    nop

times 510-($-$$) db 0   ; uzupełnienie do 512 bajtów
dw 0xaa55

