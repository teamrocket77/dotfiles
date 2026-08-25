#!/usr/bin/env bash

# --- RAM Calculation ---
# Fetches hardware specs directly from the kernel
page_size=$(sysctl -n hw.pagesize)
mem_total=$(sysctl -n hw.memsize)

# Extract page counts using the colon delimiter to safely strip text and spaces
stats=$(vm_stat)
app_pages=$(echo "$stats" | awk -F ':' '/Anonymous pages/ {print $2}' | tr -d ' .')
wired_pages=$(echo "$stats" | awk -F ':' '/Pages wired down/ {print $2}' | tr -d ' .')
comp_pages=$(echo "$stats" | awk -F ':' '/Pages occupied by compressor/ {print $2}' | tr -d ' .')

# Fallbacks to 0 in case a value is empty
app_pages=${app_pages:-0}
wired_pages=${wired_pages:-0}
comp_pages=${comp_pages:-0}

# Calculate used bytes and convert to a percentage
used_bytes=$(( (app_pages + wired_pages + comp_pages) * page_size ))
ram_pct=$(( used_bytes * 100 / mem_total ))

# --- CPU Calculation ---
# Get total logical cores
cores=$(sysctl -n hw.ncpu)

# Sum all active process CPU percentages, then divide by core count for system 0-100%
cpu_pct=$(ps -A -o %cpu | awk -v cores="$cores" '{sum+=$1} END {printf "%.0f", sum/cores}')

echo "CPU: ${cpu_pct}% | RAM: ${ram_pct}%"
