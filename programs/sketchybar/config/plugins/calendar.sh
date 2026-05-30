#!/bin/bash

# 获取当前小时与分钟
HOUR=$(date +"%H")
MIN=$(date +"%M")

# 转成分钟方便比较
TOTAL_MIN=$((10#$HOUR * 60 + 10#$MIN))

# 四个区间（写成分钟）
# 05:00–11:30
# 4:30–10:15
if (( TOTAL_MIN >= 270 && TOTAL_MIN <= 615 )); then
    ICON="􀆱"  # 区间1

# 10:16–17:19
elif (( TOTAL_MIN >= 616 && TOTAL_MIN <= 1039 )); then
    ICON="🌞"  # 区间2

# 17:20–19:00
elif (( TOTAL_MIN >= 1040 && TOTAL_MIN <= 1140 )); then
    ICON="􀆳"  # 区间3

# 19:01–04:29（跨天）
else
    ICON="🌙"  # 区间4
fi
# 12小时制，不显示 AM/PM
TIME=$(date +"%I:%M" | sed 's/^0//')  # 去掉前导 0

# 显示效果： 图标 + 日期 + 时间
sketchybar --set "$NAME" label="$(date +'%a %d') $TIME $ICON"
