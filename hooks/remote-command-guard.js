#!/usr/bin/env node
'use strict';
// remote-command-guard.js -- PreToolUse(Bash) hook
// Blocks dangerous remote and destructive commands.
// Exit 2 = block the tool call. Exit 0 = allow.

const process = require('process');

const BLOCKED_PATTERNS = [
  /\bssh\b/,
  /\bscp\b/,
  /\brsync\b.*:/,
  /\bcurl\b.*\|\s*bash/,
  /\bwget\b.*\|\s*bash/,
  /\beval\b/,
  /\bnc\b/,
  /\brm\s+-rf\s+\//,
  /\bgit\s+push\s+--force\s+(main|master)\b/,
  /\bgit\s+push\s+-f\s+(main|master)\b/,
  /\bgit\s+reset\s+--hard\b/,
];

function main() {
  let input;
  try {
    const raw = process.argv[2];
    if (!raw) { process.exit(0); }
    input = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const command = input.command || input.input?.command || '';
  if (!command) { process.exit(0); }

  for (const pattern of BLOCKED_PATTERNS) {
    if (pattern.test(command)) {
      process.stderr.write(
        `[noyeah-harness] BLOCKED: command matches forbidden pattern ${pattern}\n` +
        `  Command: ${command}\n`
      );
      process.exit(2);
    }
  }

  process.exit(0);
}

try {
  main();
} catch {
  // On unexpected error, allow (fail open for non-security-critical path)
  process.exit(0);
}
