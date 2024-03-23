#include<iostream>
#include<string>
#include<vector>
#include<map>
#include<iomanip>
#include<bitset>
using namespace std;

int main()
{
    string type;
    vector<unsigned int> instruction;
    map<string,string> reg ={
        {"$0","00000"},
        {"$1","00001"},
        {"$2","00010"},
        {"$3","00011"},
        {"$4","00100"},
        {"$5","00101"},
        {"$6","00110"},
        {"$7","00111"},
        {"$8","01000"},
        {"$9","01001"},
        {"$10","01010"},
        {"$11","01011"},
        {"$12","01100"},
        {"$13","01101"},
        {"$14","01110"},
        {"$15","01111"},
        {"$16","10000"},
        {"$17","10001"},
        {"$18","10010"},
        {"$19","10011"},
        {"$20","10100"},
        {"$21","10101"},
        {"$22","10110"},
        {"$23","10111"},
        {"$24","11000"},
        {"$25","11001"},
        {"$26","11010"},
        {"$27","11011"},
        {"$28","11100"},
        {"$29","11101"},
        {"$30","11110"},
        {"$31","11111"}
    };
    map<string,string> function = {
        {"add","100000"},
        {"sub","100010"},
        {"and","100100"},
        {"or","100101"},
        {"slt","101010"},
    };
    map<string,string> op ={
        {"addi","001000"},
        {"subi","001001"},
        {"andi","001100"},
        {"ori","001101"},
        {"slti","001010"},
        {"lw","100011"},
        {"sw","101011"},
        {"beq","000100"},
        {"bne","000101"},
        {"j","000010"}
    };

    
    while(true)
    {
        cin>>type;
        if(type=="r")
        {
            string rd;
            string rs;
            string rt;
            string funct;            
            cin>>funct>>rd>>rs>>rt;
            string instruction = "000000"+reg[rs]+reg[rt]+reg[rd]+"00000"+function[funct];
            cout <<hex << setw(8) << setfill('0') << (unsigned int)stoi(instruction,nullptr,2) << endl;
        }  
        else if(type=="i")
        {
            string optype;
            string rs;
            string rt;
            string imm;
            cin>>optype>>rt>>rs>>imm;
            string instruction = op[optype]+reg[rs]+reg[rt]+bitset<16>(stoi(imm)).to_string();
            cout <<hex << setw(8) << setfill('0') << (unsigned int)stoul(instruction,nullptr,2) << endl;
        }
        else if(type=="j")
        {
            string j;
            string jaddr;
            
            cin>>j>>jaddr;
            string instruction = op[j]+bitset<26>(stoi(jaddr)).to_string();
            cout <<hex << setw(8) << setfill('0') << (unsigned int)stoul(instruction,nullptr,2) << endl;
        }
        else if(type=="end")
        {
            break;
        }

    }  
}