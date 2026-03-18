#!/usr/bin/env bash
# Claude Code status line: PR, token usage, conversation context, session cost estimate
#
# Input JSON schema (from Claude Code docs) relevant fields:
#   .context_window.total_input_tokens    - cumulative input tokens this session
#   .context_window.total_output_tokens   - cumulative output tokens this session
#   .context_window.context_window_size   - model's max context window size
#   .context_window.current_usage         - last API call token breakdown (may be null)
#     .input_tokens                       - input tokens in current context
#     .output_tokens                      - output tokens generated
#     .cache_creation_input_tokens        - tokens written to cache
#     .cache_read_input_tokens            - tokens read from cache
#   .context_window.used_percentage       - % of context window used (null until first message)
#   .context_window.remaining_percentage  - % of context window remaining (null until first message)
#
# NOTE: The Claude Code status line input JSON does NOT include any session cost in dollars,
# weekly cost, or usage budget fields. The only cost-proxy available is token counts.
# Session cost is therefore estimated from cumulative token counts using approximate
# pricing for claude-sonnet-4-6 (input: $3/MTok, output: $15/MTok, cache-read: $0.30/MTok).
# Weekly cost tracking is not possible from this input JSON (no cross-session data).

input=$(cat)

# --- Git PR / branch info ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
branch=""
pr_info=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ] && command -v gh >/dev/null 2>&1; then
    pr_number=$(GIT_OPTIONAL_LOCKS=0 gh pr view --json number -q '.number' 2>/dev/null)
    if [ -n "$pr_number" ]; then
      pr_state=$(GIT_OPTIONAL_LOCKS=0 gh pr view --json state -q '.state' 2>/dev/null)
      pr_info="PR#${pr_number}(${pr_state})"
    fi
  fi
fi

# --- Token / context info ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')

# Cache tokens from current_usage (best available proxy for session cache activity)
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

# --- Session cost estimate ---
# Pricing (per million tokens): input=$3, output=$15, cache_read=$0.30, cache_create=$3.75
# Uses cumulative totals; cache tokens are from last call only (best available approximation).
session_cost=""
if [ -n "$total_input" ] && [ -n "$total_output" ]; then
  session_cost=$(awk -v tin="$total_input" -v tout="$total_output" \
                     -v tcr="$cache_read" -v tcc="$cache_create" '
    BEGIN {
      cost = (tin  / 1000000 * 3.00) \
           + (tout / 1000000 * 15.00) \
           + (tcr  / 1000000 * 0.30) \
           + (tcc  / 1000000 * 3.75)
      if (cost < 0.01)
        printf "<$0.01"
      else
        printf "$%.2f", cost
    }')
fi

# --- Build output ---
parts=()

if [ -n "$branch" ]; then
  if [ -n "$pr_info" ]; then
    parts+=("${branch} ${pr_info}")
  else
    parts+=("${branch}")
  fi
fi

if [ -n "$total_input" ] && [ -n "$total_output" ]; then
  total_tokens=$((total_input + total_output))
  if [ "$total_tokens" -ge 1000 ]; then
    token_k=$(echo "$total_tokens" | awk '{printf "%.1fk", $1/1000}')
    parts+=("tokens:${token_k}")
  else
    parts+=("tokens:${total_tokens}")
  fi
fi

# Session cost estimate (labeled as estimate since no dollar data in JSON)
if [ -n "$session_cost" ]; then
  parts+=("session:~${session_cost}")
fi

# NOTE: weekly cost cannot be shown - the input JSON contains no cross-session
# or billing period data. Only per-session token counts are available.

# Conversation context window fill level (renamed from "ctx:X% used" for clarity)
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  used_rounded=$(printf "%.0f" "$used_pct")
  remaining_rounded=$(printf "%.0f" "$remaining_pct")
  parts+=("conv:${used_rounded}% full (${remaining_rounded}% free)")
fi

# Join with separator
printf "%s" "$(IFS=' | '; echo "${parts[*]}")"
