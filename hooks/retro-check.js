#!/usr/bin/env node
'use strict';
// retro-check.js -- PostToolUse hook (matcher: Write|Edit)
// Reminds to run /noyeah-retro after Ralph completes if no recent learnings exist.
// Exits 0 silently on any error (graceful no-op).

const fs = require('fs');
const path = require('path');
const process = require('process');

const RECENT_WINDOW_MS = 300_000; // 5 minutes

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => { resolve(data); });
    process.stdin.on('error', () => { resolve(''); });
  });
}

async function main() {
  const raw = await readStdin();
  if (!raw.trim()) { process.exit(0); }

  let input;
  try {
    input = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const filePath = (input.tool_input && input.tool_input.file_path) || '';
  if (!filePath.endsWith('ralph-state.json')) { process.exit(0); }

  let ralphState;
  try {
    const stateRaw = fs.readFileSync(filePath, 'utf8');
    ralphState = JSON.parse(stateRaw);
  } catch {
    process.exit(0);
  }

  if (ralphState.current_phase !== 'complete' || ralphState.active !== false) {
    process.exit(0);
  }

  const memoryPath = path.join(
    path.dirname(path.dirname(filePath)), // .harness/
    'memory',
    'project-memory.json'
  );

  let memory;
  try {
    const memRaw = fs.readFileSync(memoryPath, 'utf8');
    memory = JSON.parse(memRaw);
  } catch {
    // Memory file absent or unreadable — no recent learning by definition.
    memory = { entries: [] };
  }

  const now = Date.now();
  const entries = Array.isArray(memory.entries) ? memory.entries : [];
  const hasRecentLearning = entries.some((entry) => {
    if (entry.type !== 'learning') { return false; }
    if (!entry.timestamp) { return false; }
    const ts = new Date(entry.timestamp).getTime();
    return Number.isFinite(ts) && (now - ts) < RECENT_WINDOW_MS;
  });

  if (hasRecentLearning) { process.exit(0); }

  process.stdout.write(
    'Ralph completed. Run /noyeah-retro to capture learnings from this run.\n'
  );
  process.exit(0);
}

main().catch(() => { process.exit(0); });
