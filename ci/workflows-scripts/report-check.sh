#!/bin/bash

# report_check(label, skipped, result)
# Appends a summary line to summary.html
report_check() {
  local label="$1"
  local skipped="$2"
  local result="$3"

  if [[ "$skipped" == "true" ]]; then
    echo "✅ $label check skipped (no relevant changes)" >> summary.html
    echo "<br/>" >> summary.html
  elif [[ ("$skipped" == "false" || -z "$skipped") && -z "$result" ]]; then
    echo "❌ $label check did not complete properly – please re-run the job." >> summary.html
    echo "<br/>" >> summary.html
  else
    echo "$result" >> summary.html
  fi
}
