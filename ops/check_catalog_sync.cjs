#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const root = process.env.DATAMOON_ROOT || path.resolve(__dirname, "../..");
const serverItems = path.join(root, "datamoon-online-server", "utils", "jsons", "items");
const apiItems = path.join(root, "datamoon-online-mysqlapi", "internal", "catalog", "data", "items");
const presentationFields = new Set(["name", "sprite", "description", "tooltip_type"]);

function loadCatalog(directory) {
  const result = new Map();
  for (const file of fs.readdirSync(directory).filter((name) => name.endsWith(".json")).sort()) {
    const value = JSON.parse(fs.readFileSync(path.join(directory, file), "utf8"));
    result.set(file, value);
  }
  return result;
}

function gameplayData(value) {
  return canonicalize(Object.fromEntries(Object.entries(value).filter(([key]) => !presentationFields.has(key))));
}

function canonicalize(value) {
  if (Array.isArray(value)) return value.map(canonicalize);
  if (value !== null && typeof value === "object") {
    return Object.fromEntries(Object.keys(value).sort().map((key) => [key, canonicalize(value[key])]));
  }
  return value;
}

const server = loadCatalog(serverItems);
const api = loadCatalog(apiItems);
const failures = [];
for (const file of new Set([...server.keys(), ...api.keys()])) {
  if (!server.has(file) || !api.has(file)) {
    failures.push(`${file}: missing from ${server.has(file) ? "API" : "Server"} catalog`);
    continue;
  }
  if (JSON.stringify(gameplayData(server.get(file))) !== JSON.stringify(gameplayData(api.get(file)))) {
    failures.push(`${file}: gameplay fields differ`);
  }
}

if (failures.length > 0) {
  console.error("Item catalog synchronization failed:\n" + failures.map((entry) => `- ${entry}`).join("\n"));
  process.exit(1);
}
console.log(`Item catalogs synchronized: ${server.size} definitions.`);
