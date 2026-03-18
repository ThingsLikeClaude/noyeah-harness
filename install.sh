#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# noyeah-harness installer (macOS / Linux)
# ─────────────────────────────────────────────

HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
META_FILE="$CLAUDE_DIR/.noyeah-meta.json"
SETTINGS_TEMPLATE="$HARNESS_DIR/hooks/settings-template.json"

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
}

info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $1"; exit 1; }

# ── Step 1: Check dependencies ──────────────
check_deps() {
  info "Step 1/8: Checking dependencies..."

  if ! command -v node &>/dev/null; then
    fail "node is not installed. Install Node.js first: https://nodejs.org"
  fi
  ok "node $(node --version)"

  if ! command -v git &>/dev/null; then
    fail "git is not installed. Install git first: https://git-scm.com"
  fi
  ok "git $(git --version | awk '{print $3}')"
}

# ── Step 2: Detect conflicts ────────────────
detect_conflicts() {
  info "Step 2/8: Detecting conflicts..."

  if [[ -f "$CLAUDE_DIR/.forge-meta.json" ]]; then
    warn "Found .forge-meta.json — another harness (claude-forge?) is installed."
    warn "noyeah-harness may overwrite its symlinks."
    echo ""
    read -rp "Continue anyway? (y/N): " answer
    if [[ "${answer,,}" != "y" ]]; then
      fail "Aborted by user."
    fi
  fi

  if [[ -f "$META_FILE" ]]; then
    warn "noyeah-harness is already installed. Re-running will overwrite symlinks."
  fi

  ok "No blocking conflicts."
}

# ── Step 3: Backup existing ~/.claude/ ───────
backup_claude() {
  info "Step 3/8: Backing up existing ~/.claude/..."

  if [[ -d "$CLAUDE_DIR" ]]; then
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$HOME/.claude.backup.${timestamp}"
    cp -a "$CLAUDE_DIR" "$backup_dir"
    ok "Backed up to $backup_dir"
  else
    mkdir -p "$CLAUDE_DIR"
    ok "Created $CLAUDE_DIR (no backup needed)"
  fi
}

# ── Step 4: Create symlinks ─────────────────
create_symlinks() {
  info "Step 4/8: Creating symlinks..."

  local items=("agents" "skills" "hooks" "CLAUDE.md")

  # Include rules/ only if it has content
  if [[ -d "$HARNESS_DIR/rules" ]] && [[ -n "$(ls -A "$HARNESS_DIR/rules" 2>/dev/null)" ]]; then
    items+=("rules")
  fi

  for item in "${items[@]}"; do
    local src="$HARNESS_DIR/$item"
    local dst="$CLAUDE_DIR/$item"

    if [[ ! -e "$src" ]]; then
      warn "Source not found, skipping: $src"
      continue
    fi

    # Remove existing target (symlink or directory)
    if [[ -L "$dst" ]]; then
      rm "$dst"
    elif [[ -e "$dst" ]]; then
      warn "$dst exists and is not a symlink. Moving to ${dst}.bak"
      mv "$dst" "${dst}.bak"
    fi

    ln -s "$src" "$dst"
    ok "Linked $dst -> $src"
  done
}

# ── Step 5: Handle settings.json ─────────────
handle_settings() {
  info "Step 5/8: Handling settings.json..."

  local dst="$CLAUDE_DIR/settings.json"

  if [[ -e "$dst" ]]; then
    warn "settings.json already exists. Skipping to avoid overwriting your config."
    warn "Review $SETTINGS_TEMPLATE and merge manually if needed."
  else
    if [[ -f "$SETTINGS_TEMPLATE" ]]; then
      ln -s "$SETTINGS_TEMPLATE" "$dst"
      ok "Linked settings.json -> $SETTINGS_TEMPLATE"
    else
      warn "No settings template found at $SETTINGS_TEMPLATE"
    fi
  fi
}

# ── Step 6: Create settings.local.json ───────
create_local_settings() {
  info "Step 6/8: Creating settings.local.json..."

  local dst="$CLAUDE_DIR/settings.local.json"

  if [[ -f "$dst" ]]; then
    ok "settings.local.json already exists. Skipping."
  else
    cat > "$dst" << 'LOCALJSON'
{
  "permissions": {
    "allow": [],
    "deny": []
  },
  "env": {}
}
LOCALJSON
    ok "Created $dst (customize as needed)"
  fi
}

# ── Step 7: Optional MCP install ─────────────
install_mcps() {
  info "Step 7/8: Optional MCP servers..."
  echo ""
  echo "  The following MCP servers are recommended:"
  echo "    1) @anthropic/claude-code-mcp-context7  (library docs)"
  echo "    2) @anthropic/claude-code-mcp-memory    (persistent memory)"
  echo "    3) @anthropic/claude-code-mcp-github    (GitHub integration)"
  echo ""
  read -rp "Install recommended MCP servers via npx? (y/N): " answer

  if [[ "${answer,,}" == "y" ]]; then
    if ! command -v npx &>/dev/null; then
      warn "npx not found. Skipping MCP install."
      return
    fi

    local servers=(
      "@anthropic-ai/claude-code-mcp-context7"
      "@anthropic-ai/claude-code-mcp-memory"
      "@anthropic-ai/claude-code-mcp-github"
    )

    for server in "${servers[@]}"; do
      info "Installing $server..."
      if npx -y "$server" install 2>/dev/null; then
        ok "Installed $server"
      else
        warn "Failed to install $server (you can install manually later)"
      fi
    done
  else
    ok "Skipped MCP install."
  fi
}

# ── Step 8: Write metadata ──────────────────
write_meta() {
  info "Step 8/8: Writing metadata..."

  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local version
  version=$(git -C "$HARNESS_DIR" describe --tags 2>/dev/null || echo "dev")
  local commit
  commit=$(git -C "$HARNESS_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")

  cat > "$META_FILE" << METAJSON
{
  "harness": "noyeah-harness",
  "version": "$version",
  "commit": "$commit",
  "installed_at": "$now",
  "harness_dir": "$HARNESS_DIR",
  "symlinks": {
    "agents": "$CLAUDE_DIR/agents",
    "skills": "$CLAUDE_DIR/skills",
    "hooks": "$CLAUDE_DIR/hooks",
    "CLAUDE.md": "$CLAUDE_DIR/CLAUDE.md"
  }
}
METAJSON

  ok "Wrote $META_FILE"
}

# ── Main ─────────────────────────────────────
main() {
  banner
  check_deps
  detect_conflicts
  backup_claude
  create_symlinks
  handle_settings
  create_local_settings
  install_mcps
  write_meta

  echo ""
  echo -e "${GREEN}════════════════════════════════════════${NC}"
  echo -e "${GREEN}  Installation complete!${NC}"
  echo -e "${GREEN}════════════════════════════════════════${NC}"
  echo ""
  echo "  Next steps:"
  echo "    1. Restart Claude Code to load the new config"
  echo "    2. Run /noyeah-status to verify harness is active"
  echo "    3. Try /noyeah-ralph \"your first task\" to test"
  echo ""
}

main "$@"
