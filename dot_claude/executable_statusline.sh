#!/usr/bin/env bash
# Claude Code status line: model + current context-window usage.
# Receives the status-line JSON payload on stdin.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // "?"')
model_id=$(printf '%s' "$input" | jq -r '.model.id // ""')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd" 2>/dev/null)

# Current git branch (if cwd is inside a work tree).
branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Context window limit: 1M for [1m] models, else 200k.
case "$model_id" in
  *1m*|*\[1m\]*) limit=1000000 ;;
  *)            limit=200000 ;;
esac

# Most recent main-chain assistant turn's usage = current context size.
ctx=0
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  ctx=$(tac "$transcript" 2>/dev/null | jq -rs '
    map(select(.type == "assistant" and (.isSidechain // false | not) and .message.usage))
    | .[0].message.usage
    | ( (.input_tokens // 0)
      + (.cache_read_input_tokens // 0)
      + (.cache_creation_input_tokens // 0) ) // 0
  ' 2>/dev/null)
  [ -z "$ctx" ] && ctx=0
fi

# Human-readable token count + percentage of the window.
fmt=$(awk -v t="$ctx" 'BEGIN { if (t>=1000) printf "%.1fk", t/1000; else printf "%d", t }')
pct=$(awk -v t="$ctx" -v l="$limit" 'BEGIN { if (l>0) printf "%d", (t*100)/l; else printf "0" }')

printf '\033[2m%s\033[0m' "$dir"
[ -n "$branch" ] && printf ' \033[32m\356\202\240 %s\033[0m' "$branch"
printf ' | \033[36m%s\033[0m | ctx \033[33m%s\033[0m (%s%%)' "$model" "$fmt" "$pct"
