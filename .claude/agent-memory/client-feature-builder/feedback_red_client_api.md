---
name: Red client event API
description: Correct Red v2 client-side event API — use :On() and :Fire(), not .OnClientEvent
type: feedback
---

Red client events use `:On(callback)` to listen for server fires and `:Fire(...)` to send to the server.

There is no `.OnClientEvent` property on Red events (that's Roblox RemoteEvent API, not Red).

**Why:** The plan template for this project incorrectly referenced `.OnClientEvent`. Caught during implementation by reading the Red source.

**How to apply:** Any time client code listens on a Red event — always use `:On(callback)`. Any time client code sends to server — always use `:Fire(...)`.
