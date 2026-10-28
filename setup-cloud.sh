#!/usr/bin/env bash
# Installe mes skills Claude Code (+ hooks ponytail et Hallmark) dans ~/.claude.
# Prévu pour le script de démarrage des environnements cloud ; marche aussi sur Linux/macOS.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$DEST/skills"

cp -R "$SRC/skills/." "$DEST/skills/"
rm -rf "$DEST/hooks-src" && cp -R "$SRC/hooks-src" "$DEST/hooks-src"
# Ne remplace pas un CLAUDE.md déjà présent : ajoute seulement le déclencheur graphify s'il manque.
grep -qs "skills/graphify" "$DEST/CLAUDE.md" || cat "$SRC/CLAUDE.md" >> "$DEST/CLAUDE.md"

# Programme graphify (le skill en a besoin).
VENV="$HOME/.local/share/graphify-venv"
if ! command -v graphify >/dev/null && [ ! -x "$HOME/.local/bin/graphify" ]; then
  python3 -m pip install -q --user "graphifyy==0.9.97" 2>/dev/null \
    || python3 -m pip install -q --user --break-system-packages "graphifyy==0.9.97" 2>/dev/null \
    || { python3 -m venv "$VENV" && "$VENV/bin/pip" install -q "graphifyy==0.9.97" \
         && mkdir -p "$HOME/.local/bin" && ln -sf "$VENV/bin/graphify" "$HOME/.local/bin/graphify"; } \
    || echo "!! graphify non installé (ni pip ni venv) : le skill graphify ne pourra pas construire de graphe"
fi

# Hooks dans settings.json (idempotent). Ils ont besoin de node ; sans node on les saute.
if command -v node >/dev/null; then
  DEST="$DEST" python3 - <<'EOF'
import json, os
dest = os.environ["DEST"]
sp = os.path.join(dest, "settings.json")
s = json.load(open(sp)) if os.path.exists(sp) else {}
hooks = s.setdefault("hooks", {})
pt = os.path.join(dest, "hooks-src", "ponytail", "hooks")
hm = os.path.join(dest, "skills", "hallmark", "scripts", "lint-hook.mjs")
mine = {
    "SessionStart": {"matcher": "startup|resume|clear|compact", "hooks": [{"type": "command", "command": f'node "{pt}/ponytail-activate.js"', "timeout": 15}]},
    "SubagentStart": {"hooks": [{"type": "command", "command": f'node "{pt}/ponytail-subagent.js"', "timeout": 15}]},
    "UserPromptSubmit": {"hooks": [{"type": "command", "command": f'node "{pt}/ponytail-mode-tracker.js"', "timeout": 15}]},
    "PostToolUse": {"matcher": "Write|Edit|MultiEdit", "hooks": [{"type": "command", "command": f'node "{hm}"', "timeout": 10}]},
}
for ev, entry in mine.items():
    cmd = entry["hooks"][0]["command"]
    lst = hooks.setdefault(ev, [])
    if not any(h.get("command") == cmd for e in lst for h in e.get("hooks", [])):
        lst.append(entry)
json.dump(s, open(sp, "w"), indent=2)
EOF
else
  echo "!! node absent : skills installés, mais pas les hooks ponytail/Hallmark"
fi

echo "claude-config : $(ls "$SRC/skills" | wc -l) skills installés dans $DEST/skills"
