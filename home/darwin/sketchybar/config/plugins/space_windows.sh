#!/bin/bash

# 1. 引用图标映射函数
source "$CONFIG_DIR/plugins/icon_map_fn.sh"
source "$CONFIG_DIR/colors.sh"

# $1 是我们在 items/spaces.sh 里通过 script="$PLUGIN_DIR/aerospace.sh $sid" 传进来的
SID=$1

# 2. 从 AeroSpace 获取该工作区内的 App 列表
# --format %{app-name} 能够拿到类似 "QQ", "Safari浏览器" 这样的名字
APPS_LIST=$(aerospace list-windows --workspace "$SID" --format "%{app-name}")

# 3. 拼接图标字符串
ICON_STR=""

if [ "$APPS_LIST" != "" ]; then
  while IFS= read -r app_name; do
    # 调用映射函数
    icon_map "$app_name"
    # 拼接结果
    ICON_STR+="$icon_result "
  done <<< "$APPS_LIST"
fi

# 4. 根据是否是当前工作区，设置不同的颜色
if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME \
        background.drawing=on \
        background.color=$ACCENT_COLOR \
        label.color=$BAR_COLOR \
        icon.color=$BAR_COLOR \
        label="$ICON_STR" \
        drawing=on
else
    # 非当前工作区
    if [ "$ICON_STR" = "" ]; then
        # 如果是空的，就隐藏（智能隐藏）
        sketchybar --set $NAME drawing=off
    else
        # 如果有窗口，显示但变暗
        sketchybar --set $NAME \
            background.drawing=off \
            label.color=$ACCENT_COLOR \
            icon.color=$ACCENT_COLOR \
            label="$ICON_STR" \
            drawing=on
    fi
fi
