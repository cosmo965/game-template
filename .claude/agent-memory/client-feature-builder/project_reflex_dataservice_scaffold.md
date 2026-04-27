---
name: Reflex + DataService client scaffold
description: Foundational Reflex broadcast receiver + DataService client controller. Store location, selector names, public API entry points.
type: project
---

The combined Reflex producer lives at `ReflexController.Store` (set in `PreInit`). AppContainer imports it as `RootProducer.Store`.

states key: `PlayerData` (matches server `combineProducers({ PlayerData = PlayerDataSlice })`).

Client selectors in `src/features/Reflex/client/state/PlayerData.luau`:
- `selectMyData(state)` — full data table for LocalPlayer, or nil
- `selectMyCoins(state)` — `data.Coins` or nil
- `selectMyJoinCount(state)` — `data.JoinCount` or nil

Public API for other features to get player data:
- `DataClientUtils:Get()` — returns current data or nil (no yield)
- `DataClientUtils:WaitFor()` — yields until data is non-nil, then returns it

`ReflexClientUtils.GetStore()` returns the combined producer.
`ReflexClientUtils.Selectors.PlayerData` re-exports all three selectors.

**Why:** AppContainer already imported `Client.Features.Reflex.Controller` as `RootProducer` before these files were built, so the Reflex scaffold is foundational and must always exist.

**How to apply:** Any client feature needing player data should import `DataService.client.Utils` rather than subscribing to Reflex state directly.
