---
name: build-feature
description: Orchestrate the full build-feature agent team to plan, implement, and audit a new feature. Runs feature-planner → server-feature-builder + client-feature-builder (parallel) → ui-feature-builder (designs and builds the feature UI; builds any missing generic primitives inline) → qa-tester.
---

You are orchestrating the build-feature agent team. The feature to build is: $0

## Auto mode

This skill runs in **auto mode**: execute end-to-end without pausing for user input. Do not stop to ask questions at any step. Apply these rules:

- **Step 1 suggestions / open questions**: do **not** surface them and do **not** wait for user choice. Make reasonable assumptions, fold sensible suggestions into the plan, and continue. Briefly note in the final report which suggestions were adopted vs. skipped and any assumptions you made on open questions.
- **Step 3 ui-feature-builder design intake**: instruct it to skip its interactive design intake. It must make reasonable design decisions on its own (palette, layout, animation feel, state bindings) by reading existing primitives and the closest existing feature UI for reference, then build. Pass an explicit `auto mode: do not ask design questions, infer from existing UI conventions in the codebase` directive in its prompt.
- **Step 5 QA fixes**: do **not** ask whether to fix Critical/High issues. Report them in the summary and let the user decide after the run.

Only stop the run for genuinely blocking issues (missing required input that cannot be inferred, destructive action that needs confirmation, agent reports it cannot proceed). Course corrections from the user mid-run are normal — accept them and continue.

Follow these steps in order. Do not skip steps. Do not implement anything yourself.

## Step 1 — Plan

Launch the `feature-planner` agent with the full feature description. Wait for it to return a complete implementation plan before proceeding.

Prompt it with:
> Plan the implementation of: $0
> Read all relevant existing code before producing the plan. Output the full structured plan including: suggestions, remote design, data schema, server state, client state, files to create, files to modify, and implementation order.

The planner will include a **Suggestions** section with optional scope expansions, design alternatives, and balance/tuning ideas, and may include open questions. **Do not surface these to the user.** Per auto mode, decide yourself: fold in suggestions that are clearly net-positive and low-risk, skip ones that expand scope materially, and answer open questions with the most reasonable default. Track the decisions for the final report.

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

## Step 3 — UI (conditional)

Skip this step entirely if the feature has no UI.

Otherwise, launch `ui-feature-builder` with:
> Design and build the UI for this feature.
> Feature plan: [paste plan from Step 1]
> Client state summary from client-feature-builder: [paste relevant selectors, state keys, and dispatchable actions]
>
> Read existing primitives in `src/ui/Generic/Components/` and the closest existing feature UI under `src/features/*/ui/`, then ask the user the design intake questions before writing any feature UI file. Compose existing primitives where possible. If you need a generic primitive that doesn't exist, build it inline in `src/ui/Generic/Components/` and continue — do not stop or hand off. In your final summary, list any new generic primitives separately from feature UI files.

This agent is interactive: it will ask the user design questions. Surface its questions verbatim and wait for answers before letting it proceed.

## Step 4 — QA audit

Launch `qa-tester` with:
> Audit the implementation of: $0
> Files implemented:
> [list all files created/modified from Steps 2 and 3, including any new generic primitives the ui-feature-builder added]
> Focus areas flagged by client-feature-builder: [paste from Step 2 client output]
> Focus areas flagged by ui-feature-builder: [paste from Step 3 if present]
> Check all 7 audit categories. Report findings by severity.

## Step 5 — Report to user

After all agents complete, summarize to the user:
- What was built (files created/modified)
- Any QA findings that need addressing (Critical and High severity first)
- Any open items or follow-up work

If qa-tester finds Critical or High severity issues, ask the user whether to fix them before closing out.
