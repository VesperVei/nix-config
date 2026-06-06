#!/usr/bin/env zsh

# 为每个 tmux pane 使用独立历史文件，避免多个 pane 共享同一个回滚记录池。
# tmux 下的 pane 定位使用 tmux-resurrect 恢复时依赖的 session/window_index/pane_index，
# 不再使用 TMUX_PANE=%N 这种 tmux server 生命周期内的临时 id。
HISTSIZE=50000
SAVEHIST=50000

_chenhun_history_dir="$HOME/.zsh_history.d"
mkdir -p "$_chenhun_history_dir"

if [[ -n "$TMUX_PANE" ]]; then
  _chenhun_tmux_session="$(tmux display-message -p '#S' 2>/dev/null)"
  _chenhun_tmux_window="$(tmux display-message -p '#I' 2>/dev/null)"
  _chenhun_tmux_pane="$(tmux display-message -p '#{pane_index}' 2>/dev/null)"

  # pane 池是当前 shell 的主历史；window/session 池只作为新 pane 的兜底来源。
  _chenhun_history_id="pane_${_chenhun_tmux_session}_${_chenhun_tmux_window}_${_chenhun_tmux_pane}"
  _chenhun_history_window_id="window_${_chenhun_tmux_session}_${_chenhun_tmux_window}"
  _chenhun_history_session_id="session_${_chenhun_tmux_session}"
elif [[ -n "$KITTY_WINDOW_ID" ]]; then
  _chenhun_history_id="kitty_${KITTY_WINDOW_ID//[^A-Za-z0-9]/_}"
else
  _chenhun_tty="${TTY:-$(tty 2>/dev/null)}"
  _chenhun_history_id="tty_${_chenhun_tty//[^A-Za-z0-9]/_}"
fi

_chenhun_history_id="${_chenhun_history_id//[^A-Za-z0-9]/_}"
export HISTFILE="$_chenhun_history_dir/zsh_history_${_chenhun_history_id}"

if [[ -n "$_chenhun_history_window_id" ]]; then
  _chenhun_history_window_id="${_chenhun_history_window_id//[^A-Za-z0-9]/_}"
  _chenhun_history_window_file="$_chenhun_history_dir/zsh_history_${_chenhun_history_window_id}"
fi

if [[ -n "$_chenhun_history_session_id" ]]; then
  _chenhun_history_session_id="${_chenhun_history_session_id//[^A-Za-z0-9]/_}"
  _chenhun_history_session_file="$_chenhun_history_dir/zsh_history_${_chenhun_history_session_id}"
fi

# 不跨 shell 共享历史；当前 pane 只读取和写入自己的 HISTFILE。
unsetopt SHARE_HISTORY 2>/dev/null
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# ~/.zshrc 中 Oh My Zsh 已经先加载过全局历史，这里切换到 pane 专属历史栈。
if [[ "$CHENHUN_PANE_HISTORY_ACTIVE" != "$HISTFILE" ]]; then
  fc -p "$HISTFILE" "$HISTSIZE" "$SAVEHIST"

  # 如果当前 pane 历史为空，按 window -> session 逐级读取兜底历史。
  # 注意：兜底只导入当前内存历史栈，新命令仍然写入 pane 自己的 HISTFILE。
  if [[ ! -s "$HISTFILE" ]]; then
    if [[ -n "$_chenhun_history_window_file" && -s "$_chenhun_history_window_file" ]]; then
      fc -R "$_chenhun_history_window_file"
    elif [[ -n "$_chenhun_history_session_file" && -s "$_chenhun_history_session_file" ]]; then
      fc -R "$_chenhun_history_session_file"
    fi
  fi

  export CHENHUN_PANE_HISTORY_ACTIVE="$HISTFILE"
fi

autoload -Uz add-zsh-hook
zmodload zsh/datetime 2>/dev/null

_chenhun_history_save() {
  builtin fc -AI
}

_chenhun_history_aggregate() {
  local _line="${1%$'\n'}"
  local _timestamp="${EPOCHSECONDS:-$(date +%s)}"

  # 聚合池只用于未来新 pane fallback，不参与当前 shell 的实时共享历史。
  # zshaddhistory 在命令入栈时触发；这里手动写 extended history，避免 fc -AI 已写标记导致聚合池为空。
  if [[ -z "$_line" || "$_line" == [[:space:]]* ]]; then
    return 0
  fi

  if [[ -n "$CHENHUN_HISTORY_WINDOW_FILE" ]]; then
    print -r -- ": ${_timestamp}:0;${_line}" >>| "$CHENHUN_HISTORY_WINDOW_FILE"
  fi

  if [[ -n "$CHENHUN_HISTORY_SESSION_FILE" ]]; then
    print -r -- ": ${_timestamp}:0;${_line}" >>| "$CHENHUN_HISTORY_SESSION_FILE"
  fi
}

add-zsh-hook -d precmd _chenhun_history_save 2>/dev/null
add-zsh-hook precmd _chenhun_history_save
add-zsh-hook -d zshaddhistory _chenhun_history_aggregate 2>/dev/null
add-zsh-hook zshaddhistory _chenhun_history_aggregate

export CHENHUN_HISTORY_WINDOW_FILE="$_chenhun_history_window_file"
export CHENHUN_HISTORY_SESSION_FILE="$_chenhun_history_session_file"

unset _chenhun_history_dir _chenhun_history_id _chenhun_history_window_id _chenhun_history_session_id
unset _chenhun_history_window_file _chenhun_history_session_file _chenhun_tty
unset _chenhun_tmux_session _chenhun_tmux_window _chenhun_tmux_pane
