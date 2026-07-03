#!/usr/bin/env bash
# Desinstalador para macOS / Linux.
# Quita los symlinks de skills, el de mcp.json y la entrada de PATH.
# No borra tus backups de mcp.json.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="${HOME}/.cursor"
SKILLS_DIR="${CURSOR_DIR}/skills"

info() { printf '\033[0;36m[uninstall]\033[0m %s\n' "$*"; }

# 1) Skills: borra solo symlinks que apunten al repo
if [ -d "$SKILLS_DIR" ]; then
  for skill in "$REPO_DIR"/skills/*/; do
    [ -d "$skill" ] || continue
    name="$(basename "$skill")"
    link="$SKILLS_DIR/$name"
    if [ -L "$link" ]; then
      rm -f "$link"
      info "skill desenlazada: $name"
    fi
  done
fi

# 2) MCP: borra el symlink si apunta al repo
target="$CURSOR_DIR/mcp.json"
if [ -L "$target" ]; then
  dest="$(readlink "$target")"
  case "$dest" in
    "$REPO_DIR"/*) rm -f "$target"; info "mcp.json desenlazado" ;;
  esac
fi

# 3) Rules (harness): borra symlinks que apunten al repo
RULES_DIR="$CURSOR_DIR/rules"
if [ -d "$REPO_DIR/harness/rules" ] && [ -d "$RULES_DIR" ]; then
  for rule in "$REPO_DIR"/harness/rules/*.mdc; do
    [ -e "$rule" ] || continue
    link="$RULES_DIR/$(basename "$rule")"
    if [ -L "$link" ]; then rm -f "$link"; info "regla desenlazada: $(basename "$rule")"; fi
  done
fi

# 4) Hooks (harness): borra los enlaces si apuntan al repo
for h in "$CURSOR_DIR/hooks.json" "$CURSOR_DIR/hooks"; do
  if [ -L "$h" ]; then
    dest="$(readlink "$h")"
    case "$dest" in
      "$REPO_DIR"/*) rm -f "$h"; info "hook desenlazado: $(basename "$h")" ;;
    esac
  fi
done

# 5) PATH: elimina el bloque del perfil
for profile in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
  [ -f "$profile" ] || continue
  if grep -qF "# >>> skills-jorge tools >>>" "$profile"; then
    tmp="$(mktemp)"
    sed '/# >>> skills-jorge tools >>>/,/# <<< skills-jorge tools <<</d' "$profile" > "$tmp"
    mv "$tmp" "$profile"
    info "PATH limpiado en $profile"
  fi
done

info "Listo. Reinicia Cursor y tu terminal."
