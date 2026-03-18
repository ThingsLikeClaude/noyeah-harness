#!/usr/bin/env node
'use strict';
// learning-remind.js -- SessionStart hook
// Reminds about available learning entries at session start.
// Exits 0 silently on any error.

const fs = require('fs');
const path = require('path');
const process = require('process');

function findMemoryPath() {
  // Resolve relative to the working directory Claude Code invokes hooks from.
  return path.join(process.cwd(), '.harness', 'memory', 'project-memory.json');
}

function main() {
  const memoryPath = findMemoryPath();

  if (!fs.existsSync(memoryPath)) { process.exit(0); }

  let memory;
  try {
    const raw = fs.readFileSync(memoryPath, 'utf8');
    memory = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const entries = Array.isArray(memory.entries) ? memory.entries : [];
  const learningCount = entries.filter((e) => e.type === 'learning').length;

  if (learningCount === 0) { process.exit(0); }

  process.stdout.write(
    `Project has ${learningCount} learning ${learningCount === 1 ? 'entry' : 'entries'}. ` +
    'Inject relevant learnings when dispatching agents ' +
    '(delegation rule 7, see docs/learning-injection.md).\n'
  );
  process.exit(0);
}

try {
  main();
} catch {
  process.exit(0);
}
