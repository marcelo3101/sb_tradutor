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
    ret 4
; -------------------------
;   Fim da função INPUT_C
; -------------------------

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
    ret 4
; --------------------------
;   Fim da função OUTPUT_C
; --------------------------

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
    ret 8
; -------------------------
;   Fim da função INPUT_S
; -------------------------

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
    ret 8
; --------------------------
;   Fim da função OUTPUT_S
; --------------------------

; -----------------------------------------------------------
;   Função para ler bytes em ASCII e converter para decimal
;                           INPUT
; -----------------------------------------------------------

input:
    enter 14, 0

    ; Leitura dos bytes ASCII
    mov eax, 3
    mov ebx, 0
    lea ecx, [ebp-17]
    mov edx, 12
    int 0x80

    mov edi, eax ; Salva quantidade de bytes lidos

    ; Conversão dos bytes ASCII para um número decimal
    mov byte [ebp-4], 0
    xor eax, eax ; eax inicializado como zero
    lea esi, [ebp-17] ; esi aponta para o endereço do primeiro byte da string lida
    mov ebx, 10 ; ebx igual a 10 para a multiplicação
    
    cmp byte [esi], 0x2D ; Compara se o primeiro caractere é o sinal negativo
    jne .loop ; if(*esi != '-')
    ; Caso for negativo retirar o sinal e marcar a variável local para o número ser multiplicado por -1 ao final
    inc esi
    mov byte [ebp-4], 1

.loop:
    movzx ecx, byte [esi] ; ecx recebe o caractere digitado, zerando o resto dos bits
    inc esi ; incrementa para a próxima iteração (Pilha cresce para baixo)
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
    mov ebx, [ebp+8] ; ebx recebe o endereço da label que está salvo na pilha
    mov [ebx], eax ; Salva o número no endereço da label recebida como parâmetro
    mov eax, edi ; Retorna no eax o número de bytes lidos
    
    leave
    ret 4  
; -----------------------
;   Fim da função INPUT
; -----------------------



; -------------------------------------------------------------------
;   Função para converter decimal em bytes ASCII e escrever na tela
;                               OUTPUT
; -------------------------------------------------------------------

output:
    enter 14, 0

    ; Checar se for negativo
    mov byte [ebp-4], 0
    mov eax, [ebp+8]
    cmp eax, 0
    jge int_to_string
    neg eax ; Transforma em positivo para a conversão
    mov byte [ebp-4], 1 ; Set na flag para saber que é negativo

    ;Converter novamente para ASCII
int_to_string:
    lea esi, [ebp-6]     ; esi aponta para o último endereço do buffer
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
.done:
    mov eax, 4
    mov ebx, 1
    mov ecx, esi ; esi vai apontar para o último byte adicionado, que nesse caso é o primeiro da string
    mov edx, 10
    int 80h

    leave
    ret 4
; ------------------------
;   Fim da função OUTPUT
; ------------------------