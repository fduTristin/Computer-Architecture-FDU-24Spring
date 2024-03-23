#include<fstream>
#include<iostream>
#include<string>
#include<vector>
#include<map>
#include<cstring>
#include<cmath>
#include<cstdlib>
#include <random>
#include <time.h>

using namespace std;

default_random_engine r(time(NULL));

// Cache 设置 在读取配置文件的时候初始化
struct cacheconfig{
    int cacheSize;
    int blockSize;
    int associativity;
    int writePolicy; // 0 写回 1 写直达
    int MissCost;
    int replacePolicy;
} CacheConfig;



// 全局变量 用于统计访存情况
long TotalTime = 0;
int TotalloadHit = 0;
int Totalload = 0;
int TotalstoreHit = 0;
int Totalstore = 0;

void DirectRead(int CO, int CI, long addr, map<long,long> &cache){
    TotalTime += 1;
    Totalload++;
    int cacheIndex = (addr >> CO) % (1<<CI);
    if(cache.find(cacheIndex)==cache.end() || cache[cacheIndex] != addr>>(CO + CI))
    {
        TotalTime+=CacheConfig.MissCost;
        cache[cacheIndex]=(addr>>(CO + CI));
    }else{
        // cout<<"命中"<<endl;
        TotalloadHit++;
    }
};

void DirectWrite(int CO, int CI, long addr, map<long,long> &cache){
    TotalTime += 1;
    // 写入内存开销
    TotalTime += CacheConfig.MissCost;
    Totalstore++;
    int cacheIndex = (addr >> CO) % (1<<CI);
    if(cache.find(cacheIndex)==cache.end() || cache[cacheIndex] != addr>>(CO + CI))
    {
        
        if(CacheConfig.writePolicy == 0)
        {
            TotalTime += CacheConfig.MissCost;
            cache[cacheIndex]=(addr>>(CO + CI));
        }

    }else{
        // cout<<"命中"<<endl;
        TotalstoreHit++;
    }
};

void LRU(vector<vector<long>> &slot, long newTag)
{
    long len = slot.size();
    long newTagIndex = -1;
    for(long i = 0; i < len; i++)
    {
        if(slot[i][1] == len - 1)
        {
            slot[i][0] = newTag;
            slot[i][1] = 0;
            newTagIndex = i;
            break;
        }
    }
    for(long i = 0; i < len; i++)
    {
        if(i != newTagIndex)
        slot[i][1] ++;
    }
    // cout<<"newTagIndex: "<<newTagIndex<<endl;
    // slot[newTagIndex][1] = 0;
}

void FullRead(int CO, long SlotLen, long addr, vector<vector<long>> &cache){

    int CT = 48 - CO;
    TotalTime++;
    Totalload++;
    int count = -1; 
    long position = 0;
    for (int i = 0; i < cache.size(); i++)
    {
        if(cache[i][0] == addr >> CO)
        {
            count = cache[i][1];
            position = i;
            TotalloadHit++;
            break;
        }
    }

    // 命中
    if(count != -1)
    {
        for (int i = 0; i<cache.size(); ++i){
            if(cache[i][1]<count)
            cache[i][1] = cache[i][1] + 1;
        }
        cache[position][1] = 0;
        return;
    }
    // 未命中
    TotalTime+=CacheConfig.MissCost;

    if(cache.size() != SlotLen)
    {
        // 未满 直接加入
        for(int i = 0; i<cache.size(); ++i)
        cache[i][1] = cache[i][1] + 1;
        cache.push_back({addr >> CO,0});
        return;
    }
    else{
        // 已满 替换
        if(CacheConfig.replacePolicy == 0)
        {
            // 随机替换
            uniform_int_distribution<long> dis1(0, SlotLen-1);
            cache[dis1(r)] = {addr >> CO,0};
        }
        else 
        {
            // LRU替换
            LRU(cache,addr >> CO);
        }
    }
}

void FullWrite(int CO, long SlotLen, long addr, vector<vector<long>> &cache)
{
    
    Totalstore++;
    TotalTime++;
    TotalTime += CacheConfig.MissCost;

    int CT = 48 - CO;

    int count = -1;
    for (int i = 0;i < cache.size();i++){
        if(cache[i][0] == addr >> CO){
            count = cache[i][1];
            cache[i][1] = 0;
            break;}}
    if(count != -1){
        TotalstoreHit++;
        for (int i = 0;i<cache.size();i++){
            if(cache[i][1]<count)
                cache[i][1] = cache[i][1] + 1;
        }
        return;
    }
    if(CacheConfig.writePolicy == 0)
    {
        // 写分配
        TotalTime+=CacheConfig.MissCost;

         if(cache.size() != SlotLen)
         {
            for(int i = 0; i<cache.size(); ++i)
            cache[i][1] = cache[i][1] + 1;
            cache.push_back({addr >> CO,0});
            return;
         }
         else
         {
            if(CacheConfig.replacePolicy == 0)
            {
                // 随机替换
                uniform_int_distribution<long> dis1(0, SlotLen-1);
                cache[dis1(r)] = {addr >> CO,0};
            }
            else if(CacheConfig.replacePolicy == 1)
            {
                // LRU替换
                LRU(cache,addr >> CO);
            }
         }
    }
}

