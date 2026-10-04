# 🤠 Coin Climb

A Texas-themed obstacle course (obby) on Roblox, written in Luau. Jump across platforms, dodge a
pit of red-hot chili, collect gold coins, spend them on upgrades in the General Store, and race
your best time. Progress is saved between sessions, and the game plays on desktop and mobile.

Built with an external-editor workflow: code lives in this repo, is edited in VS Code, and is
synced into Roblox Studio with [Rojo](https://rojo.space).

## Features
- **Course built from data.** Platforms, coins, and hazards are defined in one layout file and built at runtime.
- **Checkpoints.** "Lone Star" flags turn gold, and you respawn at the furthest one you've reached.
- **Coins and upgrade shop.** Coins come back after being collected. Spend them on *Roadrunner Boots* (speed) and *Jackrabbit Legs* (jump), and use upgrades to reach high bonus coins.
- **Run timer.** Starts on the blue pad, stops at the finish, and tracks your personal best.
- **Finish celebration.** Banner, fireworks, and fanfare, then an automatic restart. A Restart button is always available.
- **Saving.** Coins, upgrades, and best time are stored with DataStores.
- **Desert scenery.** Mesas, cacti, grazing longhorns, a spinning windmill, circling vultures, drifting clouds, and rolling tumbleweeds.

## Architecture

```
src/
├── server/   → ServerScriptService   game rules: course, hazards, checkpoints, coins, runs, shop, saving
├── client/   → StarterPlayerScripts  presentation: scenery, animation, audio, HUD, shop UI
└── shared/   → ReplicatedStorage     data both sides read: course layout, upgrade prices, sound IDs
```

**Design principles**
- **Authoritative server.** The server owns all game state and validates every client request (e.g. purchases), and the client only renders and sends input.
- **Data-driven content.** The course, prices, and sounds are plain data, so tuning the game doesn't mean changing logic, and client and server share a single source of truth.
- **Composition through tags.** The course builder only creates and tags parts (`Lava`, `Checkpoint`, `Coin`, `RunStart`, `Finish`). Separate modules attach the behavior to each tag.
- **Event-driven.** Modules react to touches, spawns, attribute changes, and remote events, with no polling.
- **Defensive persistence.** DataStore calls are wrapped in `pcall`, saving is turned off after a failed load so real data is never overwritten, and there's autosave plus save-on-shutdown.

**Client ↔ server messages** (in ReplicatedStorage)

| Name | Type | Direction | Purpose |
|---|---|---|---|
| `Celebrate` | RemoteEvent | server → client | Finish reached: show time and fireworks |
| `RestartRun` | RemoteEvent | client → server | Player pressed Restart (rate-limited) |
| `BuyUpgrade` | RemoteFunction | client → server → reply | Purchase request, validated on the server |

## Running it locally
Requirements: [Roblox Studio](https://create.roblox.com), and [Rokit](https://github.com/rojo-rbx/rokit) to install the pinned toolchain.

```bash
rokit install   # installs the Rojo version pinned in rokit.toml
rojo serve      # start the sync server
```

Then in Studio: open a Baseplate place, go to **Plugins → Rojo → Connect**, and press **Play**.
To test saving in Studio, the place must be saved to Roblox with
*Game Settings → Security → Enable Studio Access to API Services* turned on.

## Possible next steps
- Strict Luau types (`--!strict`), unit tests, Selene and StyLua, and CI
- Session-locked saving (`UpdateAsync` / ProfileStore)
- Server-side movement sanity checks (anti-teleport)
- Object pooling for the fireworks
- Multiplayer, with per-player coins and flags
