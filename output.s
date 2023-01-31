section .data
msg db 'Digite o input: '
MSG_SIZE EQU $-msg
section .bss
input_text resb 32
section.text
global_start
_start
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, MSG_SIZE
    int 80h

    mov eax, 3
    mov ebx, 0
    mov ecx, input_text
    mov edx, 32
    int 80h

    mov eax, 4
    mov ebx, 1
    mov ecx, input_text
    mov edx, 32
    int 80h



