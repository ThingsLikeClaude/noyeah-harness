#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# noyeah-harness uninstaller (macOS / Linux)
# Removes symlinks only — never deletes source files
# ─────────────────────────────────────────────

CLAUDE_DIR="$HOME/.claude"
META_FILE="$CLAUDE_DIR/.noyeah-meta.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║  noyeah-harness installer            ║"
  echo "║  No? Yeah. 시키면 끝까지 한다.        ║"
  echo "╚══════════════════════════════════════╝"
  echo ""
  echo "  Mode: UNINSTALL"
  echo ""
}

info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $1"; exit 1; }

# ── Preflight ────────────────────────────────
preflight() {
  if [[ ! -f "$META_FILE" ]]; then
    fail "noyeah-harness is not installed (.noyeah-meta.json not found)"
  fi

  info "Found noyeah-harness installation metadata."
}

# ── Remove symlinks ─────────────────────────
remove_symlinks() {
  info "Removing symlinks..."

  local items=("agents" "skills" "hooks" "rules" "CLAUDE.md" "settings.json")

  for item in "${items[@]}"; do
    local target="$CLAUDE_DIR/$item"

    if [[ -L "$target" ]]; then
      rm "$target"
      ok "Removed symlink: $target"
    elif [[ -e "$target" ]]; then
      warn "$target exists but is not a symlink. Skipping (not managed by harness)."
    fi
  done
}

# ── Remove metadata ─────────────────────────
remove_meta() {
  info "Removing metadata..."

  if [[ -f "$META_FILE" ]]; then
    rm "$META_FILE"
    ok "Removed $META_FILE"
  fi
}

# ── Find backups ─────────────────────────────
find_backups() {
  local backups
  backups=$(ls -d "$HOME"/.claude.backup.* 2>/dev/null || true)

  if [[ -n "$backups" ]]; then
    echo ""
    echo -e "${CYAN}  Available backups:${NC}"
    echo "$backups" | while read -r dir; do
      echo "    $dir"
    done
    echo ""
    echo "  To restore a backup:"
    echo "    rm -rf ~/.claude"
    echo "    mv ~/.claude.backup.YYYYMMDD_HHMMSS ~/.claude"
    echo ""
  else
    echo ""
    echo "  No backups found."
    echo "  If you need to restore, check if ~/.claude/ has .bak files."
    echo ""
  fi
}

# ── Main ─────────────────────────────────────
main() {
  banner
  preflight
  remove_symlinks
  remove_meta

  echo ""
  echo -e "${GREEN}════════════════════════════════════════${NC}"
  echo -e "${GREEN}  Uninstall complete!${NC}"
  echo -e "${GREEN}════════════════════════════════════════${NC}"

  find_backups

  echo "  Note: Your harness source files are untouched."
  echo "  Note: settings.local.json was preserved (user config)."
  echo "  Note: .harness/ runtime state (if any) was not removed."
  echo ""
}

main "$@"
