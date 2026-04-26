# Client Feature Builder Memory

- [Reflex + DataService scaffold](project_reflex_dataservice_scaffold.md) — Foundational Reflex root + DataService client layer. Store lives at `Reflex.Controller.Store`. Use `DataClientUtils:Get()`/`:WaitFor()` for player data.
- [Red client API](feedback_red_client_api.md) — Red client event uses `:On(callback)` to listen from server and `:Fire(...)` to send to server. No `.OnClientEvent`.
- [Reflex broadcast receiver wiring](feedback_reflex_receiver_wiring.md) — `options.start()` fires automatically on `applyMiddleware`. Store must be cached in `PreInit`; `receiver:dispatch` is wired in `PostInit`.
