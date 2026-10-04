# Coin Climb

A solo Texas-themed Roblox obby: jump across platforms, avoid the chili pit, collect coins,
buy upgrades, and beat your best time. Full docs live in Notion ("Roblox Work").

## Layout
- `src/server/` → ServerScriptService.Server: game rules (course, lava, checkpoints, coins, run timer, shop, saving)
- `src/client/` → StarterPlayerScripts.Client: visuals, audio, UI
- `src/shared/` → ReplicatedStorage.Shared: data both sides read (course layout, upgrades, sounds)

## Workflow
1. `rojo serve` in this folder (or the Rojo button in VS Code's status bar)
2. In Studio: Plugins → Rojo → Connect
3. Edit code, press Play in Studio to test
4. Commit changes to git
5. **Publish: File → Publish to Roblox** (with Rojo connected). Saving alone does not update the live game or the phone version.
