#include "cache.h"
#include <malloc.h>
#include <random>

cache::cache(int b, int e, int s, int rplc, int ovhd, int wt) : B(b), E(e), S(s), replacement(rplc), miss_overhead(ovhd), write_method(wt)
{
    cache_line = (struct line **)malloc(sizeof(struct line *) * s);
    for (int i = 0; i != s; i++)
    {
        cache_line[i] = (struct line *)malloc(sizeof(struct line) * E);
        for (int j = 0; j != E; j++)
        {
            cache_line[i][j].tag = -1;
            cache_line[i][j].valid = false;
            cache_line[i][j].dirty = false;
            cache_line[i][j].recently_used = 0;
            cache_line[i][j].data = (unsigned char *)malloc(sizeof(unsigned char) * B);
        }
    }
    r_misses = w_misses = r_hits = w_hits = 0;
    time = 0;
    mem_count = 0;
}

int cache::find_empty(int s)
{
    for (int i = 0; i != E; i++)
    {
        if (!cache_line[s][i].valid)
            return i;
    }
    return -1;
}

int cache::find_block(long long tag, int s)
{
    for (int i = 0; i != E; i++)
    {
        if (cache_line[s][i].tag == tag)
            return i;
    }
    return -1;
}

int cache::find_LRU(int s)
{
    int idx = 0;
    for (int i = 0; i != E; i++)
    {
        if (cache_line[s][i].recently_used > cache_line[s][idx].recently_used)
            idx = i;
    }
    return idx;
}

int cache::find_replace(int s)
{
    if (replacement) // LRU
        return find_LRU(s);
    else // random
    {
        // set random number engine
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> distrib(0, E - 1);

        // return a random number between 0 and E-1
        return distrib(gen);
    }
}

void cache::update_block(int idx, int s, long long tag)
{
    for (int i = 0; i != E; i++)
    {
        if (i != idx)
        {
            if (cache_line[s][i].valid && replacement)
                cache_line[s][i].recently_used++;
        }
        else
        {
            cache_line[s][i].tag = tag;
            cache_line[s][i].recently_used = 0;
            cache_line[s][i].valid = true;
            cache_line[s][i].dirty = false;
        }
    }
}

void cache::run(char op, long long tag, int s)
{

    int idx = find_block(tag, s); // find

    time += CACHE_TIME;

    if (idx != -1)
    {
        if (op == 'R')
        {
            r_hits++;
            //printf("r_hit\n");
        }
        else
        {
            w_hits++;
            //printf("w_hit\n");
            if (write_method == 1)               //  write back
                cache_line[s][idx].dirty = true; // set dirty bit
            if (write_method == 0)               // write through
                time += miss_overhead;           // mem
        }
    }
    else
    {
        int id = find_empty(s);

        if (op == 'R')
        {
            r_misses++;
            //printf("r_miss\n");
            if (id != -1)
            {

                update_block(id, s, tag);
                time += miss_overhead;
            }
            else
            {
                id = find_replace(s);

                if (write_method == 1) // need to write back the block replaced
                {
                    if (cache_line[s][id].dirty)
                    {
                        time += miss_overhead; // write back to mem
                    }
                }

                update_block(id, s, tag);
                time += miss_overhead;
            }
        }

        else
        {
            w_misses++;
            //printf("w_miss\n");
            if (write_method == 0)
            {

                time += miss_overhead; // just need to write to mem
            }
            else
            {
                if (id != -1)
                {
                    update_block(id, s, tag); // transfer mem to cache
                    time += miss_overhead;
                    run('W', tag, s); // write again
                }
                else
                {
                    id = find_replace(s);

                    if (cache_line[s][id].dirty)
                    {
                        time += miss_overhead; // write back to mem
                    }

                    update_block(id, s, tag);
                    time += miss_overhead;
                    run('W', tag, s); // write again
                }
            }
        }
    }
}

double cache::total_hit_rate()
{
    return 1.0 * (r_hits + w_hits) / (r_hits + w_hits + r_misses + w_misses);
}

double cache::load_hit_rate()
{
    return 1.0 * r_hits / (r_hits + r_misses);
}

double cache::store_hit_rate()
{
    return 1.0 * w_hits / (w_hits + w_misses);
}

long long cache::run_time()
{
    return time;
}

double cache::avg_latency()
{
    return 1.0 * time / mem_count;
}

void cache::mem()
{
    mem_count++;
}
