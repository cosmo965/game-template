---
name: balance-check
description: Audit game economy values for outliers, progression cliffs, dead zones, and broken ladders. Optionally scope to a specific feature or config area. Runs the balance-designer agent in audit mode.
---

You are running a balance audit. The scope to audit is: $0

If `$0` is empty, audit the full project economy (all config files under `src/server/`).

Launch the `balance-designer` agent with the following prompt:

> Run in **audit mode**.
>
> Scope: $0 (if empty, audit the full project — read all config/balance files under src/server/)
>
> Steps:
> 1. Read src/server/Data/ to understand what currencies and data fields exist
> 2. Read every config file in the scope — Upgrades, Rebirth, SpinWheel, DailyRewards, and any module that exports a table of prices, multipliers, or rates
> 3. For each ladder found, check for: inverted steps, cliffs (>3× jump), dead zones (<0.5× step), rewards that dwarf the next upgrade cost, hardcoded round numbers that break the curve
> 4. Report findings using the audit output format: Critical / High / Low by severity, with file:line, issue description, current value, and suggested fix
> 5. End with a one-paragraph summary of the overall progression curve shape and the most urgent issue to address

Wait for the agent to return its report, then present the findings directly to the user.

If the agent finds **Critical** issues, ask the user whether to fix them now before closing out.
If there are no issues, confirm the economy looks consistent and briefly describe the curve pattern observed.