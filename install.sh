#!/usr/bin/env bash
# install.sh — Agent Time Hook for Claude Code & Codex (macOS/Linux)
# Usage:  curl -fsSL https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.sh | bash
# Drops the hook script and registers the UserPromptSubmit hook in the existing
# Claude Code and/or Codex config. Merges cleanly (overwrites nothing), is
# idempotent (no duplicate entry) and writes a .bak before any change.
set -euo pipefail

echo "== Agent Time Hook installer (Claude Code & Codex) =="

# --- 1) Drop the hook script (shared by both tools) ---
HOOK_DIR="$HOME/.agent-time-hook"
mkdir -p "$HOOK_DIR"
SCRIPT="$HOOK_DIR/inject-current-time.sh"
cat > "$SCRIPT" <<'SH'
#!/usr/bin/env bash
now=$(LC_TIME=C date '+%Y-%m-%d %H:%M:%S, %A, UTC%z')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"Current local system time (real, via hook): %s. Authoritative for all date/time reasoning (today/tomorrow/yesterday, deadlines, age/duration); do NOT extrapolate from earlier messages."}}' "$now"
SH
chmod +x "$SCRIPT"
echo "Hook script: $SCRIPT"

command -v python3 >/dev/null 2>&1 || { echo "[!] python3 not found - please install it or add the hook manually (see README)."; exit 1; }

merge() {
  python3 - "$1" "$SCRIPT" "$2" <<'PY'
import json, os, sys, shutil
config, script, label = sys.argv[1], sys.argv[2], sys.argv[3]
data = {}
if os.path.exists(config):
    try:
        with open(config, encoding="utf-8") as f:
            t = f.read().strip()
            data = json.loads(t) if t else {}
    except Exception:
        print(f"  [!] {label}: {config} is not valid JSON - skipped (add the hook manually)."); sys.exit(0)
hooks = data.setdefault("hooks", {})
ups = hooks.setdefault("UserPromptSubmit", [])
for grp in ups:
    for h in grp.get("hooks", []):
        if "inject-current-time" in (h.get("command","") + " " + " ".join(h.get("args", []))):
            print(f"  {label}: already installed - nothing to do."); sys.exit(0)
ups.append({"hooks": [{"type": "command", "command": "bash", "args": [script], "timeout": 10, "statusMessage": "Getting real time..."}]})
os.makedirs(os.path.dirname(config), exist_ok=True)
had = os.path.exists(config)
if had:
    shutil.copyfile(config, config + ".bak")
with open(config, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print(f"  {label}: registered -> {config}" + ("  (backup .bak written)" if had else ""))
PY
}

ANY=0
[ -d "$HOME/.claude" ] && { merge "$HOME/.claude/settings.json" "Claude Code"; ANY=1; }
[ -d "$HOME/.codex" ]  && { merge "$HOME/.codex/hooks.json"   "Codex";       ANY=1; }

echo
if [ "$ANY" -eq 0 ]; then
  echo "Neither ~/.claude nor ~/.codex found. Start Claude Code or Codex once, then run this installer again."
else
  echo "Done! Start a new session and ask:  'What day and time is it right now?'  (must match your system clock)."
fi
