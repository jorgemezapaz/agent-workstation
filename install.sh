#!/usr/bin/env bash
# Instalador para macOS / Linux.
# Enlaza skills, mcp.json, reglas y hooks del harness a ~/.cursor y agrega tools/bin al PATH.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="${HOME}/.cursor"
SKILLS_DIR="${CURSOR_DIR}/skills"
TOOLS_BIN="${REPO_DIR}/tools/bin"

info() { printf '\033[0;36m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[warn]\033[0m %s\n' "$*"; }

mkdir -p "$SKILLS_DIR"

# 1) Skills -> symlink de cada carpeta en ~/.cursor/skills
info "Enlazando skills en $SKILLS_DIR"
for skill in "$REPO_DIR"/skills/*/; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  ln -sfn "${skill%/}" "$SKILLS_DIR/$name"
  info "  skill: $name"
done

# 2) MCP -> symlink de mcp.json (con backup del existente)
if [ -f "$REPO_DIR/mcps/mcp.json" ]; then
  target="$CURSOR_DIR/mcp.json"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    warn "mcp.json existente respaldado en: $backup"
  fi
  ln -sfn "$REPO_DIR/mcps/mcp.json" "$target"
  info "MCP enlazado -> $target"
fi

# 3) Rules (harness) -> symlink de cada .mdc en ~/.cursor/rules
if [ -d "$REPO_DIR/harness/rules" ]; then
  RULES_DIR="$CURSOR_DIR/rules"
  mkdir -p "$RULES_DIR"
  for rule in "$REPO_DIR"/harness/rules/*.mdc; do
    [ -e "$rule" ] || continue
    ln -sfn "$rule" "$RULES_DIR/$(basename "$rule")"
    info "  regla: $(basename "$rule")"
  done
fi

# 4) Hooks (harness) -> symlink de hooks.json y de la carpeta hooks
if [ -f "$REPO_DIR/harness/hooks.json" ]; then
  htarget="$CURSOR_DIR/hooks.json"
  if [ -e "$htarget" ] && [ ! -L "$htarget" ]; then
    mv "$htarget" "${htarget}.backup.$(date +%Y%m%d%H%M%S)"
    warn "hooks.json existente respaldado"
  fi
  ln -sfn "$REPO_DIR/harness/hooks.json" "$htarget"
  hdir="$CURSOR_DIR/hooks"
  if [ -e "$hdir" ] && [ ! -L "$hdir" ]; then
    mv "$hdir" "${hdir}.backup.$(date +%Y%m%d%H%M%S)"
    warn "carpeta hooks existente respaldada"
  fi
  ln -sfn "$REPO_DIR/harness/hooks" "$hdir"
  chmod +x "$REPO_DIR"/harness/hooks/*.js 2>/dev/null || true
  info "hooks del harness enlazados -> $htarget"
fi

# 5) Tools -> agregar tools/bin al PATH en el perfil del shell
if [ -d "$TOOLS_BIN" ]; then
  chmod +x "$TOOLS_BIN"/* 2>/dev/null || true
  case "${SHELL##*/}" in
    zsh)  profile="$HOME/.zshrc" ;;
    bash) profile="$HOME/.bashrc" ;;
    *)    profile="$HOME/.profile" ;;
  esac
  marker="# >>> agent-workstation tools >>>"
  [ -f "$profile" ] || touch "$profile"
  if ! grep -qF "$marker" "$profile"; then
    {
      echo ""
      echo "$marker"
      echo "export PATH=\"$TOOLS_BIN:\$PATH\""
      echo "# <<< agent-workstation tools <<<"
    } >> "$profile"
    info "tools/bin agregado al PATH en $profile (reinicia la terminal)"
  else
    info "tools/bin ya estaba en el PATH ($profile)"
  fi
fi

info "Listo. Reinicia Cursor y tu terminal para aplicar los cambios."
