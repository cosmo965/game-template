---
name: build-feature
description: Orchestrate the full build-feature agent team to plan, implement, and audit a new feature. Runs feature-planner → server-feature-builder + client-feature-builder (parallel) → ui-component-builder (only if new generic primitives are needed) → ui-feature-design-builder (for the feature's UI) → qa-tester.
---

You are orchestrating the build-feature agent team. The feature to build is: $0

Follow these steps in order. Do not skip steps. Do not implement anything yourself.

## Step 1 — Plan

Launch the `feature-planner` agent with the full feature description. Wait for it to return a complete implementation plan before proceeding.

Prompt it with:
> Plan the implementation of: $0
> Read all relevant existing code before producing the plan. Output the full structured plan including: remote design, data schema, server state, client state, files to create, files to modify, and implementation order.

If the plan contains open questions, surface them to the user and wait for answers before continuing.

## Step 2 — Build server and client in parallel

Using the plan from Step 1, launch **both** of the following agents **in the same message** (parallel):

**server-feature-builder** prompt:
> Implement the server side of this feature using the following plan:
> [paste full plan from Step 1]
> Write all server files. After finishing, summarize: files created/modified and any remote names, action strings, or state keys that client-feature-builder needs.

**client-feature-builder** prompt:
> Implement the client side (non-UI) of this feature using the following plan:
> [paste full plan from Step 1]
> Write all client files. After finishing, summarize: files created/modified, Reflex selectors/state keys the UI layer needs, and anything qa-tester should focus on.

Wait for both to complete before proceeding.

## Step 3 — Generic primitives (conditional)

Only run this step if the plan or the design needs a NEW reusable primitive in `src/ui/Generic/Components/` that does not already exist (e.g. a novel animation wrapper). Do NOT run it for feature-local UI — that belongs to Step 4.

If needed, launch `ui-component-builder` with:
> Build the following new generic UI primitives needed by this feature:
> [list each: name, purpose, expected props]
> They live in `src/ui/Generic/Components/`. Follow all React-Lua project conventions.

If the feature only composes existing primitives, skip this step entirely.

## Step 4 — Feature UI design + build (conditional)

If the plan includes any feature UI (Menu, HUD, feature-local Components), launch `ui-feature-design-builder` with:
> Design and build the UI for this feature.
> Feature plan: [paste plan from Step 1]
> Client state summary from client-feature-builder: [paste relevant selectors, state keys, and dispatchable actions]
> New generic primitives added in Step 3 (if any): [paste list, or "none"]
>
> Read existing primitives in `src/ui/Generic/Components/` and the closest existing feature UI under `src/features/*/ui/`, then ask the user the design intake questions before writing any file. Compose existing primitives — do not author new generic primitives. If you need a primitive that doesn't exist, stop and report it.

This agent is interactive: it will ask the user design questions. Surface its questions verbatim and wait for answers before letting it proceed.

If the agent reports back with a "Needs ui-component-builder" block, return to Step 3 with that list, then re-invoke `ui-feature-design-builder` with the same plan plus the newly added primitives.

Skip this step entirely if the feature has no UI.

## Step 5 — QA audit

Launch `qa-tester` with:
> Audit the implementation of: $0
> Files implemented:
> [list all files created/modified from Steps 2, 3, and 4]
> Focus areas flagged by client-feature-builder: [paste from Step 2 client output]
> Focus areas flagged by ui-feature-design-builder: [paste from Step 4 if present]
> Check all 7 audit categories. Report findings by severity.

## Step 6 — Report to user

After all agents complete, summarize to the user:
- What was built (files created/modified)
- Any QA findings that need addressing (Critical and High severity first)
- Any open items or follow-up work

If qa-tester finds Critical or High severity issues, ask the user whether to fix them before closing out.
