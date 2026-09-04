# Test checklist

No headless rig exists for Balatro; testing is empirical. Hot-restart with mods: `Alt+F5` or hold `M`.
Lovely log: `%AppData%\Balatro\Mods\lovely\log\`. Tick items per milestone; a milestone is committed only
when its section is green.

## M0 — Environment
- [x] `Balatro.exe` launches with the Lovely console window open
- [x] Main menu shows the SMODS **Mods** button and the mod list opens
- [x] `Steamodded` shows version `26.829.0`
- [x] `DebugPlus` is listed (dev tool)
- [x] `docs/smods-notes.md` exists with links

## M1 — Mod boots
- [x] **Build Lab** is listed in the Mods menu with a crimson badge (`AA0F3C`), version 0.1.0, no error badge
- [x] `lovely/log/<latest>.log` contains `:: INFO  :: BuildLab :: Build Lab v0.1.0 loaded`
- [x] Log also contains `Valid JSON file found` for the BuildLab folder (the junction is picked up)
- [x] Disable Build Lab in the Mods menu → restart → game boots identically without it
- [x] Re-enable → restart → listed again

## Boot (regression, rerun after every Balatro/SMODS update)
- [ ] Clean install boots vanilla
- [ ] +Lovely boots
- [ ] +SMODS boots
- [ ] +BuildLab boots
- [ ] BuildLab disabled via SMODS toggle → vanilla behaviour byte-identical

## M2 — Impossible rarity + placeholder Joker
- [ ] Rarity "Impossible" registers; badge coloured
- [ ] Placeholder Understudy in Collection with tooltip
- [ ] Spawnable via DebugPlus; badge reads "Impossible"
- [ ] Never appears in shop / packs / The Soul across 3 test runs

## M3 — Run injection (no UI)
- [ ] Temporary keybind starts a run: Red deck, White stake, 2 known Jokers with editions, $20
- [ ] Run is saveable and continuable
- [ ] Vanilla New Run unaffected

## M4 — Build Lab page
- [ ] Play → New Run flow shows deck page, stake page, then **Build Lab** (nav button text)
- [ ] Page shows "Starting Jokers", five empty slots with Pick buttons, deck preview + stake tower on the right
- [ ] "DEV: sample build" fills Blueprint (foil) + Understudy (negative); cards render with edition shaders; hover shows tooltips
- [ ] Clear (X) empties a slot
- [ ] Play starts the run with the two Jokers, $20; save + Continue works
- [ ] Back / Esc closes the overlay without errors; reopening shows the last config
- [ ] Toggle "Hide Build Lab page" in config → page skipped (M9)

## M5 — Joker picker
- [ ] Pick opens the picker in place (nav Next disabled while open); Back returns to the panel
- [ ] Grid shows 10 real Joker cards per page with hover tooltips; page label and < > buttons work and wrap
- [ ] Typing in Search filters live (name or key); rarity cycler filters Common/Uncommon/Rare/Legendary/Impossible/Modded
- [ ] Clicking a card fills the slot, plays a sound, returns to the panel showing the card
- [ ] Same Joker in 2+ slots allowed; picking for slot 3 leaves other slots intact
- [ ] Open/close the picker 20× → no ghost cards, no leaked sprites, no log errors

## M6 — editions + advanced params
- [ ] Edition cycler under a filled slot: Base → Foil → Holographic → Polychrome → Negative; preview card re-shades instantly
- [ ] Started run: each Joker has the chosen edition; Negative ones don't consume slots (5 Negatives → 5 free slots)
- [ ] Advanced toggle reveals Money / Hands / Discards / Hand Size / Joker Slots / Consumable Slots cyclers; Auto leaves deck/stake effects intact (Blue Deck still +1 hand)
- [ ] Set Money 100, Hands 6, Discards 0, Hand Size 12, Joker Slots 8, Consumable Slots 4 → run reflects each
- [ ] Seed via the SMODS nav-bar toggle: two runs, same seed + same build → identical first shop
- [ ] Facepocalypse manually buildable and startable (once M8 Jokers exist)

## Builder (M4–M6)
- [ ] Every deck incl. modded; every stake
- [ ] Empty slots (0–5 Jokers); duplicate Joker in 2+ slots; same Joker ×5
- [ ] Each edition per slot; 5×Negative (slot math)
- [ ] Seed respected (two runs, same seed, same shop)
- [ ] Advanced params each at min / mid / max
- [ ] Full flow with mouse and with controller
- [ ] Picker: pick 5, hover tooltips correct, search + rarity filter, lists modded Jokers when another mod is installed
- [ ] Picker open/close ×20: no ghost cards, no leaked sprites

## Injection
- [ ] Started run is saveable/continuable
- [ ] Joker order preserved
- [ ] Negative Jokers don't consume slots
- [ ] Stickers correct (V1.x)

## M9 — layout + dynamic slots
- [ ] Build Lab page, picker, Advanced and Presets each fit above the nav bar with no overlap (deck preview + stake tower visible)
- [ ] Header reads "N / 5 slots"; setting a slot to Negative opens a 6th slot (one row, slightly smaller cards); two Negatives → 7 slots in two rows
- [ ] Advanced → Joker Slots 8 → panel shows 8 slots; back to Auto → extra empty slots vanish, filled ones beyond capacity turn red with the "Over the slot limit" line
- [ ] Start a run with 5 Negatives + 5 more Jokers → all 10 present, 5 free Joker slots remain
- [ ] Picker shows 12 cards per page (2×6); count text and page text update with search/filter

## M9 — polish / config
- [ ] Mods → Build Lab → Config: two toggles render; toggling "Hide the Build Lab page" then reopening New Run skips page 3
- [ ] "Impossible Jokers in shops" on → over ~10 shops with rerolls at least one Impossible Joker can appear; off → never
- [ ] Config survives restart (`%AppData%/Balatro/config/BuildLab.jkr` written when leaving the Mods menu)
- [ ] Mod list shows version 1.0.0
- [ ] Controller: every panel button/cycler reachable with d-pad; picker cards focusable

## Impossible Jokers (M8)
- [ ] Each alone; each + Blueprint; each + Brainstorm; each + Showman duplicates
- [ ] Fun Hoe + Pareidolia: deck-drain over 10 hands, no crash on tiny deck
- [ ] Bambino rightmost / all-Negative row / converting next to Eternal
- [ ] Jazzy: leftmost card destroyed mid-score; Zoomies + Oops! All 6s
- [ ] Understudy at row edges; Understudy×2 adjacent; Understudy next to a Blueprint chain
- [ ] Forger + Midas Mask; Forger save/reload mid-round (no double stamp)

## Presets (M7)
- [ ] Presets button opens the list in place; built-ins Facepocalypse and Baron Machine listed in orange with mini cards
- [ ] Type a name, "Save current as" → row appears; `presets.json` written in the mod folder
- [ ] Load sets slots, editions, params, AND switches the deck preview + stake tower to the preset's deck/stake
- [ ] Overwrite replaces the config; Delete removes the row; built-ins have Load only
- [ ] Save / load / delete; restart persistence
- [ ] Preset referencing an uninstalled modded Joker → warning slot, run still startable
- [ ] Hand-corrupted JSON → reset with message, no crash
- [ ] Built-ins Facepocalypse and Baron Machine load

## Compat matrix
- [ ] + Cryptid, + Galdur, + Talisman, + a deck-adding mod: picker lists their content, runs start, no calc crashes

## Regression cadence
Rerun Boot + one full Builder flow + one Joker-interaction spot check after every SMODS/Balatro update.
