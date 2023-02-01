section .data
msg db 'Digite o caractere: '
MSG_SIZE EQU $-msg
valor dd 0
section .bss
input_char resw 1 ; Reserva uma word para o char que será lido. PERGUNTAR: NÃO DEU ERRO PARA PUSH input_char CASO input_char SEJA RESB 1
output_char resw 1; Buffer de saída

section .text
global _start
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, MSG_SIZE
    int 80h

    push input_char
    call input_c
    movzx ecx, byte [input_char]
    mov byte [output_char], cl
    push output_char
    call output_c
    mov eax, 1
    mov ebx, 0
    int 80h

; ------------------------------------
;   Função para ler um char em ASCII
;              INPUT_C
; ------------------------------------

input_c:
    enter 0, 0 ; PUSH EBP e MOV EBP, ESP
    mov eax, 3
    mov ebx, 0
    mov ecx, [ebp+8]
    mov edx, 1
    int 80h
    leave ; MOV ESP, EBP e POP EBP
    ret 2

; -----------------------------------------
;   Função para escrever um char em ASCII
;                  OUTPUT_C
; -----------------------------------------

output_c:
    enter 0, 0; PUSH EBP e MOV EBP, ESP
    mov eax, 4
    mov ebx, 1
    mov ecx, [ebp+8]
    mov edx, 1
    int 80h
    leave ; MOV ESP, EBP e POP EBP
    ret 2

; ---------------------
;   Comando nasm e ld
; ---------------------

; nasm -f elf -o char.o char.s && ld -m elf_i386 -o char char.o