section .data
msg db 'Digite o número decimal de até 10 dígitos: '
MSG_SIZE EQU $-msg
valor dd 0
section .bss
input_text resb 12 ; Número pode ter até 10 dígitos, considerando o possível '-' e enter
buffer resb 12 ; String resultado da conversão de int para ASCII

section .text
global _start
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, MSG_SIZE
    int 80h
    push input_text ; Empilha o endereço do primeiro byte, parâmetro para a função INPUT
    call input 
    ;push buffer
    ;call output
    ;add eax, 10
    push buffer ; Empilha o endereço do primeiro byte do buffer de saída
    call output

    mov eax, 1
    mov ebx, 0
    int 80h



; -----------------------------------------------------------
;   Função para ler bytes em ASCII e converter para decimal
;                           INPUT
; -----------------------------------------------------------

input:
    enter 2, 0

    ; Leitura dos bytes ASCII
    mov eax, 3
    mov ebx, 0
    mov ecx, [ebp+8]
    mov edx, 10
    int 80h

    mov edi, eax ; Salva quantidade de bytes lidos

    ; Conversão dos bytes ASCII para um número decimal
    mov byte [ebp-4], 0
    xor eax, eax ; eax inicializado como zero
    mov esi, [ebp+8] ; esi aponta para o endereço recebido como parâmetro
    mov ebx, 10 ; ebx igual a 10 para a multiplicação
    
    cmp byte [esi], 0x2D ; Compara se o primeiro caractere é o sinal negativo
    jne .loop ; if(*esi != '-')
    ; Caso for negativo retirar o sinal e marcar a variável local para o número ser multiplicado por -1 ao final
    inc esi
    mov byte [ebp-4], 1

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
    cmp byte [ebp-4], 1
    jne no_mult
    neg eax
no_mult:
    mov ebx, edi ; ebx contém o número de bytes lidos
    leave
    ret 4
    

; -------------------------------------------------------------------
;   Função para converter decimal em bytes ASCII e escrever na tela
;                               OUTPUT
; -------------------------------------------------------------------

output:
    enter 2, 0

    ; Checar se for negativo
    mov byte [ebp-4], 0
    cmp eax, 0
    jge int_to_string
    neg eax ; Transforma em positivo para a conversão
    mov byte [ebp-4], 1 ; Set na flag para saber que é negativo

    ;Converter novamente para ASCII
int_to_string:
    mov esi, buffer     ; esi aponta para o primeiro byte de buffer
    add esi, 10          ; Vai para o último endereço do buffer
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

    cmp byte [ebp-4], 1
    jne .done
    dec esi
    mov byte [esi], 0x2D
    neg eax
    sbb eax, 0
    mov ebx, eax
.done:
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 10
    int 80h

    leave
    ret 4


    ; nasm -f elf -o nums.o nums.s && ld -m elf_i386 -o nums nums.o