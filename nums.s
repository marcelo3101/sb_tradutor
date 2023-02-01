section .data
msg db 'Digite o input: '
MSG_SIZE EQU $-msg
valor dd 0
section .bss
input_text resb 10 ; Será o parâmetro de INPUT
buffer resb 10 ; String resultado da conversão de int para ASCII

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
    mov edx, 10
    int 80h

    ; Converte string para decimal
atoi:
    xor eax, eax ; eax inicializado como zero
    mov esi, input_text ; esi aponta para o endereço inicial do input
    mov ebx, 10 ; ebx igual a 10 para a multiplicação
.loop:
    movzx ecx, byte [esi] ; ecx recebe o caractere digitado, zerando o resto dos bits
    inc esi ; incrementa para a próxima iteração
    cmp ecx, 0x30 ; Compara se é um dígito válido
    jb .done
    cmp ecx, 0x39
    ja .done
    sub ecx, 0x30 ; Realiza a conversão
    mul ebx ; Multiplica por 10, na primeira iteração eax é zero, então não irá alterar o valor
    add eax, ecx ; Adição do valor convertido, após multiplicar por 10
    jmp .loop ; jmp do loop
.done:
    add eax, 20

    ;Converter novamente para ASCII
int_to_string:
    mov esi, buffer     ; esi aponta para o primeiro byte de buffer
    add esi, 9          ; Vai para o último endereço do buffer
    mov byte [esi], 0   ; Adiciona o terminator no conteúdo do último endereço
    mov ebx, 10         ; Salva 10 em ebx para realizar a divisão 
.next_digit:
    xor edx, edx        ; Limpa o valor de edx para realizar a divisão de edx:eax por ebx
    div ebx             ; eax /= 10, realiza a divisão inteira. O resto estará em edx
    add dl, 0x30        ; Converte o resto da divisão para ASCII
    dec esi             ; Estamos salvando no buffer em ordem inversa
    mov [esi], dl       ; Salva o caractere já convertido no conteúdo do endereço apontado pelo esi
    test eax, eax       ; eax AND eax para testar se foi zerado    
    jnz .next_digit     ; Repeat until eax==0


    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 10
    int 80h

    mov eax, 1
    mov ebx, 0
    int 80h

    ; nasm -f elf -o nums.o nums.s && ld -m elf_i386 -o nums nums.o