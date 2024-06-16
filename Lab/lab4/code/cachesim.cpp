#include "cache.h"
#include <cstring>

using namespace std;

int main(int argc, char *argv[])
{
    int b = 0, associativity = 0, size = 0, rplc = 0, ovhd = 0, wt = 0;

    char *configFile = nullptr;
    char *traceFile = nullptr;
    char *outputFile = nullptr;

    for (int i = 1; i < argc; i += 2)
    {
        if (strcmp(argv[i], "-c") == 0)
        {
            configFile = argv[i + 1];
            // printf("%s\n",configFile);
        }
        else if (strcmp(argv[i], "-t") == 0)
        {
            traceFile = argv[i + 1];
            // printf("%s\n", traceFile);
        }
        else if (strcmp(argv[i], "-o") == 0)
        {
            outputFile = argv[i + 1];
            // printf("%s\n", outputFile);
        }
    }

    FILE *config;
    config = fopen(configFile, "r");

    if (config == NULL)
    {
        printf("无法打开文件\n");
        return 1; // 返回错误代码
    }

    fscanf(config, "%d%d%d%d%d%d", &b, &associativity, &size, &rplc, &ovhd, &wt);

    fclose(config);
    int blocksize = b;
    int s = associativity == 0 ? 1 : size * 1024 / (blocksize * associativity);
    int e = associativity == 0 ? size * 1024 / blocksize : associativity;
    cache C(b, e, s, rplc, ovhd, wt);

    FILE *trace;
    trace = fopen(traceFile, "r");
    char op;
    long long addr1, addr2;
    while (fscanf(trace, "0x%llx: %c 0x%llx\n", &addr1, &op, &addr2) > 0)
    {
        long long tag1 = addr1 / (s * blocksize);
        int set1 = (addr1 / blocksize) % s;
        C.run('R', tag1, set1);
        C.mem();

        long long tag2 = addr2 / (s * blocksize);
        int set2 = (addr2 / blocksize) % s;
        C.run(op, tag2, set2);
        C.mem();
    }
    fclose(trace);

    if (outputFile != nullptr)
    {
        FILE *output = fopen(outputFile, "w");
        fprintf(output, "Total Hit Rate: %.2f%%\n", C.total_hit_rate() * 100.0);
        fprintf(output, "Load Hit Rate: %.2f%%\n", C.load_hit_rate() * 100.0);
        fprintf(output, "Store Hit Rate: %.2f%%\n", C.store_hit_rate() * 100.0);
        fprintf(output, "Total Run Time: %d\n", C.run_time());
        fprintf(output, "AVG MA Latency: %.2f\n", C.avg_latency());
        fclose(output);
    }
    else
    {
        printf("Total Hit Rate: %.2f%%\n", C.total_hit_rate() * 100.0);
        printf("Load Hit Rate: %.2f%%\n", C.load_hit_rate() * 100.0);
        printf("Store Hit Rate: %.2f%%\n", C.store_hit_rate() * 100.0);
        printf("Total Run Time: %d\n", C.run_time());
        printf("AVG MA Latency: %.2f\n", C.avg_latency());
    }
}