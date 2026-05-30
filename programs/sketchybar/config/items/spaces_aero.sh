#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# 1. 动态获取所有工作区
for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change front_app_switched \
        --set space.$sid \
        background.color=$ACCENT_COLOR \
        background.corner_radius=5 \
        background.height=20 \
        background.drawing=off \
        drawing=off \
        \
        icon="$sid" \
        icon.color=$ACCENT_COLOR \
        icon.font="SF Pro:Bold:16.0" \
        icon.padding_left=10 \
        icon.padding_right=2 \
        \
        label="…" \
        label.color=$ACCENT_COLOR \
        label.font="sketchybar-app-font:Regular:16.0" \
        label.padding_right=10 \
        label.y_offset=-1 \
        \
        click_script="aerospace workspace $sid" \
        script="$PLUGIN_DIR/aerospace.sh $sid"
done

# 分割线
sketchybar --add item space_separator left \
           --set space_separator icon="􀆊" \
                                 icon.color=$ACCENT_COLOR \
                                 icon.padding_left=4 \
                                 label.drawing=off \
                                 background.drawing=off
