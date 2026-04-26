# Game template — Project Specs

Roblox Game template: usually used for tycoon/incremental games.

---

## Toolchain (rokit.toml)

| Tool | Version | Purpose |
|------|---------|---------|
| rojo | 7.6.0 | Sync source → Roblox Studio |
| wally | 0.3.2 | Package manager |
| wally-package-types | 1.6.2 | Generates Luau types for Wally packages |
| selene | 0.29.0 | Linter |
| stylua | 2.3.0 | Formatter |
| luau-lsp | 1.55.0 | Language server |

Install with `rokit install`, then `wally install`.

---

## Packages (wally.toml)

**UI / State**
- `React` (jsdotlua/react @ 17.1.0)
- `ReactRoblox` (jsdotlua/react-roblox @ 17.1.0)
- `Reflex` (littensy/reflex @ 4.3.1)
- `ReactReflex` (littensy/react-reflex @ 0.3.6)
- `ReactSpring` (chriscerie/react-spring @ 2.0.0)
- `Topbarplus` (1foreverhd/topbarplus @ 3.4.0)

**Networking**
- `Red` (red-blox/red @ 2.3.0)
- `Guard` (red-blox/guard @ 1.0.1) — type validation
- `Ratelimit` (red-blox/ratelimit @ ^1.0.0)

**Async / Events**
- `Future` (red-blox/future @ ^1.0.0)
- `Promise` (evaera/promise @ 4.0.0)
- `GoodSignal` (stravant/goodsignal @ 0.3.1)
- `Trove` (sleitnick/trove @ 1.4.0) — cleanup

**Animation / Motion**
- `Spr` (blackjackiee/spr @ 1.1.3)

**Utilities**
- `Sift` (csqrl/sift @ 0.0.9) — immutable table ops
- `Chrono` (parihsz/chrono @ 1.2.4) — time utilities
- `RthroScaler` (egomoose/rthro-scaler @ 0.3.0)
- `ObjectCache` (pyseph/objectcache @ 1.4.6) — part pooling
- `Observers` (sleitnick/observers @ 0.5.0) — instance lifecycle observation

**Admin**
- `Conch` (alicesaidhi/conch @ 0.3.1) — admin command framework
- `Conch_ui` (alicesaidhi/conch-ui @ 0.3.1)

**Raw wally.toml**
```toml
[package]
name = "cosmo/game-template-v3"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
React = "jsdotlua/react@17.1.0"
ReactRoblox = "jsdotlua/react-roblox@17.1.0"
Red = "red-blox/red@2.3.0"
Future = "red-blox/future@^1.0.0"
Guard = "red-blox/guard@1.0.1"
Promise = "evaera/promise@4.0.0"
Ratelimit = "red-blox/ratelimit@^1.0.0"
GoodSignal = "stravant/goodsignal@0.3.1"
Trove = "sleitnick/trove@1.4.0"
ReactSpring = "chriscerie/react-spring@2.0.0"
Spr = "blackjackiee/spr@1.1.3"
Reflex = "littensy/reflex@4.3.1"
ReactReflex = "littensy/react-reflex@0.3.6"
Sift = "csqrl/sift@0.0.9"
Conch = "alicesaidhi/conch@0.3.1"
Conch_ui = "alicesaidhi/conch-ui@0.3.1"
Chrono = "parihsz/chrono@1.2.4"
RthroScaler = "egomoose/rthro-scaler@0.3.0"
ObjectCache = "pyseph/objectcache@1.4.6"
Observers = "sleitnick/observers@0.5.0"
Topbarplus = "1foreverhd/topbarplus@3.4.0"
```

---

## Project Structure (default.project.json)

```
ReplicatedFirst → src/runtime/ReplicatedFirst.client.luau
ReplicatedStorage
  Client
    Features    → src/features/{FeatureName}/client/
    UI          → src/ui
  Packages      → Packages
  Shared
    Features    → src/features/{FeatureName}/shared/
    Modules     (empty Folder)
    ClientLoaded → src/runtime/ClientLoaded.luau
ServerScriptService
  Server
    Features    → src/features/{FeatureName}/server/
  Runtime       → src/runtime/Runtime.server.luau
StarterPlayer.StarterPlayerScripts.Runtime → src/runtime/Runtime.client.luau
```

