# inject-current-time.ps1
# UserPromptSubmit hook for Claude Code AND OpenAI Codex (identical hook format).
# Injects the REAL local system time into the AI context on every message, so the AI
# stops guessing dates/deadlines. The time is the machine's own local time (e.g. a
# user in Toronto gets Toronto time) in ISO 8601 + timezone = globally unambiguous.
$ErrorActionPreference = 'Stop'
$d   = Get-Date
$inv = [Globalization.CultureInfo]::InvariantCulture
$now = $d.ToString('yyyy-MM-dd HH:mm:ss', $inv) + ', ' + $d.ToString('dddd', $inv) + ', UTC' + $d.ToString('zzz', $inv)
$ctx = "Current local system time (real, via hook): $now. " +
       "Authoritative for all date/time reasoning (today/tomorrow/yesterday, deadlines, age/duration); " +
       "do NOT extrapolate from earlier messages."
@{ hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit'; additionalContext = $ctx } } | ConvertTo-Json -Compress
