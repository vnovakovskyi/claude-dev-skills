#!/usr/bin/env bash
# Prints the lines a finding is about, the way a pull request review shows them:
# a few lines of context above, then the commented lines, each with its line
# number at the head commit. Lines the pull request added or changed start
# with "+", so a ```diff block colours them.
#
# usage: excerpt.sh <repo> <base sha> <head sha> <path> <start line> [end line] [context lines]
set -euo pipefail

if [ "$#" -lt 5 ]; then
  echo "usage: excerpt.sh <repo> <base sha> <head sha> <path> <start line> [end line] [context lines]" >&2
  exit 2
fi

repo=$1 base=$2 head=$3 path=$4 start=$5 end=${6:-$5} context=${7:-3}

added=$(git -C "$repo" diff -U0 "$base" "$head" -- "$path" | awk '
  /^@@/ {
    split($3, new, ",")
    line = substr(new[1], 2) + 0
    next
  }
  /^\+\+\+/ { next }
  /^\+/ { printf "%d ", line; line++; next }
')

from=$(( start - context ))
[ "$from" -lt 1 ] && from=1

length=$(git -C "$repo" show "$head:$path" | awk 'END { print NR }')
if [ "$start" -gt "$end" ] || [ "$end" -gt "$length" ]; then
  echo "excerpt.sh: lines $start-$end are not in $path, which has $length lines at $head" >&2
  exit 1
fi

git -C "$repo" show "$head:$path" | awk -v from="$from" -v to="$end" -v added="$added" '
  BEGIN {
    n = split(added, list, " ")
    for (i = 1; i <= n; i++) isAdded[list[i]] = 1
  }
  NR >= from && NR <= to {
    printf "%s %4d │ %s\n", (NR in isAdded ? "+" : " "), NR, $0
  }
  NR > to { exit }
'

# GitHub takes an inline comment only on lines inside one hunk of the diff it
# shows, which has three lines of context.
git -C "$repo" diff "$base" "$head" -- "$path" | awk -v s="$start" -v e="$end" '
  /^@@/ {
    split($3, new, ",")
    first = substr(new[1], 2) + 0
    count = (new[2] == "" ? 1 : new[2] + 0)
    if (s >= first && e <= first + count - 1) found = 1
  }
  END {
    if (found) print "inline: yes" > "/dev/stderr"
    else print "inline: no — outside the diff, put it in the review body" > "/dev/stderr"
  }
'
