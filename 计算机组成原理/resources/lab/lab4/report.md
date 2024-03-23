# 实验四：构建Cache模拟器

[TOC]

## 1 实验目的

- 完成cache模拟器
- 理解cache块大小对cache性能的影响
- 理解cache关联性对cache性能的影响
- 理解cache总大小对cache性能的影响
- 理解cache替换策略对cache性能的影响
- 理解cache写回策略对cache性能的影响

## 2 实验过程

### 设计过程

#### 总体思路

##### 全局变量

对于公共的信息，比如cache配置和命中信息，设为公共变量。创建结构体cacheconfig，并实例化一个全局变量CacheConfig，在读入配置时给该变量赋值，其他过程中可以直接调用

```cpp
struct cacheconfig{
	int cacheSize;
    int blockSize;
    int associativity;
    int writePolicy; // 0写回 1写直达
    int MissCost;
    int replacePolicy;
} CacheConfig;
```

全局变量 用于统计访存情况

```cpp
long TotalTime = 0;
int TotalloadHit = 0;
int Totalload = 0;
int TotalstoreHit = 0;
int Totalstore = 0;
```

##### 程序框架

整个程序的框架为：

![image-20240131234138264](E:\courses\Second\cs\coa\lab - 副本\lab4\assets\image-20240131234138264.png)

对应函数:

![image-20230531085845250](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230531085845250.png)a

在主函数`main`中处理命令行，若参数不足直接返回，实例化文本流对象，先调用`readConfig`配置Cache，再按照关联度调用各个函数，参数是追踪文件trace

##### 数据结构

对不同的关联性，定义cache的数据结构不同，特别说明：

1. 因为本实验情境是48位地址，且CT CI的位数不确定，可能超过int的范围，所以都设为long，避免溢出
2. 对写入内存，不论写回还是写直达，写内存的时间开销是一样的，只是不命中时cache的状态可能有差异。所以只需要每次写都加上写内存的时间（假定同缓存不命中的惩罚时间），不用设置脏位。
3. 由于需要读取指令和数据，所以要设置至少两个cache，一个缓存指令，一个缓存数据。



- 直接映射

  - 不考虑替换策略 所以不设置计数位
  
  因cache块数可能很多，如果用数组存储开销很大，而且如果很多行为空，会浪费很多空间，所以用map存储，既节省空间，又达到映射的目的
  
  `map<long>`
  
  `map[CI] = tag`
  
- 全相联

  - 用数组存储
  
  - 要考虑替换策略和写策略
  
    `vector<vector<long>(2,0)>`
  
    ``{{tag,count}}` (count 是LRU计数位)
  
- 组相联
  
  - 那么前面是map 后面是数组
  
  - 要考虑替换策略和写策略
  
    `map<long,vector<vector<long>(2,0)>>`
  
    `map[setIndex] = {{tag,count}}`
  

#### 函数实现

##### main

读入命令行参数

```cpp
char* configFile=nullptr;
char* traceFile=nullptr;
char* outputFile=nullptr;

for (int i = 1; i < argc; i+=2)
{
    if(strcmp(argv[i],"-c")==0)
    {
        configFile = argv[i+1];
    }
    else if(strcmp(argv[i],"-t")==0)
    {
        traceFile = argv[i+1];
    }
    else if(strcmp(argv[i],"-o")==0)
    {
        outputFile = argv[i+1];
    }
}
```

检查必要参数

```cpp
if(configFile==nullptr||traceFile==nullptr)
{
    cout << "参数不全，无法模拟！"<<endl;
    return 0;
}
```

接下来读配置，根据关联度调用不同函数

```cpp
ifstream config(configFile);
if (!config.is_open()){
    cout << "配置文件打开失败！" << endl;
    return 0;
}
if(!readConfig(config))
{
    cout << "配置文件读取失败" << endl;
	return 0;
}
ifstream trace(traceFile);
if(CacheConfig.associativity==1)
{
    DiretedMap(trace);
}
else if(CacheConfig.associativity==0)
{
    FullAssociative(trace);
}
else
{
    SetAssociative(trace);
}
```

输出结果

```cpp
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
    cout<<"Total Run Time: "<<TotalTime<<endl;
	cout<<"AVG MA Latency: "<<AVGTime<<endl;
}
```

##### 读入配置

检查错误

对替换政策和写入政策，检查值是否是非1即0，若有其他值，直接return false

```cpp
CacheConfig.replacePolicy=stoi(line[3]);
    if(CacheConfig.replacePolicy != 0 && CacheConfig.replacePolicy != 1)
        return false;
```

##### 直接映射

在while循环中读入`instrAddr`,`instrType`,和`dataAddr` ，转为long型整数后开始读写，指令一定读，数据读写根据`instrType`的值决定

其余两种关联度的程序也都按如下格式安排。

```cpp
while(trace >> instrAddr >> instrType >> dataAddr)
{
    long ins = strtol( instrAddr.substr(0,14).c_str(),nullptr,16);
	long data = strtol( dataAddr.c_str(),nullptr,16);
    
    DirectRead(CO,CI,ins,icache);
    if(instrType == "R")
    {
        DirectRead(CO,CI,data,dcache);
    }
    else
    {
        DirectWrite(CO,CI,data,dcache);
    }
}
```

###### DirectRead

若cache中有该index，且tag值相同，则命中。否则不命中，替换。

```cpp
if(cache.find(cacheIndex) == cache.end() || cache[cacheIndex] != addr>>(CO + CI))
    {
        TotalTime += CacheConfig.MissCost;
        cache[cacheIndex] = (addr >> (CO + CI));
    }
	else
    {
        TotalloadHit ++;
    }
