# install.ps1 — Agent Time Hook for Claude Code & Codex (Windows)
# Usage:  irm https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.ps1 | iex
# Drops the hook script and registers the UserPromptSubmit hook in the existing
# Claude Code and/or Codex config. Merges cleanly (overwrites nothing), is
# idempotent (no duplicate entry) and writes a .bak before any change.
$ErrorActionPreference = 'Stop'
function Say($m,$c='Gray'){ Write-Host $m -ForegroundColor $c }

Say "== Agent Time Hook installer (Claude Code & Codex) ==" Cyan

# --- 1) Drop the hook script (shared by both tools) ---
$hookDir = Join-Path $env:USERPROFILE '.agent-time-hook'
New-Item -ItemType Directory -Force -Path $hookDir | Out-Null
$scriptPath = Join-Path $hookDir 'inject-current-time.ps1'
@'
$ErrorActionPreference = 'Stop'
$d   = Get-Date
$inv = [Globalization.CultureInfo]::InvariantCulture
$now = $d.ToString('yyyy-MM-dd HH:mm:ss', $inv) + ', ' + $d.ToString('dddd', $inv) + ', UTC' + $d.ToString('zzz', $inv)
$ctx = "Current local system time (real, via hook): $now. " +
       "Authoritative for all date/time reasoning (today/tomorrow/yesterday, deadlines, age/duration); " +
       "do NOT extrapolate from earlier messages."
@{ hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit'; additionalContext = $ctx } } | ConvertTo-Json -Compress
'@ | Set-Content -Path $scriptPath -Encoding UTF8
Say "Hook script: $scriptPath"

function New-Entry {
  [pscustomobject]@{ hooks = @(
    [pscustomobject]@{
      type          = 'command'
      command       = 'powershell.exe'
      args          = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$scriptPath)
      timeout       = 10
      statusMessage = 'Getting real time...'
    }
  ) }
}

function Merge-Hook($configPath,$label){
  $cfg = $null
  if (Test-Path $configPath) {
    $raw = (Get-Content $configPath -Raw)
    if ($raw -and $raw.Trim()) {
      try { $cfg = $raw | ConvertFrom-Json } catch { Say "  [!] $label`: $configPath is not valid JSON - skipped (add the hook manually)." Yellow; return }
    }
  }
  if ($null -eq $cfg) { $cfg = [pscustomobject]@{} }
  if (-not ($cfg.PSObject.Properties.Name -contains 'hooks')) { $cfg | Add-Member hooks ([pscustomobject]@{}) }
  if (-not ($cfg.hooks.PSObject.Properties.Name -contains 'UserPromptSubmit')) { $cfg.hooks | Add-Member UserPromptSubmit @() }

  $existing = @($cfg.hooks.UserPromptSubmit)
  foreach ($grp in $existing) {
    foreach ($h in @($grp.hooks)) {
      if ("$($h.command) $($h.args -join ' ')" -match 'inject-current-time') { Say "  $label`: already installed - nothing to do." Green; return }
    }
  }

  $cfg.hooks.UserPromptSubmit = [object[]]($existing + (New-Entry))

  $dir = Split-Path $configPath -Parent
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $hadFile = Test-Path $configPath
  if ($hadFile) { Copy-Item $configPath "$configPath.bak" -Force }
  ($cfg | ConvertTo-Json -Depth 20) | Set-Content -Path $configPath -Encoding UTF8
  $note = if ($hadFile) { '  (backup .bak written)' } else { '  (new file)' }
  Say "  $label`: registered -> $configPath$note" Green
}

# --- 2) Detect tools and register ---
$any = $false
$claude = Join-Path $env:USERPROFILE '.claude'
$codex  = Join-Path $env:USERPROFILE '.codex'
if (Test-Path $claude) { Merge-Hook (Join-Path $claude 'settings.json') 'Claude Code'; $any = $true }
if (Test-Path $codex)  { Merge-Hook (Join-Path $codex  'hooks.json')    'Codex';       $any = $true }

Say ""
if (-not $any) {
  Say "Neither ~/.claude nor ~/.codex found." Yellow
  Say "Start Claude Code or Codex once (creates the folder), then run this installer again."
} else {
  Say "Done! Start a new session and ask:  'What day and time is it right now?'" Cyan
  Say "The answer must match your system clock exactly."
}
