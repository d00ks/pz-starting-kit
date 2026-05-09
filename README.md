# Starting Kit — Project Zomboid B42

A small server-side mod that grants every new character:

- **Strength 10**
- **Fitness 10**
- **One Police Baton** (`Base.Baton`)

Applied once per character on first spawn (uses a `modData` flag for idempotency, so dying and rerolling re-applies it on the new character).

## Compatibility

- Build 42 (B42).
- Multiplayer: works fine, but **every player needs the mod folder dropped into their client** (the dedicated server doesn't push local mods to clients automatically — that's only done for Workshop mods).
- Single-player: works the same.

## Install

1. Download / clone this repo.
2. Place the `StartingKit` folder under your PZ mods directory:
   - **Windows**: `%USERPROFILE%\Zomboid\mods\StartingKit\`
   - **Mac**: `~/Library/Application Support/Zomboid/mods/StartingKit/`
   - **Linux**: `~/Zomboid/mods/StartingKit/`
3. Open the PZ launcher, enable **Starting Kit** in the Mods list.
4. If you're a server admin, also add `StartingKit` to the `Mods=` line in `servertest.ini`.

The folder structure should end up looking like:

```
StartingKit/
├── mod.info
└── 42/
    ├── mod.info
    └── media/lua/client/StartingKit_Client.lua
```

## What it does (under the hood)

`Events.OnCreatePlayer` fires when a player is created. The handler:

1. Checks `player:getModData().StartingKit_v1_applied` — bails if already set.
2. Loops `LevelPerk(Perks.Strength)` until level 10.
3. Loops `LevelPerk(Perks.Fitness)` until level 10.
4. Adds one `Base.Baton` if not already in inventory.
5. Marks the modData flag so it doesn't re-apply on next login.

## Tweaking

Open `42/media/lua/client/StartingKit_Client.lua` and change:

- The perks (e.g. `Perks.Sprinting`, `Perks.Nimble`).
- The target level (replace `9` in the for-loop bound — the loop runs `for i = current_level, 9` so it ends at level 10).
- The starting item (`"Base.Baton"` → `"Base.PipeWrench"`, `"Base.BaseballBat"`, etc).

Bump the modData flag (e.g. `StartingKit_v2_applied`) when you change behavior so existing characters get the new kit on next login.

## License

MIT — see [LICENSE](LICENSE).
