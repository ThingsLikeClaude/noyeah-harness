# ─────────────────────────────────────────────
# noyeah-harness installer (Windows PowerShell)
# No admin required — uses Copy-Item
# ─────────────────────────────────────────────

$ErrorActionPreference = "Stop"

$HarnessDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$MetaFile = Join-Path $ClaudeDir ".noyeah-meta.json"
$SettingsTemplate = Join-Path $HarnessDir "hooks\settings-template.json"

function Show-Banner {
    Write-Host ""
    Write-Host ([char]0x2554 + [string]::new([char]0x2550, 38) + [char]0x2557)
    Write-Host ([char]0x2551 + "  noyeah-harness installer            " + [char]0x2551)
    Write-Host ([char]0x2551 + "  No? Yeah. " + [char]0xC2DC + [char]0xD0A4 + [char]0xBA74 + " " + [char]0xB05D + [char]0xAE4C + [char]0xC9C0 + " " + [char]0xD55C + [char]0xB2E4 + ".        " + [char]0x2551)
    Write-Host ([char]0x255A + [string]::new([char]0x2550, 38) + [char]0x255D)
    Write-Host ""
}

function Write-Info  { param($Msg) Write-Host "[INFO]  $Msg" -ForegroundColor Cyan }
function Write-Ok    { param($Msg) Write-Host "[OK]    $Msg" -ForegroundColor Green }
function Write-Warn  { param($Msg) Write-Host "[WARN]  $Msg" -ForegroundColor Yellow }
function Write-Fail  { param($Msg) Write-Host "[FAIL]  $Msg" -ForegroundColor Red; exit 1 }

# ── Step 1: Check dependencies ──────────────
function Test-Dependencies {
    Write-Info "Step 1/8: Checking dependencies..."

    try {
        $nodeVersion = & node --version 2>$null
        Write-Ok "node $nodeVersion"
    } catch {
        Write-Fail "node is not installed. Install Node.js first: https://nodejs.org"
    }

    try {
        $gitVersion = & git --version 2>$null
        Write-Ok "$gitVersion"
    } catch {
        Write-Fail "git is not installed. Install git first: https://git-scm.com"
    }
}

# ── Step 2: Detect conflicts ────────────────
function Test-Conflicts {
    Write-Info "Step 2/8: Detecting conflicts..."

    $forgeMeta = Join-Path $ClaudeDir ".forge-meta.json"
    if (Test-Path $forgeMeta) {
        Write-Warn "Found .forge-meta.json - another harness (claude-forge?) is installed."
        Write-Warn "noyeah-harness may overwrite its files."
        $answer = Read-Host "Continue anyway? (y/N)"
        if ($answer -ne "y") {
            Write-Fail "Aborted by user."
        }
    }

    if (Test-Path $MetaFile) {
        Write-Warn "noyeah-harness is already installed. Re-running will overwrite files."
    }

    Write-Ok "No blocking conflicts."
}

# ── Step 3: Backup existing ~/.claude/ ───────
function Backup-Claude {
    Write-Info "Step 3/8: Backing up existing ~/.claude/..."

    if (Test-Path $ClaudeDir) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupDir = Join-Path $env:USERPROFILE ".claude.backup.$timestamp"
        Copy-Item -Path $ClaudeDir -Destination $backupDir -Recurse -Force
        Write-Ok "Backed up to $backupDir"
    } else {
        New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
        Write-Ok "Created $ClaudeDir (no backup needed)"
    }
}

