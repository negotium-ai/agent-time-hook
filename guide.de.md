<!-- KICKER: Hook für Claude Code & Codex -->
<!-- TITLE: Claude Code & Codex die echte Uhrzeit beibringen -->
<!-- SUBTITLE: Ein winziger Hook gibt deiner KI bei jeder Nachricht die echte Systemzeit — statt bei Fristen und Terminen zu raten. Funktioniert in Claude Code UND OpenAI Codex. -->
<!-- DATE: Stand: Juni 2026 -->

<div class="banner">🤖 <strong>Tipp:</strong> Du musst das hier nicht selbst durcharbeiten. Häng dieses PDF deiner KI (Claude, ChatGPT o.&nbsp;Ä.) einfach als <strong>Kontext</strong> an — dann hat sie alles, um dir bei der Einrichtung zu helfen, ohne dich mit Rückfragen zu löchern. Du behältst die Kontrolle: Die KI legt erst Hand an, wenn du sie darum bittest. <em>(Lieber ein Befehl? Siehe „Schnell-Installation" unten — in einer Minute erledigt.)</em></div>

<div class="einordnung"><strong>Kurz vorab — ist das was für dich?</strong><br>
<strong>Claude Code</strong> (Anthropic) und <strong>Codex</strong> (OpenAI) sind die Werkzeuge, mit denen die KI direkt auf deinem Rechner arbeitet (Dateien, Projekte, Automatisierung) — nicht die normalen Chat-Apps im Browser. Beide nutzen dasselbe Hook-System, daher funktioniert dieser Trick in <strong>beiden</strong>.<br>
&bull; <strong>Du nutzt Claude Code oder Codex?</strong> Dann ist das ein 5-Minuten-Upgrade.<br>
&bull; <strong>Noch nicht?</strong> Dann nimm den eigentlichen Kniff mit: ein vollständiges Fachdokument als Kontext an die KI hängen, damit sie ohne Rückfragen helfen kann. Das funktioniert mit jedem Thema und jeder KI.</div>

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

**🔒 Lieber erst anschauen?** Code aus dem Netz blind auszuführen ist immer ein Vertrauensvorschuss. Auf Nummer sicher: Skript erst herunterladen, lesen, dann ausführen — die genauen Befehle stehen im README.

## Das Problem

Claude Code und Codex bekommen beim Start nur ein grobes Datum mitgeliefert — **keine Uhrzeit, keinen Wochentag, keine Sekunde.** Bei allem Zeitabhängigen („Was ist bis morgen früh fällig?", „Wie lange ist das her?", „Wann läuft die Frist ab?") fängt die KI deshalb an zu **raten** oder aus älteren Nachrichten hochzurechnen. Unzuverlässig — und man merkt es oft erst, wenn ein Datum falsch ist.

## Die Lösung in einem Satz

Ein kleiner **Hook** — ein Skript, das die KI bei *jeder* Nachricht automatisch aufruft — liest die echte Systemzeit aus und legt sie in den Kontext. So ist die Zeit **immer da**: sekundengenau, mit Wochentag und Zeitzone im ISO-Format (z. B. `2026-06-21 19:13, UTC+02:00`), basierend auf der lokalen Zeit des jeweiligen Rechners — ein Nutzer in Toronto bekommt Toronto-Zeit. Beide Tools teilen sich dasselbe Hook-Format, du brauchst also nur **ein** Skript.

## Von Hand einrichten

### Schritt 1 — Skript anlegen

**Windows:** `inject-current-time.ps1` speichern, z. B. nach `C:\Tools\`.
**macOS/Linux:** `inject-current-time.sh` speichern, z. B. nach `~/.config/`.
Das Skript ist für beide Tools identisch.

### Schritt 2 — Hook registrieren

Derselbe `hooks`-Block — nur die **Datei** unterscheidet sich je Tool:
- **Claude Code:** `~/.claude/settings.json` (vorhandenen `"hooks"`-Block ergänzen, nicht überschreiben)
- **Codex:** `~/.codex/hooks.json` (eigene Hook-Datei)

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

Auf macOS/Linux stattdessen `"command": "bash"` mit `"args": ["/home/NUTZER/.config/inject-current-time.sh"]`.

## Test

Neue Session öffnen und fragen: **„Welcher Wochentag und welche Uhrzeit ist gerade?"** Die Antwort muss exakt deine Systemuhr treffen. Wenn ja, läuft der Hook.

> ⚠️ **Sicherheitshinweis:** Hooks führen Befehle mit deinen vollen Benutzerrechten aus — sie laufen *nicht* in einer Sandbox. Übernimm Hook-Konfigurationen (egal ob von Hand oder mit Hilfe einer KI) nur aus Quellen, denen du vertraust, und sieh dir das Skript vorher an. In Claude Code zeigt `/hooks` alle aktiven Hooks; Codex zeigt nicht-verwaltete Hooks vor dem ersten Lauf zur Bestätigung.

## Quellen

Offizielle Doku: **Claude Code Hooks** (code.claude.com/docs/en/hooks) und **Codex Hooks** (developers.openai.com/codex/hooks). Beide nutzen dasselbe `UserPromptSubmit` + `hookSpecificOutput.additionalContext`-Format.
