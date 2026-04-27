---
name: refactor-feature
description: Refactor legacy or foreign Luau code into a new feature folder that follows this project's conventions (file structure, naming, attribution headers, feature description blocks, Red+Guard remotes, Reflex states, DataUtils, Trove, modular Service/Controller/Handler/Utils split, React-Lua rules). Args: `<FeatureName> <legacy-path-1> [<legacy-path-2> ...]`. Orchestrates feature-planner → server-feature-builder + client-feature-builder (parallel) → ui-feature-builder (if UI) → ui-labs-replicator (if UI) → qa-tester.
---

You are orchestrating a refactor of legacy code into a new feature folder. The skill argument is: $0

## Auto mode

This skill runs in **auto mode**: execute end-to-end without pausing for user input. Do not stop to ask questions at any step except the explicit blockers in the Pre-flight section. Apply these rules:

- **Step 1 suggestions / open questions**: do **not** surface them and do **not** wait for user choice. Make reasonable assumptions, fold sensible suggestions into the plan, and continue. Briefly note in the final report which suggestions were adopted vs. skipped and any assumptions you made on open questions.
- **Step 3 ui-feature-builder design intake**: instruct it to skip its interactive design intake. It must make reasonable design decisions on its own (palette, layout, animation feel, state bindings) by reading existing primitives and the closest existing feature UI for reference, then build. Pass an explicit `auto mode: do not ask design questions, infer from existing UI conventions in the codebase` directive in its prompt.
- **Step 5 QA fixes**: do **not** ask whether to fix Critical/High issues. Report them in the summary and let the user decide after the run.

Only stop the run for the explicit pre-flight blockers below, or for genuinely blocking issues (an agent reports it cannot proceed). Course corrections from the user mid-run are normal — accept them and continue.

Follow these steps in order. Do not skip steps. Do not implement the refactor yourself — delegate to agents.

## Step 0 — Argument parsing

Parse `$0` as: `<FeatureName> <legacy-path-1> [<legacy-path-2> ...]`.

- The first whitespace-separated token is the feature name.
- All remaining tokens are legacy source paths (files or folders, absolute or relative to the project root).

Refuse and stop (clear error message) if any of these are true:
- No tokens at all.
- Only one token (no legacy paths).
- The feature name is not PascalCase (must match `^[A-Z][A-Za-z0-9]*$`).

## Step 1 — Pre-flight checks

Do all of these **before** launching any agent or writing anything. If any check trips a "stop and ask" condition, stop and ask the user — do not proceed until they answer.

1. **Resolve legacy paths.** For each path, verify it exists and is readable. If any missing path → stop and report which paths are missing.
2. **Read the legacy code.** Read every legacy file in full (recurse into folders). You need this content for the planner anyway, and you need it now to do the next two checks.
3. **Multi-feature detection.** If the legacy code clearly contains multiple unrelated systems that should each be their own feature folder (e.g., a "Currency" system and an unrelated "DailyRewards" system bundled together), **stop and ask** the user to split the legacy code and re-run the skill once per feature. Do not try to split automatically. Be conservative — only stop on clear-cut multi-feature mixing, not on mild internal coupling.
4. **UI detection.** Note whether the legacy code contains any UI (React/Roact `createElement` calls, raw `Instance.new("ScreenGui"/"Frame"/...)` UI construction, StarterGui content, etc.). Record this as `hasUI = true|false` for use in Steps 3 and 4.
5. **Side detection.** Note whether the legacy code is server-only, client-only, or mixed (raw `RemoteEvent`/`RemoteFunction` plus both sides → mixed; references to `game.Players.LocalPlayer` → has client; references to `Players.PlayerAdded` server-side → has server). Pass this hint to the planner.
6. **Target folder collision.** Check whether `src/features/<FeatureName>/` already exists. If it does → **stop and ask** the user how to proceed (rename, overwrite, merge into existing). Do not proceed without an explicit answer.

## Step 2 — Plan the refactor

Launch the `feature-planner` agent. Prompt it with:

> Plan a **refactor** of legacy code into a new feature named `<FeatureName>`.
> Legacy source paths:
> [bullet list of every legacy path]
>
> Read every legacy file in full before planning. Side hint from pre-flight: [server-only / client-only / mixed]. UI present: [yes / no].
>
> Produce the standard structured plan (suggestions, remote design, data schema, server state, client state, files to create, files to modify, implementation order) **mapping the legacy behavior onto this project's conventions**:
> - Raw `RemoteEvent`/`RemoteFunction` → `Red.Event` in `shared/Remote.luau` with a Guard-validating function.
> - Manual state broadcasting → Reflex slice (`state/Server.luau` / `state/Client.luau` / `state/Shared.luau`) following the project's data-replication priority (data replication > reflex replication > remote-fire replication).
> - Ad-hoc persistence (`_G`, datastores accessed directly) → `DataUtils` (`DataUtils:Get`).
> - Manual cleanup / connection tracking → Trove.
> - Monolithic scripts → modular `Service.luau` / `Controller.luau` / `Handler.luau` / `Utils.luau` split. Cross-feature Utils variables named `<FeatureName><Server|Client|Shared>Utils`.
> - Every new file gets the attribution header (Author/Modified By = Claude) and a feature description block immediately after.
> - Preserve original behavior. Do **not** add scope, new features, or speculative abstractions.
>
> Auto-mode: fold low-risk suggestions in, skip scope-expanding ones, answer open questions with the most reasonable default. Track decisions for the final report.

