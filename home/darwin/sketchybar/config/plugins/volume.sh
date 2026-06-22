#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
    [4-9][0-9]|100) ICON="󰕾"
    ;;
    [1][6-9]|[2-3][0-9]) ICON="󰖀"
    ;;
    [1-9]|[1][0-5]) ICON="󰕿"
    ;;
    *) ICON="􀫠"
  esac

  sketchybar --set "$NAME" icon="$ICON"
fi
