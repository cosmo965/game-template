---
name: Data feature Reflex slice require path
description: DataServerSlice is mapped under ServerScriptService.Server.Features.Data after genRojoTree.js runs
type: project
---

After running genRojoTree.js, the Data feature's server Reflex slice (state/Server.luau) is accessible at:
`ServerScriptService.Server.Features.Data.DataServerSlice`

Internal.luau requires it this way. The client slice (state/Client.luau) is at:
`ReplicatedStorage.Client.Features.Data.DataClientSlice`

**Why:** The genRojoTree.js generator names server state slices as `${featureName}ServerSlice` under the server feature folder. For Data, that's DataServerSlice.

**How to apply:** When other features need to listen to Data state changes or when wiring the Reflex broadcaster, use these paths.
