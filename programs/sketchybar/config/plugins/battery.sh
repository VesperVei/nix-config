#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  [8-9][0-9]|100) ICON="􁁔"
  ;;
  7[0-9]) ICON="􀛨"
  ;;
  6[0-9]) ICON="􀺸"
  ;;
  5[0-9]) ICON="􀺶"
  ;;
  [3-4][0-9]) ICON="􀛩"
  ;;
  *) ICON=""
esac

# 判断是否在充电
if [[ "$CHARGING" != "" ]]; then
  if [ "$PERCENTAGE" -ge 80 ]; then
    ICON="􁁕"    # 🎯 高电量 + 充电状态
  else
    ICON="􀢋"    # 🔌 普通充电图标
  fi
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" icon="$ICON"
