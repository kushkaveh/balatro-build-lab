# Build Lab — architecture (condensed, kept current)

Full plan: [`../build-lab-technical-product-plan.md`](../build-lab-technical-product-plan.md).
Where this document differs from the plan, this document is what was built (and why).

## One line
A **Build Lab** page in Steamodded's run-select flow writes a plain Lua **RunConfig**; a single hook on
`Game:start_run` turns it into a vanilla challenge-shaped table at run start; a self-contained content pack
adds the **Impossible** rarity and five Jokers that work even if the builder page is hidden.

## Stack
Lovely v0.9.0 → Steamodded 26.829.0 (stable) → this mod at `%AppData%\Balatro\Mods\BuildLab` (a junction
to this repo). Balatro 1.0.1o. No other hard dependency. Zero Lovely patches of our own.

## Deviation from the plan: run-select page instead of a tab
Steamodded 26.829.0 ships **Run Select Pages** (`SMODS.RunSelectPage`, `src/utils/run_select.lua`), the
Galdur-derived system the plan predicted. Registering any page makes Steamodded replace the vanilla New Run
tab with its paged flow: deck page → stake page → **Build Lab** (page 3) → Play. Consequences:
- Deck and stake are chosen on Steamodded's own pages, so the Build Lab panel has no deck/stake cyclers.
  Loading a preset writes `deck_choice` / `stake_choice` into `SMODS.RunSelect.Setup.choices` and refreshes
  the built-in previews.
- Seed uses Steamodded's nav-bar seed toggle, not a field of ours.
- The Play button is Steamodded's. Our config travels as `SMODS.RunSelect.Setup.choices.build_lab`, which
  Steamodded copies into the args of `G.FUNCS.start_run` → `Game:start_run(args)`, where `src/hooks.lua`
  reads `args.build_lab`.
- "Quick Start" repeats the last choices, Build Lab config included.

## Modules
```
src/hooks.lua           ALL wraps of vanilla/SMODS functions: Game:start_run, G.FUNCS.exit_overlay_menu, Card:click
src/run_config.lua      RunConfig model: new / sanitize / set_joker / set_edition; params nil = "Auto"
src/run_injector.lua    RunConfig -> challenge table {rules.modifiers, jokers={id, edition, eternal, pinned}}
src/presets.lua         presets.json (NFS + JSON), two built-ins, corrupt-file reset with backup
src/ui/buildlab_tab.lua SMODS.RunSelectPage registration + Mods-menu config tab
src/ui/main_panel.lua   five slot CardAreas, edition cyclers, Advanced params row, panel swapping
src/ui/joker_picker.lua paged grid of real Joker cards, live search, rarity filter
src/ui/presets_modal.lua list rows with mini cards, save/load/overwrite/delete
impossible/rarity.lua   SMODS.Atlas + SMODS.Rarity 'bl_impossible' (weight 0; config can enable a tiny weight)
impossible/jokers/*.lua one SMODS.Joker per file
```

## Data flow
```
Build Lab panel  ──edits──►  SMODS.RunSelect.Setup.choices.build_lab  (RunConfig, plain data)
        ▲                                   │  Play (SMODS.RunSelect.Functions.start_run)
   presets.json  ◄──save/load──             ▼
                              G.FUNCS.start_run(nil, {build_lab=cfg, deck_choice, stake_choice, seed})
                                            │
                              hooks.lua: args.challenge = injector.to_challenge(cfg)
                                            ▼
                              vanilla Game:start_run applies jokers (+editions/eternal/pinned) and
                              starting_params modifiers  →  normal, saveable run
```
The challenge table has no `id`, so `G.GAME.challenge` stays nil: unlocks, high scores and the restart
button behave exactly as in a normal (or seeded) run.

## Dynamic slots
Negative Jokers don't occupy a Joker slot (card.lua:410-413), so the panel's capacity is
`joker_slots (or 5) + number of Negative-edition slots`, capped at 20. Each Negative you set opens one more
slot, capped at 20. The panel always shows one row of five full-size slots; extra slots live on further pages reached with
< > arrows (Collection-style paging), and the status line points at free slots on other pages. Filled slots
beyond capacity (after removing a Negative) are outlined red and skipped by the injector.

## UI approach
Everything is a `UIBox` tree built from vanilla helpers (`UIBox_button`, `create_option_cycle`,
`create_toggle`, `create_text_input`) inside Steamodded's page ROOT. Sub-screens (picker, presets) swap
the content of one `G.UIT.O` node exactly like `G.FUNCS.change_tab` does, so the run-setup overlay and
Steamodded's nav bar stay alive; `can_continue` disables Next while a sub-screen is open. Every Joker shown
is a real `Card` in a `CardArea` of type `'title'` (invisible background, vanilla tooltips). CardAreas are
scrubbed on rebuild and on overlay exit, mirroring Steamodded's own clean-up.

## Design rules (unchanged)
- No base-game edits; hooks only in `src/hooks.lua`, wrap-and-call-original.
- No Lovely patches unless unavoidable (none so far; see `docs/patches.md`).
- Config is data: presets are validated by `run_config.sanitize`; unknown Joker keys become a warning slot.
- Every API call is verified against source first and logged in `docs/smods-notes.md`.

## Content pack notes
- Rarity key is `bl_impossible` (Steamodded prefixes rarity keys); badge colour `AA0F3C`; name from
  `misc.dictionary.k_bl_impossible`.
- All five Jokers guard state mutation with `not context.blueprint and not context.retrigger_joker`, so
  Blueprint / Brainstorm / Understudy copies deliver effects without double-firing counters.
- The Forger is `blueprint_compat = false`; the others are copyable. Saving Face and Velvet Rope create
  cards, so a copy creates more (vanilla DNA / Riff-Raff precedent); Smelter, Dude and Singularity copies
  deliver the current Mult/XMult only.
- Wave 2 (v1.1) contexts: `remove_playing_cards` (Saving Face), `setting_blind` (Velvet Rope), `individual`
  (Smelter), `end_of_round` + `hands_left/discards_left` (Dude), `selling_card` + `joker_type_destroyed`
  (Singularity, de-duplicated per `card.sort_id`).
- Art: `tools/build_atlas.py` crops the `joker-design-*.png` card frames to 71×95 (1x) and 142×190 (2x).