void SetRead(int CO, int SetIndex, long addr, map<long,vector<vector<long>>> &cache)
{
    // cout<<"SetIndex: "<<SetIndex<<endl;
    // cout<<"CO: "<<CO<<endl;
    // cout<<"addr: "<<hex<<addr<<endl;
    int CT = 48 - CO - SetIndex;
    int count = -1;
    int position = 0;
    TotalTime++;
    Totalload++;
    // 取tag位
    long tag = addr >> (CO + SetIndex);
    // cout<<"tag:"<<hex<<tag<<endl;
    long index = ( addr >> CO ) % (1 << SetIndex);
    // cout<<"index:"<<index<<endl;

    // cout<<"Cache: " <<endl;
    // for(auto it = cache.begin(); it != cache.end(); it++)
    // {
    //     cout<<it -> first<<": ";
    //     for(int i = 0; i < it->second.size(); i++)
    //     {
    //         cout<<"("<<it->second[i][0]<<","<<it->second[i][1]<<") ";
    //     }
    //     cout<<endl;
    // }

    if( cache.find(index) != cache.end())
    {
        // 有该组
        // cout<<"有该组"<<endl;
        for(int i = 0; i < cache[index].size(); i++)
        {
            if(cache[index][i][0] == tag)
            {
                count = cache[index][i][1];
                position = i;
                break;
            }
        }
        if(count != -1)
        {
            // cout<<"hit"<<endl;
            TotalloadHit++;
            for (int i = 0; i<cache[index].size(); ++i){
                if(cache[index][i][1]<count)
                cache[index][i][1] = cache[index][i][1] + 1;
            }
            cache[index][position][1] = 0;
            return;
        }
        // 未找到。有该组但是未找到
        TotalTime += CacheConfig.MissCost;
        // cout<<"未找到"<<TotalTime<<endl;
        if(cache[index].size() != CacheConfig.associativity)
        {
            // 该组cache未满 直接加入
            for(int i = 0; i<cache[index].size(); ++i)
            cache[index][i][1] = cache[index][i][1] + 1;
            cache[index].push_back({tag,0});
            return;
        }
        else{
            // 已满 替换
            if(CacheConfig.replacePolicy == 0)
            {
                // 随机替换
                uniform_int_distribution<long> dis1(0, CacheConfig.associativity-1);
                cache[index][dis1(r)] = {tag,0};
            }
            else if(CacheConfig.replacePolicy == 1)
            {
                // LRU替换
                LRU(cache[index],tag);
            }
        }
    }
    else
    {
        // cout<<"miss"<<endl;
        // 未找到该组
        TotalTime += CacheConfig.MissCost;
        // cout<<"未找到"<<TotalTime<<endl;

        vector<vector<long>> temp;
        temp.push_back({tag,0});
        cache[index] = temp;
    }
}

void SetWrite(int CO, int SetIndex, long addr, map<long,vector<vector<long>>> &cache)
{
    Totalstore++;
    TotalTime++;
    TotalTime += CacheConfig.MissCost;

    int CT = 48 - CO - SetIndex;
    int count = -1;
    // 取tag位
     long tag = addr >> (CO + SetIndex);
    int index = ( addr >> CO ) % (1 << SetIndex);
    // cout<<"index:"<<index<<endl;
    if( cache.find(index) != cache.end())
    {
        for(int i = 0; i < cache[index].size(); i++)
        {
            if(cache[index][i][0] == tag)
            {
                count = cache[index][i][1];
                cache[index][i][1] = 0;
                break;
            }
        }
        if(count != -1)
        {
            // cout<<"hit"<<endl;
            TotalstoreHit++;
            for (int i = 0; i<cache[index].size(); ++i)
            {
                if(cache[index][i][1] < count)
                cache[index][i][1] = cache[index][i][1] + 1;
            }
            return;
        }
        // 未找到。有该组但是未找到
        if(CacheConfig.writePolicy == 0)
        {
            // 写分配
            TotalTime+=CacheConfig.MissCost;

            if(cache[index].size() != CacheConfig.associativity)
            {
                // 该组cache未满 直接加入
                for(int i = 0; i<cache[index].size(); ++i)
                cache[index][i][1] = cache[index][i][1] + 1;
                cache[index].push_back({tag,0});
                return;
            }
            else{
                // 已满 替换
                if(CacheConfig.replacePolicy == 0)
                {
                    // 随机替换
                    uniform_int_distribution<long> dis1(0, CacheConfig.associativity-1);
                    cache[index][dis1(r)] = {tag,0};
                }
                else if(CacheConfig.replacePolicy == 1)
                {
                    // LRU替换
                    LRU(cache[index],tag);
                }
            }
        }
    }
    else
    {
        // 未找到该组
        if(CacheConfig.writePolicy == 0){
            TotalTime += CacheConfig.MissCost;
            vector<vector<long>> temp;
            temp.push_back({tag,0});
            cache[index] = temp;
        }
    }

}

