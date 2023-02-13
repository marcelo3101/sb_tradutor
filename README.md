# sb_tradutor
Repositório para o trabalho 2 da disciplina de Software Básico da UnB do semestre 2022.2

## Integrantes
**Marcelo Aiache Postiglione - 180126652**

**João Pedro de Sousa Soares Martins - 200020692**

## Sistema operacional utilizado
Kali GNU/Linux Rolling          
Kernel: Linux 5.17.0-kali3-amd64

## Versão do C++
**C++17**

## Versão do NASM usado nos testes
NASM version 2.15.05

## Versão do LD usado nos testes
GNU ld (GNU Binutils for Debian) 2.39

## Instruções de compilação
```
$ gcc tradutor.cpp -lstdc++ -o tradutor 
```

## Rodando o programa
O programa recebe como argumento apenas o nome de um arquivo de extensão .asm, mas sem a extensão. Por exemplo, para executar a tradução para um arquivo chamado "exemplo.asm" que esteja presente no mesmo diretório de onde está sendo chamado o programa tradutor, digite o seguinte comando:

```
$ ./tradutor exemplo
```

O programa irá gerar um arquivo com mesmo nome só que com a extensão ".s". Para este exemplo o arquivo de saída gerado vai ser "exemplo.s".

### Funções escritas em assembly

Todas as funções de input e output (char,string e números) foram escritas de antemão em assembly IA-32 NASM e estão no arquivo **inputs_outputs.s**. O seu conteúdo é copiado para o final da seção de texto no arquivo traduzido e assim as funções podem ser chamadas.

Também existem arquivos com estrutura para testar os três tipos de input e output de forma separada. Para INPUT_C e OUTPUT_C, o arquivo char.s pode ser utilizado. Para INPUT_S e OUTPUT_S, o arquivo string.s pode ser utilizado. Para INPUT e OUTPUT, o arquivo nums.s pode ser utilizado.

## Link para o repositório

https://github.com/marcelo3101/sb-tradutor