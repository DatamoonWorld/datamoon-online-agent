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
const serverItems = path.join(root, "datamoon-online-server", "utils", "jsons", "items");
const apiItems = path.join(root, "datamoon-online-mysqlapi", "internal", "catalog", "data", "items");
const serverRecipes = path.join(root, "datamoon-online-server", "utils", "jsons", "recipes");
const apiRecipes = path.join(root, "datamoon-online-mysqlapi", "internal", "catalog", "data", "recipes");

function loadCatalog(directory) {
  const result = new Map();
  for (const file of fs.readdirSync(directory).filter((name) => name.endsWith(".json")).sort()) {
    const value = JSON.parse(fs.readFileSync(path.join(directory, file), "utf8"));
    result.set(file, value);
  }
  return result;
}

function gameplayData(value, ignoredFields) {
  return canonicalize(Object.fromEntries(
    Object.entries(value).filter(([key]) => !ignoredFields.has(key)),
  ));
}

function canonicalize(value) {
  if (Array.isArray(value)) return value.map(canonicalize);
  if (value !== null && typeof value === "object") {
    return Object.fromEntries(Object.keys(value).sort().map((key) => [key, canonicalize(value[key])]));
  }
  return value;
}

const failures = [];
function compareCatalog(label, serverDirectory, apiDirectory, ignoredFields) {
  const server = loadCatalog(serverDirectory);
  const api = loadCatalog(apiDirectory);
  for (const file of new Set([...server.keys(), ...api.keys()])) {
    if (!server.has(file) || !api.has(file)) {
      failures.push(`${label}/${file}: missing from ${server.has(file) ? "API" : "Server"} catalog`);
      continue;
    }
    if (JSON.stringify(gameplayData(server.get(file), ignoredFields)) !==
        JSON.stringify(gameplayData(api.get(file), ignoredFields))) {
      failures.push(`${label}/${file}: gameplay fields differ`);
    }
  }
  return server.size;
}

const itemCount = compareCatalog(
  "items", serverItems, apiItems,
  new Set(["name", "sprite", "description", "tooltip_type"]),
);
const recipeCount = compareCatalog(
  "recipes", serverRecipes, apiRecipes,
  new Set(["description"]),
);

if (failures.length > 0) {
  console.error("Catalog synchronization failed:\n" + failures.map((entry) => `- ${entry}`).join("\n"));
  process.exit(1);
}
console.log(`Catalogs synchronized: ${itemCount} items, ${recipeCount} recipes.`);
