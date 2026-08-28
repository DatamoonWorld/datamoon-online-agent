#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const workspaceRoot = path.resolve(__dirname, "../../..");
const legacyRoot = path.resolve(__dirname, "../..");
const root = process.env.DATAMOON_ROOT || (
  fs.existsSync(path.join(legacyRoot, "datamoon-online-server"))
    ? legacyRoot
    : path.join(workspaceRoot, "datamoon_online")
);
const clientRoot = path.join(root, "datamoon-online-client");
const serverCatalog = path.join(root, "datamoon-online-server", "utils", "jsons");
const languageRoot = path.join(clientRoot, "utils", "lang");

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function collectFiles(directory, extension) {
  const files = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const file = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...collectFiles(file, extension));
    else if (entry.name.endsWith(extension)) files.push(file);
  }
  return files;
}

function collectCatalogKeys(value, result) {
  if (Array.isArray(value)) {
    for (const child of value) collectCatalogKeys(child, result);
    return;
  }
  if (value === null || typeof value !== "object") return;
  for (const [key, child] of Object.entries(value)) {
    if (/(?:name_key|description_key|link_max_mastery_description_key)$/.test(key) &&
        typeof child === "string" && child.trim() !== "") {
      result.add(child.trim());
    }
    collectCatalogKeys(child, result);
  }
}

function collectClientKeys() {
  const result = new Set();
  // Dynamic keys such as EFFECT_%s are resolved from catalogs and are not
  // literal language references; only capture complete static identifiers.
  const keyPattern = /(?:lang_variables\.|get_lang_text\(\s*["'`])([A-Z][A-Z0-9_]*[A-Z0-9])(?![A-Z0-9_])/g;
  for (const file of collectFiles(path.join(clientRoot, "utils", "scripts"), ".gd")) {
    const source = fs.readFileSync(file, "utf8");
    for (const match of source.matchAll(keyPattern)) result.add(match[1]);
  }
  return result;
}

const failures = [];
const en = readJson(path.join(languageRoot, "en_us.json"));
const pt = readJson(path.join(languageRoot, "pt_br.json"));
const enKeys = new Set(Object.keys(en));
const ptKeys = new Set(Object.keys(pt));

for (const key of new Set([...enKeys, ...ptKeys])) {
  if (!enKeys.has(key)) failures.push(`en_us.json: missing ${key}`);
  if (!ptKeys.has(key)) failures.push(`pt_br.json: missing ${key}`);
}

const catalogKeys = new Set();
for (const file of collectFiles(serverCatalog, ".json")) {
  collectCatalogKeys(readJson(file), catalogKeys);
}
for (const key of catalogKeys) {
  if (!enKeys.has(key)) failures.push(`catalog reference missing from en_us.json: ${key}`);
  if (!ptKeys.has(key)) failures.push(`catalog reference missing from pt_br.json: ${key}`);
}

for (const key of collectClientKeys()) {
  if (!enKeys.has(key)) failures.push(`Client reference missing from en_us.json: ${key}`);
  if (!ptKeys.has(key)) failures.push(`Client reference missing from pt_br.json: ${key}`);
}

if (failures.length > 0) {
  console.error("Localization validation failed:\n" + failures.map((entry) => `- ${entry}`).join("\n"));
  process.exit(1);
}

console.log(`Localization synchronized: ${enKeys.size} keys, ${catalogKeys.size} catalog references.`);