Wait for the planner to return. Do **not** surface its Suggestions / open questions to the user — decide yourself per auto mode and track the decisions.

## Step 3 — Build server and client in parallel

Using the plan from Step 2, launch **both** of the following agents **in the same message** (parallel tool calls):

**server-feature-builder** prompt:
> Implement the **server side** of a **refactor** using this plan:
> [paste full plan from Step 2]
>
> Legacy source paths (read these in full before writing anything):
> [bullet list of every legacy path]
>
> This is a refactor, not a greenfield build. Preserve the legacy logic exactly unless it conflicts with this project's conventions or contains a clear bug. Do not invent new features or scope. Map legacy primitives to project primitives (raw `RemoteEvent` → Red+Guard, manual state broadcast → Reflex slice, `_G`/direct datastore → `DataUtils`, manual connection tracking → Trove). Every new file gets the attribution header + feature description block.
>
> After finishing, summarize: files created/modified, remote names, action strings, state keys client-feature-builder needs.

**client-feature-builder** prompt:
> Implement the **client side (non-UI)** of a **refactor** using this plan:
> [paste full plan from Step 2]
>
> Legacy source paths (read these in full before writing anything):
> [bullet list of every legacy path]
>
> This is a refactor, not a greenfield build. Preserve the legacy logic exactly unless it conflicts with this project's conventions or contains a clear bug. Do not invent new features or scope. Map legacy primitives to project primitives (raw `RemoteEvent` → Red+Guard, polling/coroutine state → Reflex slice subscription, manual cleanup → Trove). Every new file gets the attribution header + feature description block.
>
> After finishing, summarize: files created/modified, Reflex selectors / state keys the UI layer needs, anything qa-tester should focus on.

Wait for both to complete before proceeding.

## Step 4 — UI (conditional)

Skip this step entirely if **all** of the following are true:
- Pre-flight `hasUI = false`, AND
- The plan from Step 2 contains no files under `ui/`.

Otherwise, launch `ui-feature-builder` with:
> Refactor the UI for this feature.
> Feature plan: [paste plan from Step 2]
> Legacy source paths (read for UI surfaces): [bullet list of legacy paths]
> Client state summary from client-feature-builder: [paste relevant selectors, state keys, dispatchable actions]
>
> Read existing primitives in `src/ui/Generic/Components/` and the closest existing feature UI under `src/features/*/ui/` to match conventions. Refactor the legacy UI into React-Lua using `e()`, this project's Generic primitives, and the React-Lua rules in CLAUDE.md (custom `Button` component for buttons, `px()` for thickness, Fragment children for UIListLayout siblings, callback prop last on buttons, etc.). Preserve the original visual layout and behavior — do not redesign.
>
> Auto mode: do not ask design questions, infer from existing UI conventions in the codebase. If a missing generic primitive is needed, build it inline in `src/ui/Generic/Components/` and continue — do not stop or hand off. In your final summary, list any new generic primitives separately from feature UI files.

## Step 5 — Stories (conditional)

Run only if Step 4 ran. Launch `ui-labs-replicator` with:
> Generate `.story.luau` files under `src/features/<FeatureName>/ui/Stories/` for every UI surface the ui-feature-builder produced.
> UI files written by ui-feature-builder:
> [list every file from Step 4 under src/features/<FeatureName>/ui/, plus any new generic primitives if relevant]

## Step 6 — QA audit

Launch `qa-tester` with:
> Audit the refactored implementation of feature `<FeatureName>`.
> Legacy source paths (for behavioral parity comparison):
> [bullet list of every legacy path]
> Files created/modified:
> [list every file from Steps 3, 4, 5, including any new generic primitives]
> Focus areas flagged by client-feature-builder: [paste from Step 3 client output]
> Focus areas flagged by ui-feature-builder: [paste from Step 4 if present]
>
> Check all 7 audit categories. Additionally verify behavioral parity with the legacy code — flag any place the refactor silently changed behavior. Report findings by severity.

## Step 7 — Report to user

After all agents complete, summarize to the user:
- **Feature name** and target folder path.
- **What was built** — files created/modified, grouped by side (server / client / shared / states / ui / stories / generic primitives).
- **Refactor mapping** — notable legacy → new translations (e.g., `RemoteEvent "GiveCoin"` → `CurrencyRemote` Guarded with `Guard.Number`; `_G.PlayerData` → `DataUtils:Get`; manual `RBXScriptConnection` table → `Trove`).
- **Suggestions adopted vs. skipped** and any assumption calls made on open questions.
- **QA findings** — Critical and High severity first.
- **Open follow-ups** — anything the user should manually verify (e.g., legacy behavior that didn't map cleanly).

If qa-tester finds Critical or High severity issues, list them clearly and ask the user whether to fix them before closing out.
