#!/usr/bin/env node
'use strict';
// secret-filter.js -- PostToolUse(Write|Edit) hook
// Warns when file content contains potential secrets.
// Always exits 0 (warning only, never blocks).

const process = require('process');

const SECRET_PATTERNS = [
  { pattern: /sk-[A-Za-z0-9]{20,}/, label: 'OpenAI API key (sk-)' },
  { pattern: /ghp_[A-Za-z0-9]{36,}/, label: 'GitHub PAT (ghp_)' },
  { pattern: /AKIA[A-Z0-9]{16}/, label: 'AWS Access Key (AKIA)' },
  { pattern: /xoxb-[A-Za-z0-9\-]+/, label: 'Slack Bot Token (xoxb-)' },
  { pattern: /-----BEGIN\s+(RSA|EC|OPENSSH|DSA|PGP)\s+PRIVATE\s+KEY-----/, label: 'Private key' },
  { pattern: /password\s*[:=]\s*["'][^"']{4,}["']/, label: 'Hardcoded password' },
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

  const content = input.output || input.content || input.new_string || '';
  if (!content) { process.exit(0); }

  const warnings = [];
  for (const { pattern, label } of SECRET_PATTERNS) {
    if (pattern.test(content)) {
      warnings.push(label);
    }
  }

  if (warnings.length > 0) {
    process.stdout.write(
      `[noyeah-harness] SECRET WARNING: Potential secrets detected in written content:\n` +
      warnings.map((w) => `  - ${w}`).join('\n') + '\n' +
      'Review the file and remove secrets before committing.\n'
    );
  }

  process.exit(0);
}

try {
  main();
} catch {
  process.exit(0);
}
