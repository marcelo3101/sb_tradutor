#include <iostream>
#include <string.h>
#include <fstream>
#include <vector>
#include <sstream>
#include <unordered_map>
#include <ctype.h>

using namespace std;

void translate(vector<string> pre_processed, string filename);
vector<string> ifequ(string fname);
string ifequprocessing(string line);
vector<string> splitString(string input);
string removeComments(string input);
vector<string> splitPreProcessed(string line);

enum Section{
    DATA,
    TEXT,
};

Section section = TEXT;
string stext, sdata, sbss;

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
        translate(ifequ(argv[1]), argv[1]);  // Função translate recebe o array de strings retornado pela função ifequ
    }
    return 0;
}

/*
    Tradução para Assembly IA-32
*/
void translate(vector<string> pre_processed, string filename)
{
    cout << endl;
    cout << "Início da tradução" << endl;
    cout << endl;
    vector<string> translated;
    string translated_line = "";
    unordered_map<string, string> translations = {
        {"ADD", "add dword eax, [$arg1$]"},
        {"SUB", "sub dword eax, [$arg1$]"},
        {"MUL", "mov dword ebx, [$arg1$]\nimul ebx"},
        {"MULT", "mov dword ebx, [$arg1$]\nimul ebx"},
        {"DIV", "mov dword ebx, [$arg1$]\nidiv ebx"},
        {"JMP", "jmp $arg1$"},
        {"JMPN", "cmp eax, 0\njl $arg1$"},
        {"JMPP", "cmp eax, 0\njg $arg1$"},
        {"JMPZ", "cmp eax, 0\nje $arg1$"},
        {"COPY", "mov dword ecx, [$arg2$]\nmov dword [$arg1$], ecx"},
        {"LOAD", "mov dword eax, [$arg1$]"},
        {"STORE", "mov dword [$arg1$], eax"},
        {"INPUT", "push $arg1$\ncall input"},
        {"OUTPUT", "push dword [$arg1$]\ncall output"},
        {"INPUT_C", "push $arg1$\ncall input_c"},
        {"OUTPUT_C", "push $arg1$\ncall output_c"},
        {"INPUT_S", "push $arg1$\npush $arg2$\ncall input_s"},
        {"OUTPUT_S", "push $arg1$\npush $arg2$\ncall output_s"},
        {"STOP", "mov eax, 1\nmov ebx, 0\nint 80h\n"}
    };

    // Parte inicial de cada section
    sdata = "section .data\n";
    sbss = "section .bss\n";
    stext = "section .text\nglobal _start\n_start:\n";

    for(int i = 0; i < pre_processed.size(); i++)
    {
        translated = splitPreProcessed(pre_processed[i]);   // [rot, inst, arg1], [rot, inst, arg1, arg2], [inst, arg1]
        if(translated[0].back() == ':')
        {
            if (section == DATA) translated[0].pop_back(); // Remove o : se o rotulo for de um elemento de dados
            translated_line += translated[0]+ " ";
            translated.erase(translated.begin());  // Remove rótulo para o tratamento dos demais itens 
        }
        if (translated[0] == "SECTION"){
            if (translated[1] == "DATA") section = DATA;
        }
        else
        {
            switch (section)
            {
                case DATA:
                    if (translated[0] == "SPACE"){
                        translated_line.append("resd ");
                        if (translated.size() > 1){
                            translated_line.append(translated[1]);
                        }
                        else translated_line.append("1");
                        sbss.append(translated_line + "\n");
                    }

                    else if (translated[0] == "CONST"){
                        if (translated[1].find("'") != std::string::npos) {
                            translated_line.append("db " + translated[1]);
                        } else {
                            translated_line.append("dd " + translated[1]);
                        }
                        sdata.append(translated_line + "\n");
                    }
                    break;
                
                case TEXT:
                    auto translation = translations.at(translated[0]);
                    if (translated.size() == 1) {
                        stext.append(translated_line + translation);
                    }
                    else
                    {
                        stringstream ss(translation);
                        string line;

                        int i = 1;
                        while (std::getline(ss, line, '\n')) {
                            auto pos = line.find("$arg1$");
                            if (pos != std::string::npos) {
                                if (translated[1].find("+") != string::npos)
                                {
                                    translated[1].append("*4");
                                }
                                line.replace(pos, 6, translated[1]);
                            }

                            pos = line.find("$arg2$");
                            if (pos != std::string::npos && translated.size() >= 3) {
                                if (translated[2].find("+") != string::npos)
                                {
                                    translated[2].append("*4");
                                }
                                line.replace(pos, 6, translated[2]);
                            }

                            translated_line += line + '\n';
                        }
                        stext.append(translated_line);
                    }
            }

        }
        translated_line.clear();
    }

        /* cout << ".data\n";
        cout << sdata;

        cout << ".bss\n";
        cout << sbss;

        cout << ".text\n";
        cout << stext; */

        cout << "Gerando arquivo final" << endl;
        ofstream outfile(static_cast<string>(filename) + ".s");
        
        // inserir funções assembly na seção text
        ifstream functions_file("inputs_outputs.s");  // Arquivo .asm de entrada
        string line;
        while (getline(functions_file, line))
        {
            stext.append(line);
            stext += "\n";
        }
        
        // Inserir traduções
        outfile << sdata;
        outfile << sbss;
        outfile << stext;
        cout << "Arquivo .s gerado" << endl;
        outfile.close();


    
}

vector<string> splitPreProcessed(string line)
{
    vector<string> elements;
    stringstream ss(line);

    string temp;
    while (ss >> temp) {
        elements.push_back(temp);
    }
    return elements;
}

/*
    Pré-processamento de IF e EQU
*/

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

vector<string> ifequ(string fname)
{
    string fname_asm = static_cast<string>(fname) + ".asm";

    ifstream file(fname_asm);  // Arquivo .asm de entrada
    string line_raw, file_line;

    // ofstream outfile(static_cast<string>(fname) + ".pre");  // Arquivo .pre de saída com os comentários removidos e pré-processamento de IF e EQU
    vector<string> pre_processed;
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
                pre_processed.push_back(file_line);
            }
        }
    }
    cout << "Pré-processamento para IF e EQU realizado" << endl;
    file.close();
    return pre_processed;
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