### Source layout

- `src/runtime/` — bootstrap scripts (`Runtime.client.luau`, `Runtime.server.luau`, `ReplicatedFirst.client.luau`)
- `src/features/{FeatureName}/` — vertical feature slice:
  - `client/` — `Controller.luau` (auto-initialized by client Runtime), `Utils.luau`
  - `server/` — `Service.luau` (auto-initialized by server Runtime), `Utils.luau`
  - `shared/` — `Handler.luau` (auto-initialized by both Runtimes), `Utils.luau`, `Remote.luau` (Red event named `<FeatureName>Remote`)
  - `slices/` — optional Reflex state slices: `Server.luau` (server state), `Client.luau` (client state), `Shared.luau` (shared state). Only create files for the sides the feature needs. Missing files are skipped by the Rojo tree generator.
  - `ui/` — `Components/`, `HUD/`, `Menu/`
- `src/ui/` — shared UI (`AppContainer.luau`, `Generic/Components/`)

### Runtime bootstrap

- **Server** auto-requires all descendants of `Server.Features` and `Shared.Features` whose name contains `"Service"` or `"Handler"`, then calls `PreInit()` followed by `PostInit()` on each.
- **Client** auto-requires all descendants of `Client.Features` and `Shared.Features` whose name contains `"Controller"` or `"Handler"`, then calls `PreInit()` followed by `PostInit()` on each. Also hooks `CharacterReinitialization(character)` / cleanup on character events.

---

## Code Style

**Formatting (stylua.toml)**
- Column width: 120
- Indent: tabs, width 4
- Line endings: Unix (LF)
- Quotes: auto, prefer double
- Always use call parentheses
- Never collapse simple statements
- Requires are auto-sorted

**Linting (selene.toml)**
- Standard library: `roblox`
- `mixed_table` allowed off (no mixed array/dict tables)

**Naming**
- `camelCase` — variables, local functions
- `PascalCase` — classes, modules, React components, public functions
- When indexing the `Utils` module of another feature, name the variable `<FeatureName><Server|Client|Shared>Utils` (e.g. `local DailyRewardsServerUtils = require(...)`, `local DailyRewardsClientUtils = require(...)`, `local DailyRewardsSharedUtils = require(...)`).

**General rules**
- Keep functions small and focused
- Avoid deep nesting
- Comment only when the *why* is non-obvious
- DRY — reuse existing systems before adding new ones
- Do not create new files unless needed

**Variables order**
- Label each section variable 
- 1. Roblox default services
- 2. Project packages requires
- 3. Project services/controllers/handlers requires'
- 4. Objects that are referenced in workspace (use :WaitForChild())
- 5. Local private functions

**Misc**
- Multi-condition `if` statements must use multiple lines, one condition per line:
  ```lua
  if
      conditionA
      and conditionB
      and conditionC
  then
  ```

**Modularity**
- Make sure when creating a feature, make sure it is broken up into multiple modules to increase readability. Make it modular and easily removed/added.

**Utils method documentation**
- Every exposed method on a `Utils.luau` module must have a `--[[ ]]` comment block directly above it describing what it does and what it returns. Keep it minimal — one clear sentence is enough.
- Example:
  ```lua
  --[[
      Returns the player's active profile data, or nil if the profile is not yet loaded.
  ]]
  function DataUtils:Get(player: Player): { [string]: any }?
  
  --[[
      Grants currency to the player. Returns true on success, false if data is not loaded.
  ]]
  function CurrencyUtils:Grant(player: Player, amount: number): boolean
  ```
- Do not write these comments on private functions — only on methods exposed via the returned table.

**Feature file description block**
- Every new Luau file created as part of a feature must have a `--[[ ]]` comment block immediately after the attribution header (before any `local` declarations).
- The block must describe: what the file does, its role/layer in the feature, and its key dependencies (what it requires from other features or packages).
- Keep it concise — two to four sentences. Do not pad with obvious information.
- Example:
  ```lua
  --[[
      Server service for the Currency feature. Handles granting and spending player currency,
      validates balances before purchases, and persists changes through DataUtils.
      Requires: DataUtils (Data feature), CurrencyRemote (shared)
  ]]
  ```
