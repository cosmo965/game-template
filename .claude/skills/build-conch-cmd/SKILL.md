---
name: build-conch-cmd
description: Craft a Conch admin/dev command from structured parameters. Collects command name, description, arguments, permission, and target feature, then runs the conch-command-builder agent to register the command (bootstrapping Conch on first use).
---

You are crafting a Conch admin/dev command from parameters. The raw input is: $0

## Auto mode

This skill runs in **auto mode**: execute end-to-end without pausing for user input. Apply these rules:

- **Step 2 validation**: do **not** ask the user for missing fields. Infer reasonable defaults from `$0` and project conventions:
  - `name`: derive from the verb in the request (lowercase, no spaces).
  - `description`: write a short one-liner from the request itself.
  - `arguments`: infer from the request (e.g. "give a player currency" → `player target, string kind, number amount`). Empty if none.
  - `permission`: derive from `<feature>_<verb>` uppercased (e.g. `CURRENCY_GIVE`). The agent will add it to `Permissions.luau` if missing.
  - `feature` / `util`: pick the most likely feature folder under `src/features/` and the most plausible `Utils.luau` function name. If the helper is not exposed, the agent will stop with a clear message — that's fine, surface it in the report.
  - `roles`: default `owner`. `keybind`: default `F2`. `group`: default to the feature name.
- Only stop the run for genuinely blocking issues (the request gives no clue about what command to build, destructive action that needs confirmation). Course corrections from the user mid-run are normal — accept and continue.
- In the final report, list the assumptions you made (especially: chosen permission constant, target feature, target Util function) so the user can correct them quickly.

## Step 1 — Parse the parameters

Try to parse `$0` as a structured spec. Accept any of these shapes:

- **`key=value` pairs** on one line, e.g. `name=givecurrency desc="Give currency" args="player target, string kind, number amount" perm=CURRENCY_GIVE feature=Currency util=AddCurrency`
- **JSON-ish object**, e.g. `{ name: "givecurrency", description: "...", arguments: [...], permission: "CURRENCY_GIVE", feature: "Currency", util: "AddCurrency" }`
- **Free text** describing the command — extract the fields below from it.

Required fields:

| Field | Meaning |
|---|---|
| `name` | The command name as typed in the console (lowercase, matches Conch convention). |
| `description` | One-line description shown by Conch help. |
| `arguments` | Ordered list of typed Conch args. Each arg: `<type> <name>`, e.g. `player target`, `number amount`, `optional(string) reason`, `variadic(player) targets`. Empty list = no args. |
| `permission` | Permission constant the command requires (e.g. `CURRENCY_GIVE`). Will be added to `Permissions.luau` if missing. |
| `feature` | The feature whose `Utils.luau` provides the mutation (e.g. `Currency`). Use `none` if the command is self-contained (e.g. echo, kick via `Players`). |
| `util` | The exact `Utils.luau` function the callback should call (e.g. `AddCurrency`). Skip if `feature=none`. |

Optional fields:

| Field | Meaning |
|---|---|
| `roles` | Comma-separated roles that should receive this permission (default: `owner`). |
| `group` | Filename under `Commands/` to add to (default: derived from `feature`, e.g. `Currency.luau`). |
| `keybind` | Console open key for Conch_ui on first bootstrap (default: `F2`). |

## Step 2 — Validate before invoking the agent

Per auto mode above, do **not** prompt the user for missing fields. Fill required fields by inference from `$0` and project conventions, then proceed. Track the assumptions for the final report.

If `feature` is set and `util` is set, **do not verify the helper exists yourself** — the agent will check `src/features/<feature>/server/Utils.luau` and stop with a clear message if it isn't exposed. Just pass the spec through.

## Step 3 — Launch the conch-command-builder agent

Build a single prompt containing the parsed spec and hand it to the `conch-command-builder` agent. Use this template verbatim, filling each `<...>` slot:

> Add a Conch command with this spec:
>
> - **name**: `<name>`
> - **description**: `<description>`
> - **arguments**: `<arguments — formatted as a Lua-style list, e.g. Conch.args.player("target"), Conch.args.number("amount")>`
> - **permission**: `Permissions.<permission>` (add this constant to `Permissions.luau` if it doesn't exist)
> - **roles to grant the permission**: `<roles, default owner>`
> - **mutation**: call `<feature>Utils.<util>(<args in callback order>)` — if `<feature>` is `none`, the command is self-contained and you should implement it inline using only Roblox services / Conch APIs.
> - **command-group file**: `src/features/AdminCommands/server/Commands/<group>.luau` (create if missing, append the new command if it exists).
>
> Bootstrap Conch (server `Service.luau` + client `Controller.luau` + `Permissions.luau` + `Roles.luau`) if `src/features/AdminCommands/` does not already exist. Use `<keybind>` for the Conch_ui keybind.
>
> If `<feature>Utils.<util>` is not exposed, stop and report exactly what helper signature is needed — do not implement gameplay logic inside AdminCommands.
>
> After writing, summarize: files created/modified, the registered command's name + permission + args, whether Conch was bootstrapped this run, any `[0]` placeholder UserIds the user still needs to fill in, and the keybind used.

Wait for the agent to finish.

## Step 4 — Report to user

Relay the agent's summary to the user. Highlight, in this order:

1. **Blocked?** If the agent stopped because a `Utils.luau` helper is missing, surface the exact helper signature it asked for and recommend running `server-feature-builder` to add it, then re-running this skill.
2. **Placeholders to fill**: any `[0]` UserId entries in `Roles.luau` the user must replace with their real UserId.
3. **What was built**: command name, permission, arguments, file paths.
4. **Bootstrap status**: whether Conch was set up this run or was already in place.
