#include<iostream>
#include<string>
#include<iomanip>
using namespace std;



int main(){
    string type;
    string op;
    string rd;
    string rs;
    string rt;
    string shamt="00000";
    string funct;
    
    cout<<"Enter the op code:"<<endl;
    cin>>op;
    cout<<"Enter the rs code:"<<endl;
    cin>>rs;
    cout<<"Enter the rt code:"<<endl;
    cin>>rt;
    cout<<"Enter the rd code:"<<endl;
    cin>>rd;
    // cout<<"Enter the shamt code:"<<endl;
    // cin>>shamt.s;
    cout<<"Enter the funct code:"<<endl;
    cin>>funct;
    string instruction;
    instruction=op+rs+rt+rd+shamt+funct;
    cout<<instruction<<endl;
    unsigned long i=(unsigned long)stoi(instruction,nullptr,2);
    cout <<hex << setw(8) << setfill('0') << i << endl;
    return 0;
     
}