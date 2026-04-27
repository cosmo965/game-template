---
name: genRojoTree.js extended for extra server files
description: When a feature has extra server/ files beyond Utils.luau and Service.luau, the generator must be extended to map them
type: feedback
---

When a feature's server/ directory contains files beyond Utils.luau and Service.luau (e.g. Config.luau, Template.luau, Internal.luau, ProfileStore.luau), the genRojoTree.js generator does NOT map them by default. Extend the generator's server section to scan for any .luau files not in the known set and map them by their base name (filename without .luau extension).

**Why:** The generator only hard-codes Utils.luau and Service.luau. Internal helper modules need to be in the Rojo tree so they can be required via instance paths like ServerScriptService.Server.Features.Data.Internal.

**How to apply:** When writing features with internal server modules, update genRojoTree.js to include a loop over extra server/ files before calling node tools/genRojoTree.js. This was done in the Data feature refactor (April 2026).
