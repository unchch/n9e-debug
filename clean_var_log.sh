#!/bin/bash

# 日志目录
LOG_DIR="/var/log"

# 文件前缀列表（以空格分隔）
LOG_PREFIXES=("boot" "cli" "mail" "message" "secure" "spooler" "yum")

# 最大允许大小（单位：MB）
MAX_SIZE_MB=100
MAX_SIZE=$((MAX_SIZE_MB * 1024 * 1024))  # 转换为字节

# 日志文件
CLEAN_LOG="/data/logs/clean_var_log.log"

# 清理函数
clean_logs_by_prefix() {
    total_size=0

    # 遍历指定前缀的文件，计算总大小
    for prefix in "${LOG_PREFIXES[@]}"; do
        for log_file in "$LOG_DIR"/"$prefix"*; do
            # 跳过非文件情况
            [ -f "$log_file" ] || continue

            # 累加文件大小
            file_size=$(stat -c %s "$log_file")
            total_size=$((total_size + file_size))
        done
    done

    # 如果总大小超过限制，清空符合条件的文件
    if (( total_size > MAX_SIZE )); then
        for prefix in "${LOG_PREFIXES[@]}"; do
            for log_file in "$LOG_DIR"/"$prefix"*; do
                [ -f "$log_file" ] && : > "$log_file"
                echo "$(date) - Cleaned $log_file" >> "$CLEAN_LOG"
            done
        done
        echo "$(date) - Total size exceeded ${MAX_SIZE_MB}MB. Logs cleaned." >> "$CLEAN_LOG"
    fi
}

# 后台运行脚本
(
    while true; do
        clean_logs_by_prefix
        sleep 48h  # 每48小时检测一次
    done
) &