```

###### DirectWrite

若命中，计数+1

若不命中且写分配，替换。

```cpp
if(cache.find(cacheIndex)==cache.end() || cache[cacheIndex] != addr>>(CO + CI))
{
    if(CacheConfig.writePolicy == 0)
    {
        TotalTime += CacheConfig.MissCost;
        cache[cacheIndex]=(addr>>(CO + CI));
    }
}
else
{
    TotalstoreHit++;
}
```

##### 全相联

###### FullRead

采取的策略是不论是否按LRU替换，都按照LRU的算法调整计数位。

遍历cache，看存储的是否与tag一致的，若有，记住计数位的值，讲计数位低于它的都加1，该位置计数位置为0。

若未命中：cache未满的时候直接加入，所有计数位+1，新加入的计数位为0

若未命中且已满：替换策略为0 时随机生成一个0-槽数-1 的数，替换掉；若替换策略为1 调用LRU。

遍历cache：

```cpp
int count = -1; 
long position = 0;
for (int i = 0; i < cache.size(); i++)
{
    if(cache[i][0] == addr >> CO)
    {
        count = cache[i][1];
        position = i;
        break;
    }
}
```

命中：

```cpp
if(count != -1)
{
    TotalloadHit++;
    for (int i = 0; i<cache.size(); ++i)
    {
        if(cache[i][1]<count)
        cache[i][1] = cache[i][1] + 1;
    }
    cache[position][1] = 0;
    return;
}
```

未命中且未满，直接插入：

```cpp
if(cache.size() != SlotLen)
{
    for(int i = 0; i<cache.size(); ++i)
        cache[i][1] = cache[i][1] + 1;
    cache.push_back({addr >> CO,0});
    return;
}
```

未命中且已满，替换：

```cpp
if(CacheConfig.replacePolicy == 0)
{
    uniform_int_distribution<long> dis1(0, SlotLen-1);
    cache[dis1(r)] = {addr >> CO,0};
}
else 
{
    LRU(cache,addr >> CO);
}
```

###### FullWrite

与读时基本一致，但时只有写策略为1时才做替换，写策略为0时什么也不做。

##### 组相联

###### SetRead

组相联是直接映射和全相联的结合，先在cache中找index，再遍历cache[index]，寻找是否有匹配的tag

两者都满足时，视为命中。

若有该index，在向量cache[index]中按全相联的方法判断是否满了，如何替换。

若没有该index，插入`{{tag,0}}`

有该组时：

```cpp
 if(cache.find(index) != cache.end())
 {
     // 遍历
     if(cache[index][i][0] == tag)
     {
         count = cache[index][i][1];
         break;
     }
     // 命中
     if(count != -1)
     {
         ... 同全相联命中
     }
     // 不命中
     ...同全相联不命中
 }
```

无该组时

```cpp
else
{
    TotalTime += CacheConfig.MissCost;
    vector<vector<long>> temp;
    temp.push_back({tag,0});
    cache[index] = temp;
}
```

###### SetWrite

与读时基本一致，但时只有写策略为1时才做替换，写策略为0时什么也不做。

##### LRU

遍历该组，替换掉计数位为总长-1的块。

将该块的tag置为新tag，计数位置为0，其余块计数位加1

```cpp
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
```

### 结果展示

#### 调用方法

`./Cachesim -c 配置文件 -t trace文件 -o 输出文件`



若配置文件为：

块大小16B，2路组相联，数据大小16KB，lru，未命中开销100周期，写直达。

![image-20230609130507221](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230609130507221.png)

读入trace，输出如下：

![image-20230609130657425](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230609130657425.png)

<img src="C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230531103228132.png" alt="image-20230531103228132" style="zoom:80%;" />

也可以指定输出到文件：

![image-20230609130722199](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230609130722199.png)

实验成功！

## 3 实验结论

### cache块大小和cache总大小对cache性能的影响

cache块大小取32、64、128、256字节，数据大小取16KB、32KB、64KB、128KB或256kb，直接映射、写分配、LRU替换规则；画图：

![图片2](C:\Users\cos\Desktop\图片2.png)

> 可以看到在一定范围内块增大、命中率提高，时间降低，性能增强。超过范围，随块增大，性能减弱。
>
> 在一定范围内块增大，使一次性数据交换更多，更充分地利用空间局部性。那但是超过一定范围后块大小增大会导致组数减少，映射到同一块的可能性增大，更接近全相联的情况，导致性能下降。
>
> 随cache总大小增大，命中率上升，运行时间变短，性能增强。

### cache关联性对cache性能的影响

数据cache大小取128KB，关联性选择直接映像、2路组相联、4路组相联、8路组相联，写分配、LRU替换规则；画图：

![图片3](C:\Users\cos\Desktop\图片3.png)

> 得到结论：就命中率而言：全相联 > 组相联 > 直接映射
>
> 并且组相联一组中槽数越多（关联性越高），命中率越高

### cache替换策略对cache性能的影响

配置为：

![image-20230609130026122](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230609130026122.png)

当值为0，随机替换：

![image-20230607153311554](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230607153311554.png)

当值为1，lru

![image-20230607153338334](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230607153338334.png)

> 当采用直接映射时，由于替换方式是唯一的，替换策略没有意义，不影响性能。
>
> 当全相联或组相联时，LRU的性能强于随机替换

### cache写回策略对cache性能的影响

当值为0，写直达

![image-20230607153338334](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230607153338334.png)

当值为1，写回

![image-20230607153615163](C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230607153615163.png)

> 可以看到写回的命中率更高，但是消耗时间增多了，因为若写回，需要在不命中时替换cache内容，消耗了更多的时间。
