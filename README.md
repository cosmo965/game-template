# Game Template

A Roblox game template tailored for tycoon and incremental games. It ships with a feature-sliced architecture, opinionated tooling (Rojo + Wally + Rokit), and a curated package set covering UI, state, networking, and animation so you can drop in new features quickly.

---

## Highlights

- **Vertical feature states** — each feature lives under `src/features/{FeatureName}/` with its own `client/`, `server/`, `shared/`, and `ui/` folders.
- **Auto-bootstrapped runtimes** — server and client runtimes auto-discover and initialize modules ending in `Service`, `Controller`, or `Handler`.
- **Generated Rojo tree** — the project tree is generated from `src/` via a small Node script, so adding a feature folder is enough to wire it up.
- **Batteries included** — React + ReactRoblox, Reflex, Red (networking + Guard + Ratelimit), Trove, Sift, Promise, Future, Spr, ReactSpring, ObjectCache, Observers, Conch admin, and more.

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| [Rokit](https://github.com/rojo-rbx/rokit) | Manages the Roblox toolchain pinned in `rokit.toml` (Rojo, Wally, Selene, StyLua, luau-lsp, wally-package-types). |
| [Node.js](https://nodejs.org/) (LTS) + npm | Runs the Rojo tree generator and the watch/dev scripts. |
| [Roblox Studio](https://create.roblox.com/) with the Rojo plugin | Connects to the local Rojo server and syncs the place. |

---

## First-time setup

```bash
# 1. Install the pinned Roblox toolchain (Rojo, Wally, Selene, StyLua, luau-lsp)
rokit install

# 2. Install Wally packages into Packages/
wally install

# 3. (Optional) Generate Luau type definitions for Wally packages
wally-package-types --sourcemap sourcemap.json Packages/

# 4. Install Node dev dependencies (chokidar-cli, concurrently)
npm install
```

---

## Running the project

The project uses a generated `default.project.json`. Always start work via `npm run dev` so the tree stays in sync with the file system.

```bash
npm run dev
```

That command:

1. Runs `tools/genRojoTree.js` to (re)generate `default.project.json` from the contents of `src/`.
2. Starts a watcher that regenerates the tree whenever files in `src/` change.
3. Starts `rojo serve` so Roblox Studio can connect.

Then in Roblox Studio: open the Rojo plugin → **Connect** to the local server.

### Other npm scripts

| Script | What it does |
|--------|--------------|
| `npm run build:rojo` | One-shot generation of `default.project.json`. |
| `npm run watch:rojo` | Watches `src/` and regenerates the tree on change. |
| `npm run server:rojo` | Just starts `rojo serve` against the existing tree. |

---

## Project layout

```
src/
├── runtime/                    # Bootstrap scripts
│   ├── ReplicatedFirst.client.luau
│   ├── Runtime.client.luau     # Auto-inits *Controller / *Handler modules
│   ├── Runtime.server.luau     # Auto-inits *Service / *Handler modules
│   └── ClientLoaded.luau       # Shared client-loaded signal
├── features/
│   └── {FeatureName}/
│       ├── client/             # Controller.luau, Utils.luau
│       ├── server/             # Service.luau, Utils.luau
│       ├── shared/             # Handler.luau, Utils.luau
│       └── ui/                 # Components/, HUD/, Menu/
├── remotes/                    # Red event definitions
│   ├── Core/
│   └── Misc/
└── ui/                         # Shared UI (AppContainer, Generic/Components)
```

Mapped into Roblox by Rojo as:

```
ReplicatedFirst       ← src/runtime/ReplicatedFirst.client.luau
ReplicatedStorage
├── Client
│   ├── Features      ← src/features/{FeatureName}/client + ui
│   └── UI            ← src/ui
├── Packages          ← Packages/
└── Shared
    ├── Features      ← src/features/{FeatureName}/shared
    ├── Modules       (empty Folder)
    └── ClientLoaded  ← src/runtime/ClientLoaded.luau
ServerScriptService
├── Server.Features   ← src/features/{FeatureName}/server
└── Runtime           ← src/runtime/Runtime.server.luau
StarterPlayer.StarterPlayerScripts.Runtime ← src/runtime/Runtime.client.luau
```

---

## Adding a new feature

1. Create `src/features/MyFeature/` with the subfolders you need (`client/`, `server/`, `shared/`, `ui/`).
2. Add a module with the right suffix so the runtime picks it up:
   - Server logic → `server/Service.luau`
   - Client logic → `client/Controller.luau`
   - Shared logic that runs on both sides → `shared/Handler.luau`
3. Optionally expose `PreInit()` and `PostInit()` functions on the module — they're invoked in two passes so cross-module references resolve cleanly.
4. Save. The watcher regenerates `default.project.json` and Rojo syncs the new instances into Studio.

For client controllers, you can also implement `CharacterReinitialization(character)`; the client runtime calls it on every `CharacterAdded` and runs the returned cleanup function on `CharacterRemoving`.

---

## Networking

- Validate every server-bound payload with **Guard**, and rate-limit with **Ratelimit**.
- Replication priority: **DataUtils data replication > Reflex replication > Remote firing**.

---

## Code style

- Formatting via **StyLua** (`stylua.toml`): tabs (width 4), 120 cols, LF, double quotes preferred.
- Linting via **Selene** (`selene.toml`) with the Roblox std lib.
- `camelCase` for variables / local functions, `PascalCase` for modules / classes / React components / public functions.
- Multi-condition `if` statements split one condition per line.
- Always use the project's `Button` component (`src/ui/Generic/Components/Button.luau`) instead of raw buttons.
- See [.claude/CLAUDE.md](.claude/CLAUDE.md) for the full contributor guide.

---

## Troubleshooting

- **Studio shows no changes.** Make sure `npm run dev` is running and the Rojo plugin is connected. The Studio output panel logs sync errors.
- **Wally packages missing types.** Re-run `wally-package-types --sourcemap sourcemap.json Packages/` after `wally install`.
- **`default.project.json` looks stale.** Run `npm run build:rojo` to regenerate it, or restart `npm run dev`.
- **Rokit-managed tool not found.** Re-run `rokit install` from the project root and ensure the Rokit shims are on your `PATH`.
