import os
import subprocess
import re
import matplotlib.pyplot as plt

# 配置文件参数生成函数
def generate_cfg_files():
    cfg_files = []
    cache_size = 128 # 缓存大小固定为128KB
    block_size = 32  # 缓存块大小固定为32字节
    replace_policy = 1  # LRU
    miss_overhead = 100  # 固定值
    write_policy = 1  # 写分配
    
    associativities = [1, 2, 4, 8]  # 关联性: 直接映像, 2路, 4路, 8路组相联
    
    for associativity in associativities:
        cfg_filename = f'cfg_{cache_size}KB_{associativity}way.txt'
        with open(cfg_filename, 'w') as f:
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
    cfg_files = generate_cfg_files()
    
    results = []
    for cfg_file in cfg_files:
        metrics = run_simulation(cfg_file)
        # 提取文件名中的关联性
        associativity = int(re.search(r'(\d+)way', cfg_file).group(1))
        results.append((associativity, metrics['Total Hit Rate']))
        os.remove(cfg_file)  # 删除生成的配置文件
    
    # 绘制图线
    plot_results(results)

# 绘制结果
def plot_results(results):
    results.sort()  # 根据关联性排序
    associativities = [result[0] for result in results]
    hit_rates = [result[1] for result in results]

    plt.figure(figsize=(10, 6))
    plt.plot(associativities, hit_rates, marker='o')
    plt.title('Hit Rate vs Associativity for 128KB Cache Size')
    plt.xlabel('Associativity (ways)')
    plt.ylabel('Total Hit Rate (%)')
    plt.xticks(associativities)
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    main()
