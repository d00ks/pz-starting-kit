# Starting Kit — Project Zomboid B42

A small mod that grants every new character on a multiplayer server:

- **Strength 10**
- **Fitness 10**
- **One Police Nightstick** (`Base.Nightstick`)

Applied once per character on first spawn (uses a server-side `modData` flag for idempotency, so dying and rerolling re-applies it on the new character).

## Compatibility

- Build 42 (B42 unstable, tested on the May 2026 builds).
- Multiplayer dedicated server: **yes, this is what it's designed for**. The kit is applied server-side via an authoritative client→server handshake, so values stick (B42 reverts client-side perk changes on body skills).
- Multiplayer with the host-game/coop mode: should work.
- Single-player: works.

## Install

Both the **server** and **every connecting client** need the mod folder.

1. Download / clone this repo (or grab a release zip).
2. Place the `StartingKit` folder where PZ looks for mods:
   - **Server (dedicated, with `-cachedir=...`)**: `<cachedir>\mods\StartingKit\` (e.g. `C:\PZServer\mods\StartingKit\`).
   - **Server (default location)**: `%USERPROFILE%\Zomboid\mods\StartingKit\`.
   - **Client (Windows)**: `%USERPROFILE%\Zomboid\mods\StartingKit\`.
   - **Client (Mac)**: `~/Library/Application Support/Zomboid/mods/StartingKit/`.
   - **Client (Linux)**: `~/Zomboid/mods/StartingKit/`.
3. Add `StartingKit` to the `Mods=` line in your server's `servertest.ini`.
4. In each client's PZ launcher, enable **Starting Kit** in the Mods list.

The folder layout should look like:

```
StartingKit/
├── mod.info
└── 42/
    ├── mod.info
    └── media/lua/
        ├── client/StartingKit_Client.lua
        └── server/StartingKit_Server.lua
```

## How it works

PZ B42 dedicated MP is server-authoritative for body skills (Strength/Fitness) and inventory — calling `xp:AddXP()` or `inv:AddItem()` from a client-side mod is silently reverted by the server on the next sync.

So the mod splits the work:

- **Client side** (`media/lua/client/StartingKit_Client.lua`): on `Events.OnGameStart`, waits until the local player is fully resolved (not the placeholder "Bob" used during the loading transition) and sends `sendClientCommand("StartingKit", "applyKit", {})` to the server.
- **Server side** (`media/lua/server/StartingKit_Server.lua`): on `Events.OnClientCommand`, applies the kit using authoritative server-side calls:
  - **`LevelPerk` loop** (not `AddXP`) — body skills don't level reliably from `AddXP` even server-side; this is what admin RCON `addxp` calls under the hood.
  - **`inv:AddItem("Base.Nightstick")`** for the baton.
  - **server-side modData flag** (`StartingKit_v7_serverApplied`) persisted in `players.db` so each character gets the kit exactly once.

## Tweaking

Edit `42/media/lua/server/StartingKit_Server.lua`:

- **Different perks**: change `Perks.Strength` / `Perks.Fitness` to e.g. `Perks.Sprinting`, `Perks.Nimble`, etc.
- **Different target level**: change `TARGET_LEVEL = 10` to whatever you want.
- **Different starting item**: change `BATON_ID = "Base.Nightstick"` to e.g. `Base.BaseballBat`, `Base.HammerStone`, etc.
- **Force re-apply on existing characters**: bump `SERVER_FLAG = "StartingKit_v7_serverApplied"` to v8 (or anything new).

The client side rarely needs editing — it's just the trigger.

## License

MIT — see [LICENSE](LICENSE).
