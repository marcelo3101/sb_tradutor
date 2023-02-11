# sb_tradutor
Repositório para o trabalho 2 da disciplina de Software Básico da UnB do semestre 2022.2

## Integrantes
**Marcelo Aiache Postiglione - 180126652**

**Nome - Matrícula**

## Sistema operacional utilizado
Kali GNU/Linux Rolling          
Kernel: Linux 5.17.0-kali3-amd64

## Versão do C++
**C++17**

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

## Link para o repositório

https://github.com/marcelo3101/sb-tradutor
