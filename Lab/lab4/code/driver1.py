import os
import subprocess
import re
import matplotlib.pyplot as plt

# 配置文件参数生成函数
def generate_cfg_files(block_sizes, cache_sizes):
    cfg_files = []
    for block_size in block_sizes:
        for cache_size in cache_sizes:
            cfg_filename = f'cfg_{block_size}_{cache_size}.txt'
            with open(cfg_filename, 'w') as f:
                associativity = 1  # 直接映射
                replace_policy = 1  # LRU
                miss_overhead = 100  # 固定值
                write_policy = 1  # 写分配
                f.write(f"{block_size}\n{associativity}\n{cache_size}\n{replace_policy}\n{miss_overhead}\n{write_policy}\n")
            cfg_files.append(cfg_filename)
    return cfg_files

# 运行 cachesim.exe 并解析输出
def run_simulation(cfg_file):
    result = subprocess.run(['.\cachesim.exe', '-c', cfg_file, '-t', 'ls.trace'], capture_output=True, text=True)
    output = result.stdout
    return parse_output(output)

# 解析 cachesim.exe 的输出
def parse_output(output):
    metrics = {}
    metrics['Total Hit Rate'] = float(re.search(r'Total Hit Rate:\s+([\d.]+)', output).group(1))
    metrics['Load Hit Rate'] = float(re.search(r'Load Hit Rate:\s+([\d.]+)', output).group(1))
    metrics['Store Hit Rate'] = float(re.search(r'Store Hit Rate:\s+([\d.]+)', output).group(1))
    metrics['Total Run Time'] = int(re.search(r'Total Run Time:\s+(\d+)', output).group(1))
    metrics['AVG MA Latency'] = float(re.search(r'AVG MA Latency:\s+([\d.]+)', output).group(1))
    return metrics

# 主函数
def main():
    block_sizes = [32, 64, 128, 256]  # 缓存块大小
    cache_sizes = [16, 32, 64, 128, 256]  # 缓存大小，单位KB
    cfg_files = generate_cfg_files(block_sizes, cache_sizes)
    
    results = {cache_size: [] for cache_size in cache_sizes}
    for cfg_file in cfg_files:
        metrics = run_simulation(cfg_file)
        # 提取文件名中的缓存块大小和缓存大小
        block_size, cache_size = map(int, re.findall(r'\d+', cfg_file))
        results[cache_size].append([block_size, metrics['Total Hit Rate']])
        os.remove(cfg_file)  # 删除生成的配置文件
    # 绘制图线
    plot_results(results)

# 绘制结果
def plot_results(results):
    plt.figure(figsize=(12, 8))

    for cache_size, data in results.items():
        data.sort()  # 根据缓存块大小排序
        block_sizes = [item[0] for item in data]
        hit_rates = [item[1] for item in data]
        plt.plot(block_sizes, hit_rates, marker='o', label=f'{cache_size}KB Cache Size')

    plt.title('Total Hit Rate vs Block Size for Different Cache Sizes')
    plt.xlabel('Block Size (bytes)')
    plt.ylabel('Total Hit Rate (%)')
    plt.legend()
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    main()
