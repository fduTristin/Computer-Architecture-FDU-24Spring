import os
import subprocess
import re
import matplotlib.pyplot as plt

# 配置文件参数生成函数
def generate_cfg_files():
    cfg_files = []
    cache_size = 128  # 缓存大小固定为128KB
    block_size = 64  # 缓存块大小固定为64字节
    associativity = 4  # 4路组相联
    miss_overhead = 100  # 固定值
    write_policy = 1  # 写回法
    
    replace_policies = [0, 1]  # 替换策略: 随机替换, LRU
    
    for replace_policy in replace_policies:
        policy_name = "Random" if replace_policy == 0 else "LRU"
        cfg_filename = f'cfg_{cache_size}KB_{associativity}way_{policy_name}.txt'
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
        # 提取文件名中的替换策略
        replace_policy = "Random" if "Random" in cfg_file else "LRU"
        results.append((replace_policy, metrics['Total Hit Rate'], metrics['Load Hit Rate'], metrics['Store Hit Rate'], metrics['Total Run Time'], metrics['AVG MA Latency']))
        os.remove(cfg_file)  # 删除生成的配置文件
    
    # 绘制图线
    plot_results(results)

# 绘制结果
def plot_results(results):
    policies = [result[0] for result in results]
    total_hit_rates = [result[1] for result in results]
    load_hit_rates = [result[2] for result in results]
    store_hit_rates = [result[3] for result in results]
    total_run_times = [result[4] for result in results]
    avg_ma_latencies = [result[5] for result in results]

    fig, ax = plt.subplots(figsize=(12, 8))

    x = range(len(policies))

    # 总命中率
    ax.bar(x, total_hit_rates, width=0.1, label='Total Hit Rate', align='center')
    for i, v in enumerate(total_hit_rates):
        ax.text(i, v + 1, f"{v:.2f}%", ha='center')

    # 加载命中率
    ax.bar([p + 0.1 for p in x], load_hit_rates, width=0.1, label='Load Hit Rate', align='center')
    for i, v in enumerate(load_hit_rates):
        ax.text(i + 0.1, v + 1, f"{v:.2f}%", ha='center')

    # 存储命中率
    ax.bar([p + 0.2 for p in x], store_hit_rates, width=0.1, label='Store Hit Rate', align='center')
    for i, v in enumerate(store_hit_rates):
        ax.text(i + 0.2, v + 1, f"{v:.2f}%", ha='center')

    # # 总运行时间
    # ax.bar([p + 0.3 for p in x], total_run_times, width=0.1, label='Total Run Time', align='center')
    # for i, v in enumerate(total_run_times):
    #     ax.text(i + 0.3, v + 1, f"{v}", ha='center')

    # 平均内存访问延迟
    ax.bar([p + 0.3 for p in x], avg_ma_latencies, width=0.1, label='AVG MA Latency', align='center')
    for i, v in enumerate(avg_ma_latencies):
        ax.text(i + 0.3, v + 1, f"{v:.2f}", ha='center')

    ax.set_xlabel('Replacement Policies')
    ax.set_ylabel('Values')
    ax.set_title('Cache Performance Comparison for Different Replacement Policies')
    ax.set_xticks([p + 0.2 for p in x])
    ax.set_xticklabels(policies)
    ax.legend()
    ax.grid(True)

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()