- Existing files: do not retroactively add a description block — only refresh `Modified By` / `Last Modified`.

---

## Performance

- Prefer O(1) / O(log n) where possible
- Cache frequently reused values
- Avoid heavy work in `RenderStepped`
- Use `task.spawn` / `task.defer` appropriately
- Pool parts via `ObjectCache` where applicable

---

## Roblox Boundaries

- Keep server/client boundaries clear
- Never trust client input for authoritative logic
- Validate all remote payloads with `Guard`
- Rate-limit client→server remotes with `Ratelimit`
- Always use Red's guard functions when defining Red events. Pass a Guard validator function as the second argument to `Red.Event()` that accepts the expected parameters and returns them after Guard-checking each one. Example: `Red.Event("ExampleRemote", function(param1, param2) return Guard.String(param1), Guard.Number(param2) end)`.
- For creating Red events for a feature, create `src/features/{FeatureName}/shared/Remote.luau` returning a `Red.Event("<FeatureName>Remote", ...)` with a guard function that validates all expected parameters individually by type.
- When referencing a Red remote, always call `:Server()` in server modules and `:Client()` in client modules. Never call both on the same side.
- In shared modules that reference a remote, do **not** call `:Server()` or `:Client()` at require-time. Instead, check `RunService:IsServer()` at the call site (inside `:Fire()` / `:On()` usage) and call the appropriate side there.
- On the server, always call `:On()` with a Guard-validated handler. Reject or ignore payloads that fail Guard checks — never trust raw client data.

---

## Extra Roblox rules
- When writing new features, when having to update client state with server state. Prioritize data replication > reflex replication > remote fire replication when implementing. Ask me if you have trouble figuring out which to use.
- Instead of using `task.cancel()` to cancel loop threads, toggle a boolean and check if that boolean is false/nil in order to stop the loop.
- When using DataUtils and trying to retrieve data, prioritize using `DataUtils:Get()`.
- When writing if-statement guards that only return, have it one lined unless the if statement is long and should be multi-lined.
- If `PreInit` or `PostInit` has no code to run in a module, omit it entirely — never include empty lifecycle stubs.
---

## React-Lua Rules
- When doing `React.createElement()`, use `e()` instead
- When creating a custom component in React, insert another parameter with a dictionary of children instead of assigning a `children` key in the 2nd parameter of `e()`
- When assigning callback property to a button component have it go down another line from the other properties and have the callback property be last
- When assigning any native property that is related to Thickness, wrap the Thickness around a `px()` hook.
- When creating Fragments in a parent with a UIListLayout, just do `e(React.Fragment, nil, items)` instead of `Sift.Dictionary.merge` or anything extra
- Never create a "button" without using the custom Button component (`src/ui/Generic/Components/Button.luau`).

---

## AI / Contributor Rules (from CLAUDE.md)

1. Do exactly what is asked — no extra features
2. Do not rewrite large sections unless necessary
3. Preserve existing logic unless it's incorrect
4. Ask for clarification if the request is ambiguous
5. Prefer simple solutions over clever ones
6. Identify root cause before fixing — no blind patches
7. Return minimal, precise changes
8. Do not make any changes until you have 95% confidence in what you need to build. Ask me follow-up questions until you reach that confidence.

**Avoid:** overengineering, premature optimization, magic numbers, hardcoding configurable values.

---

## File Header Attribution

Luau files in this project start with a header block like:

```
--[[
--Created Date: Sunday March 29th 2026 9:24:34 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Sunday March 29th 2026 9:30:03 pm CEST
--Modified By: Cosmovyz
--]]
```

When Claude edits a file that has this header, update `Modified By:` to `Claude` and refresh `Last Modified:` to the current date/time. When Claude creates a new file, set both `Author:` and `Modified By:` to `Claude`. Leave `Created Date` untouched on existing files. Always make this edit. No need to ask for permission to edit.

When building scripts or editing scripts that are not inside src/, do not include the file header attribution, delete it.