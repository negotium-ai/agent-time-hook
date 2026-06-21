# Agent Time Hook 🕐 — für Claude Code & Codex

> Ein winziger Hook, der **Claude Code** (Anthropic) und **OpenAI Codex** bei *jeder* Nachricht die echte lokale Systemzeit gibt — damit die KI bei Fristen, Terminen und „heute/morgen" nicht mehr rät.

*🇬🇧 English version: **[README.md](README.md)***

Claude Code und Codex bekommen beim Start nur ein grobes Datum — keine Uhrzeit, keinen Wochentag, keine Sekunde. Bei allem Zeitabhängigen rät die KI dann oder rechnet aus älteren Nachrichten hoch. Dieser Hook behebt das in 5 Minuten. Die Zeit wird im **ISO-Format + Zeitzone** injiziert (z. B. `2026-06-21 19:13, UTC+02:00`), auf Basis der lokalen Zeit des jeweiligen Rechners — ein Nutzer in Toronto bekommt Toronto-Zeit.

**Gut zu wissen:** Beide Tools nutzen exakt dasselbe Hook-Format (`UserPromptSubmit` → `hookSpecificOutput.additionalContext`). Ein Skript, eingetragen im jeweils genutzten Tool.

## 🚀 Schnell-Installation (ein Befehl)

Legt das Hook-Skript ab und trägt es in deine vorhandene **Claude-Code- und/oder Codex-Konfig** ein. Mergt sauber (überschreibt nichts), legt vorher ein Backup an, mehrfach ausführbar.

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.ps1 | iex
```

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.sh | bash
```

**🔒 Lieber erst anschauen?** Code aus dem Netz blind auszuführen ist immer ein Vertrauensvorschuss. Auf Nummer sicher: herunterladen → lesen → ausführen:
```powershell
# Windows
irm https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.ps1 -OutFile install.ps1
# install.ps1 prüfen, dann:  ./install.ps1
```
```bash
# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/negotium-ai/agent-time-hook/main/install.sh -o install.sh
# install.sh prüfen, dann:  bash install.sh
```

## 📄 Alternative: PDF an deine KI geben

Keine Lust, es selbst zu machen? Lade die beiliegende **[PDF-Anleitung](Agent-Time-Hook-Anleitung.pdf)** als *Kontext* in deine KI (Claude, ChatGPT …) — dann hat sie alles, um dir bei der Einrichtung zu helfen, ohne dich mit Rückfragen zu löchern. Du behältst die Kontrolle; geändert wird erst, wenn du es möchtest.

## 🛠️ Oder komplett von Hand

### Schritt 1 — Skript anlegen
**Windows:** [`inject-current-time.ps1`](inject-current-time.ps1) (z. B. nach `C:\Tools\`). **macOS/Linux:** [`inject-current-time.sh`](inject-current-time.sh) (z. B. nach `~/.config/`). Das Skript ist für beide Tools identisch.

### Schritt 2 — Hook registrieren
Derselbe `hooks`-Block, nur die Datei unterscheidet sich:

| Tool | Datei |
|---|---|
| **Claude Code** | `~/.claude/settings.json` (vorhandenen `"hooks"`-Block ergänzen) |
| **Codex** | `~/.codex/hooks.json` (eigene Hook-Datei) |

**Windows-Block:**
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

**macOS/Linux-Block** (absoluten Skriptpfad einsetzen):
```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ {
        "type": "command",
        "command": "bash",
        "args": ["/home/NUTZER/.config/inject-current-time.sh"],
        "timeout": 10,
        "statusMessage": "Getting real time..."
      } ] }
    ]
  }
}
```

## ✅ Test
Neue Session, fragen: **„Welcher Wochentag und welche Uhrzeit ist gerade?"** — muss exakt deine Systemuhr treffen.

## 🔍 Wie es funktioniert
Claude Code und Codex lösen bei jeder Nachricht das `UserPromptSubmit`-Event aus. Der Hook ruft ein kleines Skript auf, das die Systemzeit als JSON im Feld `hookSpecificOutput.additionalContext` ausgibt — der von beiden Tools vorgesehene Weg, Kontext hinzuzufügen. Docs: [Claude Code Hooks](https://code.claude.com/docs/en/hooks) · [Codex Hooks](https://developers.openai.com/codex/hooks).

## ⚠️ Sicherheit
Hooks führen Befehle mit deinen vollen Benutzerrechten aus — *nicht* in einer Sandbox. Übernimm Hook-Konfigurationen nur aus Quellen, denen du vertraust, und sieh dir das Skript vorher an. In Claude Code zeigt `/hooks` alle aktiven Hooks; Codex zeigt nicht-verwaltete Hooks vor dem ersten Lauf zur Bestätigung.

## 📦 Repo-Inhalt
| Datei | Zweck |
|---|---|
| `install.ps1` / `install.sh` | Ein-Befehl-Installer (Windows / macOS-Linux) |
| `inject-current-time.ps1` / `.sh` | Hook-Skript (Windows / macOS-Linux) |
| `Agent-Time-Hook-Guide.pdf` / `…-Anleitung.pdf` | In sich geschlossene Anleitung (EN / DE), auch als KI-Kontext nutzbar |
| `guide.en.md` / `guide.de.md` / `build_pdf.py` | Quellen, aus denen die PDFs gebaut werden |

## Lizenz
[MIT](LICENSE) — frei verwendbar.

## Marken & Haftungsausschluss
Claude Code und Anthropic sind Marken von Anthropic, PBC; Codex und OpenAI sind Marken von OpenAI, Inc.; GitHub ist eine Marke von GitHub, Inc. Dies ist ein unabhängiges, kostenloses Community-Projekt — es steht in **keiner Verbindung zu** Anthropic, OpenAI oder GitHub und wird von diesen weder unterstützt noch gesponsert. Produktnamen dienen ausschließlich der Beschreibung der Kompatibilität. Die Software wird „wie besehen" ohne jegliche Gewähr bereitgestellt (siehe [LICENSE](LICENSE)).
