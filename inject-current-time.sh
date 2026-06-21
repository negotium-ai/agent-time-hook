#!/usr/bin/env bash
# inject-current-time.sh
# UserPromptSubmit hook for Claude Code AND OpenAI Codex (identical hook format).
# Injects the REAL local system time (the machine's own local time, e.g. Toronto user
# -> Toronto time) in ISO 8601 + timezone into the AI context on every message, so the
# AI stops guessing dates. Same JSON shape as the PowerShell variant.
now=$(LC_TIME=C date '+%Y-%m-%d %H:%M:%S, %A, UTC%z')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"Current local system time (real, via hook): %s. Authoritative for all date/time reasoning (today/tomorrow/yesterday, deadlines, age/duration); do NOT extrapolate from earlier messages."}}' "$now"
