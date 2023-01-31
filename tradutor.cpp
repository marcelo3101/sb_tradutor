#include <iostream>
#include <string.h>
#include <fstream>
#include <vector>
#include <sstream>
#include <unordered_map>
#include <ctype.h>

using namespace std;

void ifequ(string fname);
string ifequprocessing(string line);
vector<string> splitString(string input);
string removeComments(string input);

bool jump_line = false;  // Operador booleano usado no pré-processamento de IF
unordered_map<string, int> equ_table;

int main(int argc, char **argv)
{ // argv[0] é sempre o nome do programa
    if (argc != 2)
    {
        cout << "Número errado de argumentos" << endl;
    }
    else
    {
        cout << "Processamento de EQU e IF. Extensão de saída PRE" << endl;
        cout << endl;

        ifequ(argv[1]);

        cout << endl;
        cout << endl;
    }
    return 0;
}

// IF e EQU
string ifequprocessing(string line)  // Recebe a linha sem comentários, realiza o pré processamento e escreve no arquivo de saída
{
    // Split the line elements
    vector<string> tokens = splitString(line);
    int n_elements = tokens.size();
    string pre_line = "";

    // Checa jump_line em caso de IF 0
    if(jump_line)
    {
        if(tokens[0] != "IF")
        {
            jump_line = false;
        }
        return "";
    }
    else
    {
        // Verifica se o elemento é IF
        if (tokens[0] == "IF")
        {
            if(n_elements > 1)
            {
                // Verifica valor do rótulo definido anteriormente
                if(equ_table[tokens[1]] == 0)
                {
                    jump_line = true;  // Indica o pulo de linha para a próxima
                }
            }
            return "";
        }

        // Checa se tem definição de rótulo
        if (tokens[0].back() == ':' && n_elements > 1 && tokens[1] == "EQU")
        {
            if(n_elements == 3)
            {
                // Salva valor do rótulo definido pelo EQU
                equ_table[tokens[0].substr(0, tokens[0].length() - 1)] = stoi(tokens[2]);
                return "";
            }
            else
            {
                cout << "EQU incorreto" << endl;
                exit(1);
            }
        }

        for(int i = 0; i < n_elements; i++)
        {
            if(equ_table.find(tokens[i]) != equ_table.end())
            {
                tokens[i] = to_string(equ_table[tokens[i]]);
            }
            // Adicionar à string
            if(i == 0) pre_line += tokens[0];
            else pre_line += " " + tokens[i];
        }

        return pre_line;
    }

}

void ifequ(string fname)
{
    cout << "Pré-processamento para IF e EQU" << endl;
    string fname_asm = static_cast<string>(fname) + ".asm";

    ifstream file(fname_asm);  // Arquivo .asm de entrada
    string line_raw, file_line;

    ofstream outfile(static_cast<string>(fname) + ".pre");  // Arquivo .pre de saída com os comentários removidos e pré-processamento de IF e EQU

    while (getline(file, line_raw))
    {
        // separa a linha em rótulo, operação, operandos, comentários
        string line = removeComments(line_raw);
        if (line.find_first_not_of(" \t\n") != std::string::npos)
        {
            // Realiza pré-processamento da linha
            file_line = ifequprocessing(line);
            if(file_line != "")
            {
                //write to file
                outfile << file_line << endl;
            }
        }
    }
}

// Funções auxiliares

vector<string> splitString(string input)
{
    vector<string> tokens;
    // Split the string on spaces, commas, and semicolons
    string delimiters = " ,";
    size_t pos = input.find_first_of(delimiters);
    while (pos != string::npos)
    {
        // Add the token to the vector
        tokens.push_back(input.substr(0, pos));

        // Remove extra spaces, line breaks, tabs:
        while (input[pos + 1] == ' ' || input[pos + 1] == '\t' || input[pos + 1] == '\n')
        {
            input.erase(pos + 1, 1);
        }

        // Remove the token from the original string
        input.erase(0, pos + 1);
        // Find the next token
        pos = input.find_first_of(delimiters);
    }
    // Add the remaining string to the vector (if any)
    if (!input.empty())
    {
        tokens.push_back(input);
    }
    return tokens;
}

string removeComments(string input)
{
    string result;
    for (int i = 0; i < input.size(); i++)
    {
        if (input[i] == ';')
        {
            break;
        }
        else
        {
            result += toupper(input[i]);  // Já adiciona convertendo para maiúsculo. Feito para atender a especificação de não ser case sensitive
        }
    }
    return result;
}
