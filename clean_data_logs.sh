#!/bin/bash

# 根日志目录
LOG_ROOT_DIR="/data/logs"

# 最大允许文件大小（单位：MB）
MAX_SIZE_MB=100
MAX_SIZE=$((MAX_SIZE_MB * 1024 * 1024))  # 转换为字节

# 日志文件
CLEAN_LOG="/data/logs/clean_data_logs.log"

# 清理函数
clean_logs_in_subdirs() {
    local cleaned_count=0
    local total_cleaned_size=0

    # 遍历所有子目录中的文件
    for subdir in "$LOG_ROOT_DIR"/*; do
        # 跳过非目录
        [ -d "$subdir" ] || continue
        
        for log_file in "$subdir"/*.log; do
            # 跳过非文件
            [ -f "$log_file" ] || continue

            # 获取文件大小
            file_size=$(stat -c %s "$log_file")

            # 如果文件大小超过限制，则清空文件
            if (( file_size > MAX_SIZE )); then
                : > "$log_file"
                echo "$(date) - Cleaned $log_file (Size: $((file_size / 1024 / 1024))MB)" >> "$CLEAN_LOG"
                cleaned_count=$((cleaned_count + 1))
                total_cleaned_size=$((total_cleaned_size + file_size))
            fi
        done
    done

    # 记录总清理结果
    if (( cleaned_count > 0 )); then
        echo "$(date) - Total files cleaned: $cleaned_count, Total size cleaned: $((total_cleaned_size / 1024 / 1024))MB" >> "$CLEAN_LOG"
    fi
}

# 后台运行脚本
(
    while true; do
        clean_logs_in_subdirs
        sleep 24h  # 每24小时检测一次
    done
) &

