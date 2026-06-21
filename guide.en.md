<!-- KICKER: Hook for Claude Code & Codex -->
<!-- TITLE: Give Claude Code & Codex the real current time -->
<!-- SUBTITLE: A tiny hook feeds your AI the real system time on every message — so it stops guessing dates and deadlines. Works in Claude Code AND OpenAI Codex. -->
<!-- DATE: As of June 2026 -->

<div class="banner">🤖 <strong>Tip:</strong> You don't have to work through this yourself. Just attach this PDF to your AI (Claude, ChatGPT, etc.) as <strong>context</strong> — it then has everything to help you set it up without bombarding you with questions. You stay in control: the AI only acts when you ask it to. <em>(Prefer one command? See "Quick install" below — done in a minute.)</em></div>

<div class="einordnung"><strong>First — is this for you?</strong><br>
<strong>Claude Code</strong> (Anthropic) and <strong>Codex</strong> (OpenAI) are the tools where the AI works directly on your machine (files, projects, automation) — not the regular chat apps in the browser. Both use the same hook system, so this trick works in <strong>both</strong>.<br>
&bull; <strong>Using Claude Code or Codex?</strong> Then this is a 5-minute upgrade.<br>
&bull; <strong>Not yet?</strong> Then take the underlying trick with you: attach a complete reference document as context so the AI can help without follow-up questions. Works with any topic and any AI.</div>

## 🚀 Quick install (one command)

Drops the hook script and registers it in your existing **Claude Code and/or Codex** config. Merges cleanly (overwrites nothing), writes a backup first, safe to re-run.

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.ps1 | iex
```

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.sh | bash
```

**🔒 Prefer to look first?** Running code straight from the internet is always a leap of faith. To be safe, download the script, read it, then run it — the exact commands are in the README.

## The problem

Claude Code and Codex only receive a rough date at startup — **no time, no weekday, no seconds.** For anything time-dependent ("what's due by tomorrow morning?", "how long ago was that?", "when does the deadline expire?") the AI starts to **guess** or extrapolate from older messages. Unreliable — and you often notice only once a date is wrong.

## The fix in one sentence

A small **hook** — a script the AI runs automatically on every message — reads the real system time and puts it into context. So the time is **always there**: to the second, with weekday and timezone in ISO 8601 (e.g. `2026-06-21 13:13, UTC-04:00`), using the machine's own local time — a user in Toronto gets Toronto time. Both tools share the same hook format, so you only need **one** script.

## Set up by hand

### Step 1 — Save the script

**Windows:** save `inject-current-time.ps1`, e.g. to `C:\Tools\`.
**macOS/Linux:** save `inject-current-time.sh`, e.g. to `~/.config/`.
The script is identical for both tools.

### Step 2 — Register the hook

Same `hooks` block — only the **file** differs per tool:
- **Claude Code:** `~/.claude/settings.json` (extend an existing `"hooks"` block, don't overwrite)
- **Codex:** `~/.codex/hooks.json` (its own hook file)

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ {
        "type": "command",
        "command": "powershell.exe",
        "args": ["-NoProfile","-ExecutionPolicy","Bypass","-File","C:\\Tools\\inject-current-time.ps1"],
        "timeout": 10,
        "statusMessage": "Getting real time..."
      } ] }
    ]
  }
}
```

On macOS/Linux use `"command": "bash"` with `"args": ["/home/USER/.config/inject-current-time.sh"]` instead.

## Test

Start a new session and ask: **"What day and time is it right now?"** The answer must match your system clock exactly. If it does, the hook works.

> ⚠️ **Security note:** Hooks run commands with your full user privileges — they are *not* sandboxed. Only use hook configurations (whether by hand or via an AI) from sources you trust, and review the script first. In Claude Code, `/hooks` lists all active hooks; Codex shows non-managed hooks for confirmation before the first run.

## Sources

Official docs: **Claude Code Hooks** (code.claude.com/docs/en/hooks) and **Codex Hooks** (developers.openai.com/codex/hooks). Both use the same `UserPromptSubmit` + `hookSpecificOutput.additionalContext` format.
