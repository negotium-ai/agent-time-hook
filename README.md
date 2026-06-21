# Agent Time Hook 🕐 — for Claude Code & Codex

> A tiny hook that feeds **Claude Code** (Anthropic) and **OpenAI Codex** the real local system time on *every* message — so the AI stops guessing dates, deadlines and "today/tomorrow".

*🇩🇪 Deutsche Version: **[README.de.md](README.de.md)***

Claude Code and Codex only get a rough date at startup — no time, no weekday, no seconds. For anything time-dependent the AI then guesses or extrapolates from older messages. This hook fixes that in 5 minutes. The time is injected in **ISO 8601 + timezone** (e.g. `2026-06-21 13:13, UTC-04:00`) using the machine's own local time — a user in Toronto gets Toronto time.

**Good to know:** Both tools use the exact same hook format (`UserPromptSubmit` → `hookSpecificOutput.additionalContext`). One script, registered in whichever tool you use.

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

**🔒 Prefer to look first?** Running code straight from the internet is always a leap of faith. To be safe, download → read → run:
```powershell
# Windows
irm https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.ps1 -OutFile install.ps1
# review install.ps1, then:  ./install.ps1
```
```bash
# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.sh -o install.sh
# review install.sh, then:  bash install.sh
```

## 📄 Alternative: hand the PDF to your AI

Don't want to do it yourself? Load the included **[PDF guide](Agent-Time-Hook-Guide.pdf)** into your AI (Claude, ChatGPT, …) as *context* — it then has everything to help you set it up, without bombarding you with questions. You stay in control; nothing is changed until you ask.

## 🛠️ Or fully by hand

### Step 1 — Save the script
**Windows:** [`inject-current-time.ps1`](inject-current-time.ps1) (e.g. to `C:\Tools\`). **macOS/Linux:** [`inject-current-time.sh`](inject-current-time.sh) (e.g. to `~/.config/`). Same script for both tools.

### Step 2 — Register the hook
Same `hooks` block, only the file differs:

| Tool | File |
|---|---|
| **Claude Code** | `~/.claude/settings.json` (extend an existing `"hooks"` block) |
| **Codex** | `~/.codex/hooks.json` (its own hook file) |

**Windows block:**
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

**macOS/Linux block** (insert your absolute script path):
```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ {
        "type": "command",
        "command": "bash",
        "args": ["/home/USER/.config/inject-current-time.sh"],
        "timeout": 10,
        "statusMessage": "Getting real time..."
      } ] }
    ]
  }
}
```

## ✅ Test
New session, ask: **"What day and time is it right now?"** — must match your system clock exactly.

## 🔍 How it works
Claude Code and Codex fire the `UserPromptSubmit` event on every message. The hook runs a small script that prints the system time as JSON in the `hookSpecificOutput.additionalContext` field — the supported way (in both tools) to add context. Docs: [Claude Code Hooks](https://code.claude.com/docs/en/hooks) · [Codex Hooks](https://developers.openai.com/codex/hooks).

## ⚠️ Security
Hooks run commands with your full user privileges — *not* sandboxed. Only use hook configs from sources you trust, and review the script first. In Claude Code, `/hooks` lists all active hooks; Codex shows non-managed hooks for confirmation before the first run.

## 📦 Repo contents
| File | Purpose |
|---|---|
| `install.ps1` / `install.sh` | One-command installer (Windows / macOS-Linux) |
| `inject-current-time.ps1` / `.sh` | Hook script (Windows / macOS-Linux) |
| `Agent-Time-Hook-Guide.pdf` / `…-Anleitung.pdf` | Self-contained guide (EN / DE), also usable as AI context |
| `guide.en.md` / `guide.de.md` / `build_pdf.py` | Sources the PDFs are built from |

## License
[MIT](LICENSE) — free to use.

## Trademarks & disclaimer
Claude Code and Anthropic are trademarks of Anthropic, PBC; Codex and OpenAI are trademarks of OpenAI, Inc.; GitHub is a trademark of GitHub, Inc. This is an independent, free community project — **not affiliated with, endorsed by, or sponsored by** Anthropic, OpenAI or GitHub. Product names are used only to describe compatibility. The software is provided "as is", without warranty of any kind (see [LICENSE](LICENSE)).