void DiretedMap(ifstream& trace){
    // 读指令
    map<long,long> icache;
    // 读数据
    map<long,long> dcache;
 
        int CO = (int)log2(CacheConfig.blockSize);
        int CI = (int)log2(CacheConfig.cacheSize/CacheConfig.blockSize) + 10;
        int CT = 48 - CO - CI;

        // cout<<"CO:"<<CO<<endl;
        // cout<<"CI:"<<CI<<endl;
        // cout<<"CT:"<<CT<<endl;
        // 读取trace文件
        string instrAddr;
        string instrType;
        string dataAddr;
        // 读入 处理
        while(trace >> instrAddr >> instrType >> dataAddr){
            
            long ins = strtol( instrAddr.substr(0,14).c_str(),nullptr,16);
            long data = strtol( dataAddr.c_str(),nullptr,16);
            // cout<<"指令地址: "<<instrAddr.substr(0,14)<<" "<<hex<<ins<<endl;
            // cout<<"指令类型: "<<instrType<<endl;
            // cout<<"数据地址: "<<dataAddr<<endl;

            // 首先处理ins 一定是读
            // cout<<"处理instr: "<<hex<<ins<<endl;
            int cacheIndex = (ins >> CO) % (1<<CI);
            // cout<<"cacheIndex: "<<hex<<cacheIndex<<endl;
            DirectRead(CO,CI,ins,icache);
            
            // cout<<"处理data: "<<hex<<data<<endl;
            if(instrType == "R"){
                // 读取data
                DirectRead(CO,CI,data,dcache);
            }
            if(instrType == "W"){
                // 写入data
                DirectWrite(CO,CI,data,dcache);
            }
        }
}

void FullAssociative(ifstream& trace){
    // 槽数 
    vector<vector<long>> icache;
    vector<vector<long>> dcache;

    
    string instrAddr;
    string instrType;
    string dataAddr;
    
        int CO = log2(CacheConfig.blockSize);
        long SlotLen = CacheConfig.cacheSize/CacheConfig.blockSize<<10;

        while(trace >> instrAddr >> instrType >> dataAddr){
            long ins = strtol(instrAddr.substr(0,14).c_str(),nullptr,16);
            long data = strtol( dataAddr.c_str(),nullptr,16);
            // cout<<"指令地址: "<<instrAddr.substr(0,14)<<" "<<hex<<ins<<endl;
            // cout<<"指令类型: "<<instrType<<endl;
            // cout<<"数据地址: "<<dataAddr<<endl;

            // 首先处理ins 一定是读
            // cout<<"处理instr: "<<hex<<ins<<endl;
        
            FullRead(CO,SlotLen,ins,icache);
            // readCache(CO,CI,ins,cache,TotalTime,TotalloadHit,Totalload);
            // cout<<"处理data: "<<hex<<data<<endl;
            if(instrType == "R")
            {
                // 读取data
                FullRead(CO,SlotLen,data,dcache);
            }
            if(instrType == "W")
            {
                FullWrite(CO,SlotLen,data,dcache);
            }
        }}
  
