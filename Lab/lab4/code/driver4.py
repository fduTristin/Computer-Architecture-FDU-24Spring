import os
import subprocess
import re
import matplotlib.pyplot as plt
import numpy as np

# 配置文件参数生成函数
def generate_cfg_files():
    cfg_files = []
    cache_size = 128  # 缓存大小固定为128KB
    block_size = 64  # 缓存块大小固定为64字节
    associativity = 1  # 直接映像
    miss_overhead = 100  # 固定值
    
    write_policies = [0, 1]  # 写分配法和写回法
    
    for write_policy in write_policies:
        policy_name = "WriteThrough" if write_policy == 0 else "WriteBack"
        cfg_filename = f'cfg_{cache_size}KB_direct_LRU_{policy_name}.txt'
        with open(cfg_filename, 'w') as f:
            f.write(f"{block_size}\n{associativity}\n{cache_size}\n1\n{miss_overhead}\n{write_policy}\n")
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
    metrics['AVG MA Latency'] = float(re.search(r'AVG MA Latency:\s+([\d.]+)', output).group(1))
    return metrics

# 主函数
def main():
    cfg_files = generate_cfg_files()
    
    results = []
    for cfg_file in cfg_files:
        metrics = run_simulation(cfg_file)
        # 提取写回策略名
        write_policy = "WriteThrough" if "WriteThrough" in cfg_file else "WriteBack"
        results.append((write_policy, metrics['Total Hit Rate'], metrics['Load Hit Rate'], metrics['Store Hit Rate'], metrics['AVG MA Latency']))
        os.remove(cfg_file)  # 删除生成的配置文件
    
    # 绘制图线
    plot_results(results)

# 绘制结果
def plot_results(results):
    policies = [result[0] for result in results]
    total_hit_rates = [result[1] for result in results]
    load_hit_rates = [result[2] for result in results]
    store_hit_rates = [result[3] for result in results]
    avg_ma_latencies = [result[4] for result in results]

    fig, ax = plt.subplots(figsize=(10, 8))

    bar_width = 0.2
    index = np.arange(len(policies))

    ax.bar(index, total_hit_rates, bar_width, label='Total Hit Rate', color='tab:blue')
    ax.bar(index + bar_width, load_hit_rates, bar_width, label='Load Hit Rate', color='tab:cyan')
    ax.bar(index + 2 * bar_width, store_hit_rates, bar_width, label='Store Hit Rate', color='tab:purple')
    ax.bar(index + 3 * bar_width, avg_ma_latencies, bar_width, label='AVG MA Latency', color='tab:red')

    ax.set_xlabel('Write Policies')
    ax.set_ylabel('Performance (%) and AVG MA Latency')
    ax.set_title('Cache Performance Comparison for Different Write Policies')
    ax.set_xticks(index + 1.5 * bar_width)
    ax.set_xticklabels(policies)
    ax.legend()

    for i, v in enumerate(total_hit_rates):
        ax.text(i, v + 1, f"{v:.2f}%", ha='center', color='tab:blue')
    for i, v in enumerate(load_hit_rates):
        ax.text(i + bar_width, v + 1, f"{v:.2f}%", ha='center', color='tab:cyan')
    for i, v in enumerate(store_hit_rates):
        ax.text(i + 2 * bar_width, v + 1, f"{v:.2f}%", ha='center', color='tab:purple')
    for i, v in enumerate(avg_ma_latencies):
        ax.text(i + 3 * bar_width, v + 1, f"{v:.2f}", ha='center', color='tab:red')

    plt.show()

if __name__ == "__main__":
    main()
