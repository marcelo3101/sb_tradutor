section .data
msg db 'Digite o input: '
MSG_SIZE EQU $-msg
valor dd 0
section .bss
input_text resb 32

section .text
global _start
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, MSG_SIZE
    int 80h

    ; Parte da leitura da função input
    mov eax, 3
    mov ebx, 0
    mov ecx, input_text
    mov edx, 32
    int 80h

    ; Conversão para número decimal
    mov edi, 10
    mov ebx, input_text ; ebx aponta para o primeiro caractere digitado
    mov eax, [ebx]
    mov ecx, 3
    sub eax, 0x30
    add [valor], eax
c:  inc ebx
    mov eax, [ebx]
    sub eax, 0x30
    mul edi
    add [valor], eax
    loop c
    add dword [valor], 20

    ;Converter novamente para ascII
    


    ;mov eax, 4
    ;mov ebx, 1
    ;mov ecx, input_text
    ;mov edx, 32
    ;int 80h

    mov eax, 1
    mov ebx, 0
    int 80h

    ; nasm -f elf -o input.o input.s && ld -m elf_i386 -o input input.o

    