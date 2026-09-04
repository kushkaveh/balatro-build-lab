# Build Lab — architecture (condensed, kept current)

Full plan: [`../build-lab-technical-product-plan.md`](../build-lab-technical-product-plan.md).

## One line
A native-styled **Build Lab** page in the run-setup flow writes a plain Lua **RunConfig** table; a small
hook applies it when the run starts; a self-contained content pack adds the **Impossible** rarity and five
Jokers that work even if the builder UI is disabled.

## Stack
Lovely v0.9.0 (runtime injector, `version.dll` next to `Balatro.exe`) → Steamodded 26.829.0 stable
(mod loader + content API) → this mod in `%AppData%\Balatro\Mods\BuildLab` (a junction to this repo).
No other hard dependency. Balatro 1.0.1o.

## Two loosely-coupled modules
1. `src/` (+ `src/ui/`) — the Run Builder. UI, RunConfig model, run injection, presets. Knows nothing
   about our Jokers; it lists whatever is in `G.P_CENTER_POOLS` (so modded Jokers appear for free).
2. `impossible/` — the content pack. `SMODS.Rarity` + five `SMODS.Joker` files + atlas + localization.

## Data flow
```
Build Lab UI  →  RunConfig table  →  presets.lua (JSON on disk)
                      │
                      ▼
      run_injector.lua: config → challenge-shaped ruleset handed to the vanilla
      run-start path, then post-start SMODS.add_card per slot (editions / stickers)
                      │
                      ▼
                normal Balatro run (saveable, resumable)
```

## Design rules
- No base-game edits. All vanilla hooks live in `src/hooks.lua`, wrap-and-call-original.
- No Lovely patches unless unavoidable; each documented in `docs/patches.md`.
- Native UI only: `UIBox` trees from vanilla helpers, real `Card` objects in a `CardArea`, vanilla
  colours/sounds. Imitate the closest vanilla screen (run setup, Collection).
- Config is data, not code. A preset is `{ name, deck, stake, jokers = {{key, edition, stickers}, ...},
  params = {...}, seed }`. Unknown keys (uninstalled mods) degrade to a warning slot, never a crash.
- Every API call is verified against source first and logged in `docs/smods-notes.md`.

## Milestones
M0 env → M1 boot → M2 rarity + placeholder Joker → M3 hardcoded injection → M4 tab + panel →
M5 picker → M6 editions + params → M7 presets → M8 five Jokers (one commit each) → M9 polish.
Each ends with an in-game confirmation before the next begins.
