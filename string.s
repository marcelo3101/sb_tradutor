section .data
msg db 'Digite a string: '
MSG_SIZE EQU $-msg
valor dd 10 ; Tamanho da string. Reserva de uma DWORD, então pode ter (2^32) - 1 de tamanho máximo (4294967295)
section .bss
string resd 1 ; Reserva uma dword para endereço do caractere ASCII

section .text
global _start
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, MSG_SIZE
    int 80h

    push string
    push dword [valor] ; [ESP] <-- string_size (Número inteiro, 4bytes)
    call input_s
    push string
    push dword [valor]
    call output_s
    mov eax, 1
    mov ebx, 0
    int 80h

; ----------------------------------
;   Função para ler bytes em ASCII
;              INPUT_S
; ----------------------------------

input_s:
    enter 0, 0 ; PUSH EBP e MOV EBP, ESP
    mov eax, 3
    mov ebx, 0
    mov ecx, [ebp+12]
    mov edx, [ebp+8]
    int 80h
    leave ; MOV ESP, EBP e POP EBP
    ret 2

; ---------------------------------------
;   Função para escrever bytes em ASCII
;                  OUTPUT_S
; ---------------------------------------

output_s:
    enter 0, 0; PUSH EBP e MOV EBP, ESP
    mov eax, 4
    mov ebx, 1
    mov ecx, [ebp+12]
    mov edx, [ebp+8]
    int 80h
    leave ; MOV ESP, EBP e POP EBP
    ret 2

; ---------------------
;   Comando nasm e ld
; ---------------------

; nasm -f elf -o string.o string.s && ld -m elf_i386 -o string string.o