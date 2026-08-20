#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const root = process.env.DATAMOON_ROOT || path.resolve(__dirname, "../..");
const serverFile = path.join(
  root,
  "datamoon-online-server",
  "utils",
  "scripts",
  "movement_contract.gd"
);
const clientFile = path.join(
  root,
  "datamoon-online-client",
  "utils",
  "scripts",
  "movement_contract.gd"
);

// The Client is not installed on the production VM. Keep the cross-repository
// check active in development environments, but do not block a server deploy
// when the optional client checkout is unavailable.
if (!fs.existsSync(clientFile)) {
  console.log("Movement contract check skipped: Client repository is not installed.");
  process.exit(0);
}

function readConstants(file) {
  const source = fs.readFileSync(file, "utf8");
  const constants = new Map();
  const pattern = /const\s+([A-Z0-9_]+)\s*:=\s*"([^"]*)"/g;

  for (const match of source.matchAll(pattern)) {
    const [, name, value] = match;
    if (constants.has(name)) {
      throw new Error(`${file}: duplicate constant ${name}`);
    }
    constants.set(name, value);
  }

  return constants;
}

function compareContracts(server, client) {
  const failures = [];

  for (const [name, value] of server) {
    if (!client.has(name)) {
      failures.push(`${name}: missing from Client`);
    } else if (client.get(name) !== value) {
      failures.push(
        `${name}: Server=${JSON.stringify(value)} Client=${JSON.stringify(client.get(name))}`
      );
    }
  }

  for (const name of client.keys()) {
    if (!server.has(name)) {
      failures.push(`${name}: missing from Server`);
    }
  }

  return failures;
}

try {
  const server = readConstants(serverFile);
  const client = readConstants(clientFile);
  const failures = compareContracts(server, client);

  if (failures.length > 0) {
    console.error(
      "Movement contract synchronization failed:\n" +
        failures.map((entry) => `- ${entry}`).join("\n")
    );
    process.exit(1);
  }

  console.log(`Movement contracts synchronized: ${server.size} wire constants.`);
} catch (error) {
  console.error(`Movement contract check failed: ${error.message}`);
  process.exit(1);
}
