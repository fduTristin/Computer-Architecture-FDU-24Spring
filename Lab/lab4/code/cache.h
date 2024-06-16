#include <fstream>
#define CACHE_TIME 1

struct line
{
    bool valid; // true: valid
    bool dirty; // true: changed
    long long tag;
    unsigned char *data; // one byte each
    int recently_used;   // count
};

class cache
{
private:
    int B; // block size
    int E; // associativity
    int S; // number of sets
    line **cache_line;
    int replacement;
    int miss_overhead;
    int r_misses;
    int w_misses;
    int r_hits;
    int w_hits;
    long long time;
    long long mem_count;
    int write_method; // 0: write through / not write allocate  1: write back / write allocate

public:
    cache(int, int, int, int, int, int);
    int find_empty(int s);                  // find empty line
    int find_block(long long, int);         // find line with target tag
    int find_LRU(int);                      // find LRU
    int find_replace(int);                  // find the block for replacement
    void update_block(int, int, long long); // update a block
    void run(char, long long, int);         // perform a read/write
    double total_hit_rate();
    double load_hit_rate();
    double store_hit_rate();
    long long run_time();
    double avg_latency();
    void mem();
};
