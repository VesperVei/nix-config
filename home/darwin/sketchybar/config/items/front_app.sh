#!/bin/bash

# 这里的 front_app 是显示在 Bar 左侧区域的最右边的那个组件
sketchybar --add item front_app right \
           --set front_app \
                 background.color=$ACCENT_COLOR \
                 icon.color=$BAR_COLOR \
                 icon.font="sketchybar-app-font:Regular:16.0" \
                 label.color=$BAR_COLOR \
                 script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
