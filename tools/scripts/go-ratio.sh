#!/bin/bash

# TODO: add a command loaded with zsh to execute this script

# Compare to master (default)
# ./go-ratio.sh

# Compare to specific branch
# ./go-ratio.sh main

# Compare current branch to master
BASE_BRANCH=${1:-master}

# Get added lines for non-test files
NON_TEST=$(git diff "$BASE_BRANCH"...HEAD --stat -- '*.go' ':!*_test.go' | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)

# Get added lines for test files
TEST=$(git diff "$BASE_BRANCH"...HEAD --stat -- '*_test.go' | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)

# Handle empty values
NON_TEST=${NON_TEST:-0}
TEST=${TEST:-0}

# Calculate ratio
if [ "$NON_TEST" -gt 0 ] && [ "$TEST" -gt 0 ]; then
    RATIO=$(echo "scale=1; $TEST / $NON_TEST" | bc)
    RATIO_STR="1:$RATIO"
elif [ "$NON_TEST" -eq 0 ] && [ "$TEST" -gt 0 ]; then
    RATIO_STR="0:$TEST (all test)"
elif [ "$TEST" -eq 0 ] && [ "$NON_TEST" -gt 0 ]; then
    RATIO_STR="$NON_TEST:0 (no test)"
else
    RATIO_STR="N/A"
fi

# Print table
printf "┌──────────┬───────┐\n"
printf "│ Category │ Lines │\n"
printf "├──────────┼───────┤\n"
printf "│ Non-test │ +%-4s │\n" "$NON_TEST"
printf "├──────────┼───────┤\n"
printf "│ Test     │ +%-4s │\n" "$TEST"
printf "├──────────┼───────┤\n"
printf "│ Ratio    │ %-5s│\n" "$RATIO_STR"
printf "└──────────┴───────┘\n"