void SetAssociative(ifstream& trace){

    map<long,vector<vector<long>>> icache;
    map<long,vector<vector<long>>> dcache;
    
    string instrAddr;
    string instrType;
    string dataAddr;
    
        int CO = log2(CacheConfig.blockSize);
        // cout<<"CO:"<<CO<<endl;
        // int temp = ((CacheConfig.cacheSize/CacheConfig.blockSize)<<10)/CacheConfig.associativity;
        // cout << "temp:" << temp << endl;
       
        int SetIndex = (int)log2(((CacheConfig.cacheSize/CacheConfig.blockSize)<<10)/CacheConfig.associativity);
        // cout<<"SetIndex:"<<SetIndex<<endl;

        while(trace >> instrAddr >> instrType >> dataAddr){
            long ins = strtol(instrAddr.substr(0,14).c_str(),nullptr,16);
            long data = strtol( dataAddr.c_str(),nullptr,16);
            // cout<<"指令地址: "<<instrAddr.substr(0,14)<<" "<<hex<<ins<<endl;
            // cout<<"指令类型: "<<instrType<<endl;
            // cout<<"数据地址: "<<dataAddr<<endl;

            // 首先处理ins 一定是读
            // cout<<"处理instr: "<<hex<<ins<<endl;
        
            // FullRead(CO,ins,icache);
            SetRead(CO,SetIndex,ins,icache);
            // readCache(CO,CI,ins,cache,TotalTime,TotalloadHit,Totalload);
            // cout<<"处理data: "<<hex<<data<<endl;
            if(instrType == "R"){
                // 读取data
                // SetRead(CO,SetIndex,data,dcache);
            SetRead(CO,SetIndex,data,dcache);
            }
            if(instrType == "W"){
                SetWrite(CO,SetIndex,data,dcache);
            }
        }}

bool readConfig(ifstream& config){
    // cout<<"读取配置文件"<<endl;
    vector<string> line(6,"");
    for(int i=0;i<6;i++){
    getline(config,line[i]);}
    
    CacheConfig.blockSize=stoi(line[0]);
    
    CacheConfig.associativity=stoi(line[1]);
    // if(log2(CacheConfig.associativity)!=(int)log2(CacheConfig.associativity))
    //     return false;
    
    CacheConfig.cacheSize=stoi(line[2]);
    
    CacheConfig.replacePolicy=stoi(line[3]);
    if(CacheConfig.replacePolicy!=0&&CacheConfig.replacePolicy!=1)
        return false;
    
    CacheConfig.MissCost=stoi(line[4]);
    
    CacheConfig.writePolicy=stoi(line[5]);

    if(CacheConfig.writePolicy!=0&&CacheConfig.writePolicy!=1)
        return false;
    return true;
}

int main(int argc, char *argv[]){
    char* configFile=nullptr;
    char* traceFile=nullptr;
    char* outputFile=nullptr;

  for (int i = 1; i < argc; i+=2)
	{
        if(strcmp(argv[i],"-c")==0){
           configFile = argv[i+1];
        }
        else if(strcmp(argv[i],"-t")==0){
            traceFile = argv[i+1];
        }
        else if(strcmp(argv[i],"-o")==0){
            outputFile = argv[i+1];
        }
	}
    
    if(configFile==nullptr||traceFile==nullptr){
        cout << "参数不全，无法模拟！"<<endl;
        return 0;
    }

        ifstream config(configFile);
        if (!config.is_open())
        {
            cout << "配置文件打开失败！" << endl;
            return 0;
        }
        if(!readConfig(config))
        {
            cout << "配置文件读取失败" << endl;
            return 0;
        }        
        
        ifstream trace(traceFile);
        if(CacheConfig.associativity==1){
            DiretedMap(trace);
        }
        else if(CacheConfig.associativity==0){
            // cout<<"全相联映射"<<endl;
            FullAssociative(trace);
        }
        else{
            // cout<<"组相联映射"<<endl;
            SetAssociative(trace);
        }
        
        float TotalHitRate = 100 * (float)(TotalloadHit+TotalstoreHit)/(Totalload+Totalstore);
        float LoadHitRate =  100 * (float)TotalloadHit/Totalload;
        float StoreHitRate = Totalstore == 0 ? 0 : 100 * (float)TotalstoreHit/Totalstore;
        float AVGTime = (float)TotalTime/(Totalload+Totalstore);

        if(outputFile != nullptr)
        {
            ofstream output(outputFile);
            output<<"Total Hit Rate: "<<TotalHitRate<<'%'<<endl;
            output<<"Load Hit Rate: "<<LoadHitRate<<'%'<<endl;
            output<<"Store Hit Rate: "<<StoreHitRate<<'%'<<endl;
            output<<"Total Run Time: "<<TotalTime<<endl;
            output<<"AVG MA Latency: "<<AVGTime<<endl;
        }
        else 
        {
            cout<<"Total Hit Rate: "<<TotalHitRate<<'%'<<endl;
            cout<<"Load Hit Rate: "<<LoadHitRate<<'%'<<endl;
            cout<<"Store Hit Rate: "<<StoreHitRate<<'%'<<endl;
            cout<<"Total Run Time: "<<TotalTime<<endl;                cout<<"AVG MA Latency: "<<AVGTime<<endl;
        }
            // cout<<"Totalload: "<<Totalload<<endl;
            // cout<<"TotalloadHit: "<<TotalloadHit<<endl;
            // cout<<"Totalstore: "<<Totalstore<<endl;
            // cout<<"TotalstoreHit: "<<TotalstoreHit<<endl;
    return 0;
}