# ── Step 4: Copy files (no symlinks) ────────
function Copy-HarnessFiles {
    Write-Info "Step 4/8: Copying harness files..."

    $items = @("agents", "skills", "hooks", "CLAUDE.md")

    # Include rules/ only if it has content
    $rulesDir = Join-Path $HarnessDir "rules"
    if ((Test-Path $rulesDir) -and ((Get-ChildItem $rulesDir -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0)) {
        $items += "rules"
    }

    foreach ($item in $items) {
        $src = Join-Path $HarnessDir $item
        $dst = Join-Path $ClaudeDir $item

        if (-not (Test-Path $src)) {
            Write-Warn "Source not found, skipping: $src"
            continue
        }

        # Remove existing target
        if (Test-Path $dst) {
            if ((Get-Item $dst).PSIsContainer) {
                Remove-Item $dst -Recurse -Force
            } else {
                Remove-Item $dst -Force
            }
        }

        if ((Get-Item $src).PSIsContainer) {
            Copy-Item -Path $src -Destination $dst -Recurse -Force
        } else {
            Copy-Item -Path $src -Destination $dst -Force
        }

        Write-Ok "Copied $item -> $dst"
    }
}

# ── Step 5: Handle settings.json ─────────────
function Set-Settings {
    Write-Info "Step 5/8: Handling settings.json..."

    $dst = Join-Path $ClaudeDir "settings.json"

    if (Test-Path $dst) {
        Write-Warn "settings.json already exists. Skipping to avoid overwriting your config."
        Write-Warn "Review $SettingsTemplate and merge manually if needed."
    } else {
        if (Test-Path $SettingsTemplate) {
            Copy-Item -Path $SettingsTemplate -Destination $dst -Force
            Write-Ok "Copied settings.json from template"
        } else {
            Write-Warn "No settings template found at $SettingsTemplate"
        }
    }
}

# ── Step 6: Create settings.local.json ───────
function New-LocalSettings {
    Write-Info "Step 6/8: Creating settings.local.json..."

    $dst = Join-Path $ClaudeDir "settings.local.json"

    if (Test-Path $dst) {
        Write-Ok "settings.local.json already exists. Skipping."
    } else {
        $content = @'
{
  "permissions": {
    "allow": [],
    "deny": []
  },
  "env": {}
}
'@
        Set-Content -Path $dst -Value $content -Encoding UTF8
        Write-Ok "Created $dst (customize as needed)"
    }
}

# ── Step 7: Optional MCP install ─────────────
function Install-MCPs {
    Write-Info "Step 7/8: Optional MCP servers..."
    Write-Host ""
    Write-Host "  The following MCP servers are recommended:"
    Write-Host "    1) @anthropic/claude-code-mcp-context7  (library docs)"
    Write-Host "    2) @anthropic/claude-code-mcp-memory    (persistent memory)"
    Write-Host "    3) @anthropic/claude-code-mcp-github    (GitHub integration)"
    Write-Host ""
    $answer = Read-Host "Install recommended MCP servers via npx? (y/N)"

    if ($answer -eq "y") {
        $npxPath = Get-Command npx -ErrorAction SilentlyContinue
        if (-not $npxPath) {
            Write-Warn "npx not found. Skipping MCP install."
            return
        }

        $servers = @(
            "@anthropic-ai/claude-code-mcp-context7"
            "@anthropic-ai/claude-code-mcp-memory"
            "@anthropic-ai/claude-code-mcp-github"
        )

        foreach ($server in $servers) {
            Write-Info "Installing $server..."
            try {
                & npx -y $server install 2>$null
                Write-Ok "Installed $server"
            } catch {
                Write-Warn "Failed to install $server (you can install manually later)"
            }
        }
    } else {
        Write-Ok "Skipped MCP install."
    }
}

# ── Step 8: Write metadata ──────────────────
function Write-Metadata {
    Write-Info "Step 8/8: Writing metadata..."

    $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    try {
        $version = & git -C $HarnessDir describe --tags 2>$null
    } catch {
        $version = "dev"
    }
    if (-not $version) { $version = "dev" }

    try {
        $commit = & git -C $HarnessDir rev-parse --short HEAD 2>$null
    } catch {
        $commit = "unknown"
    }
    if (-not $commit) { $commit = "unknown" }

    $meta = @{
        harness = "noyeah-harness"
        version = $version
        commit = $commit
        installed_at = $now
        harness_dir = $HarnessDir
        install_method = "copy"
        symlinks = @{
            agents = Join-Path $ClaudeDir "agents"
            skills = Join-Path $ClaudeDir "skills"
            hooks = Join-Path $ClaudeDir "hooks"
            "CLAUDE.md" = Join-Path $ClaudeDir "CLAUDE.md"
        }
    } | ConvertTo-Json -Depth 3

    Set-Content -Path $MetaFile -Value $meta -Encoding UTF8
    Write-Ok "Wrote $MetaFile"
}

# ── Main ─────────────────────────────────────
function Main {
    Show-Banner
    Test-Dependencies
    Test-Conflicts
    Backup-Claude
    Copy-HarnessFiles
    Set-Settings
    New-LocalSettings
    Install-MCPs
    Write-Metadata

    Write-Host ""
    Write-Host "════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  Installation complete!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:"
    Write-Host "    1. Restart Claude Code to load the new config"
    Write-Host "    2. Run /noyeah-status to verify harness is active"
    Write-Host "    3. Try /noyeah-ralph `"your first task`" to test"
    Write-Host ""
    Write-Host "  NOTE: Windows uses file copies (not symlinks)."
    Write-Host "  After updating noyeah-harness, re-run this script to sync."
    Write-Host ""
}

Main
