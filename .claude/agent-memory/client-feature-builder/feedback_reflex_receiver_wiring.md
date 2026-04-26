---
name: Reflex broadcast receiver wiring pattern
description: How to correctly wire createBroadcastReceiver — start fires automatically, receiver must be cached for PostInit
type: feedback
---

`Reflex.createBroadcastReceiver({ start = fn })` — the `start` callback fires automatically when `applyMiddleware` is called, not in PostInit. There is no `receiver:start()` method.

Correct pattern:
- `PreInit`: create receiver, build store with `combineProducers(...):applyMiddleware(receiver.middleware)`, store receiver on module table
- `PostInit`: wire `ReflexRemote:On(function(actions) receiver:dispatch(actions) end)`

The `start` function's job is to fire a remote to tell the server the client is ready for hydration.

**Why:** The plan template called `receiver:start()` in PostInit which doesn't exist. The actual `start` option is an options field called during middleware application.

**How to apply:** Always store `receiver` on the module table in PreInit so PostInit can reference it.
