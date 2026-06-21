# -*- coding: utf-8 -*-
# Baut aus anleitung.md eine schoene HTML (Deckblatt + Druck-CSS).
# PDF danach via Chrome headless --print-to-pdf (siehe Build-Befehl).
import markdown, re, pathlib, sys

HERE = pathlib.Path(__file__).parent
mdpath = HERE / (sys.argv[1] if len(sys.argv) > 1 else "anleitung.md")
src = mdpath.read_text(encoding="utf-8")

def meta(key, default=""):
    m = re.search(rf"<!--\s*{key}:\s*(.*?)\s*-->", src, re.S)
    return m.group(1).strip() if m else default

kicker   = meta("KICKER")
title    = meta("TITLE")
subtitle = meta("SUBTITLE")
date     = meta("DATE")

body_md = re.sub(r"<!--.*?-->", "", src, flags=re.S).strip()
html_body = markdown.markdown(body_md, extensions=["extra", "sane_lists"])

CSS = """
@page { size: A4; margin: 18mm 16mm; }
* { box-sizing: border-box; }
body { font-family: "Segoe UI", system-ui, sans-serif; color: #1a1a1a;
       font-size: 10.5pt; line-height: 1.5; margin: 0; }
.cover { height: 247mm; display: flex; flex-direction: column;
         justify-content: center; page-break-after: always; }
.kicker { color: #0159A1; font-weight: 700; letter-spacing: .14em;
          text-transform: uppercase; font-size: 10pt; margin-bottom: 1.4rem; }
.cover-title { font-size: 30pt; line-height: 1.15; margin: 0 0 1.3rem;
               color: #0d2b45; font-weight: 800; }
.cover-sub { font-size: 13pt; color: #555; font-weight: 400; max-width: 85%; line-height: 1.45; }
.cover-date { margin-top: auto; color: #777; font-size: 10pt;
              border-top: 3px solid #0159A1; padding-top: .7rem; width: 46mm; }
h2 { color: #0159A1; font-size: 15pt; margin: 1.7rem 0 .6rem; padding-bottom: .25rem;
     border-bottom: 2px solid #e3eef7; page-break-after: avoid; }
h3 { font-size: 12pt; margin: 1.1rem 0 .4rem; color: #0d2b45; page-break-after: avoid; }
p { margin: .55rem 0; }
a { color: #0159A1; text-decoration: none; }
strong { color: #0d2b45; }
code { font-family: Consolas, "Courier New", monospace; background: #f3f5f7;
       padding: .08em .35em; border-radius: 3px; font-size: 9.2pt; }
pre { background: #f6f8fa; border: 1px solid #dfe6ee; border-left: 3px solid #0159A1;
      border-radius: 5px; padding: .8rem 1rem; white-space: pre-wrap; word-break: break-word;
      font-size: 8.8pt; line-height: 1.45; page-break-inside: avoid; }
pre code { background: none; padding: 0; font-size: inherit; }
blockquote { background: #fff7e6; border: 1px solid #ffe2a8; border-left: 4px solid #f5a623;
             margin: 1.1rem 0; padding: .7rem 1rem; border-radius: 5px; color: #5c4408;
             page-break-inside: avoid; }
blockquote p { margin: .2rem 0; }
.banner { background: #eaf3fb; border: 1px solid #b8d8f0; border-left: 4px solid #0159A1;
          border-radius: 6px; padding: .85rem 1.1rem; margin: 0 0 1.3rem; font-size: 10pt;
          color: #0d2b45; line-height: 1.5; page-break-inside: avoid; }
.einordnung { background: #f4f6f8; border: 1px solid #dde3ea; border-radius: 6px;
              padding: .75rem 1.1rem; margin: 1.1rem 0; font-size: 9.8pt; color: #33414f;
              page-break-inside: avoid; }
.einordnung strong { color: #0d2b45; }
ul, ol { margin: .5rem 0; padding-left: 1.4rem; }
li { margin: .25rem 0; }
"""

html = f"""<!doctype html><html lang="de"><head><meta charset="utf-8">
<style>{CSS}</style></head><body>
<section class="cover">
  <div class="kicker">{kicker}</div>
  <h1 class="cover-title">{title}</h1>
  <p class="cover-sub">{subtitle}</p>
  <div class="cover-date">{date}</div>
</section>
<main>
{html_body}
</main></body></html>"""

out = mdpath.with_suffix(".html")
out.write_text(html, encoding="utf-8")
print("HTML geschrieben:", out)
