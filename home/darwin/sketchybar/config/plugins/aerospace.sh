#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map_fn.sh"

SID=$1

# 1. 焦点判断
TARGET_WORKSPACE="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

# 2. 获取图标
APPS=$(aerospace list-windows --workspace "$SID" --format %{app-name})
ICON_STR=""
if [ "$APPS" != "" ]; then
    while IFS= read -r app_name; do
        icon_map "$app_name"
        ICON_STR+="$icon_result  "
    done <<< "$APPS"
fi
ICON_STR=$(echo "$ICON_STR" | xargs)

# 3. 渲染逻辑 (已修复双重显示问题)
if [ "$SID" = "$TARGET_WORKSPACE" ]; then
    # === 当前聚焦 ===
    sketchybar --set $NAME \
        background.drawing=on \
        background.color=$ACCENT_COLOR \
        label.color=$BAR_COLOR \
        icon.color=$BAR_COLOR \
        label="$ICON_STR" \
        drawing=on
        # ⬆️ 修改点：这里去掉了 $SID，只显示图标
else
    # === 后台 ===
    if [ "$ICON_STR" = "" ]; then
        # 空闲 -> 隐藏
        sketchybar --set $NAME drawing=off
    else
        # 有程序 -> 显示
        sketchybar --set $NAME \
            background.drawing=off \
            label.color=$ACCENT_COLOR \
            icon.color=$ACCENT_COLOR \
            label="$ICON_STR" \
            drawing=on
            # ⬆️ 修改点：这里也去掉了 $SID
    fi
fi
