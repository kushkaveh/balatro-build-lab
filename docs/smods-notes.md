# SMODS / vanilla API ledger (anti-hallucination)

Rule: no `SMODS.*`, `G.*`, `Card:*`, `CardArea:*`, or vanilla global may be called from this mod unless it
has a row here with a verifiable source. Add the row **before** writing the call. Re-verify every row after
a Balatro or SMODS update (`git log docs/smods-notes.md` shows what we depend on).

Local sources (read-only, outside the repo):
- SMODS stable 26.829.0 + main: `K:\Projects\reference-mods\smods\` (`../reference-mods/smods/`)
- Vanilla 1.0.1o: `K:\Projects\balatro-src\` (`../balatro-src/`)
- GPL mods: `../reference-mods/Galdur/` (GPL-3.0, branch master), `../reference-mods/Cryptid/` (GPL-3.0),
  `../reference-mods/Balatro-DeckCreator/` (GPL-3.0, mod under `src/mods/Deck Creator/`)
- Online: https://docs.smods.dev (canonical), https://github.com/Steamodded/smods

## Toolchain facts

| Fact | Value | Source | Verified |
|---|---|---|---|
| Lovely latest release | v0.9.0 (2026-01-21), asset `lovely-x86_64-pc-windows-msvc.zip` | https://github.com/ethangreen-dev/lovely-injector/releases/tag/v0.9.0 | 2026-09-04 |
| Lovely install (Windows) | copy `version.dll` next to `Balatro.exe`; mods live in `%AppData%/Balatro/Mods`; logs `Mods/lovely/log`, dumps `Mods/lovely/dump` | https://github.com/ethangreen-dev/lovely-injector#manual-installation | 2026-09-04 |
| SMODS stable version | `26.829.0` (`version.lua` returns `"26.829.0"`), release 2026-08-29 | https://github.com/Steamodded/smods/releases/tag/26.829.0 ; `../reference-mods/smods/version.lua` | 2026-09-04 |
| SMODS download | `https://download.smods.dev` → 301 → `github.com/Steamodded/smods/archive/refs/heads/stable.zip` | curl redirect | 2026-09-04 |
| SMODS main version | `26.903.0~dev-a` | https://raw.githubusercontent.com/Steamodded/smods/main/version.lua | 2026-09-04 |
| Restart with mods | `Alt+F5` or hold `M`; implemented by `SMODS.restart_game()` | https://docs.smods.dev/Guides/Your-First-Mod/ ; `../reference-mods/smods/src/utils.lua:482` | 2026-09-04 |
| Balatro version | `1.0.1o` (`version.jkr`: `1.0.1o-FULL`) | `../balatro-src/version.jkr` | 2026-09-04 |
| Typed API stubs | `lsp_def/{smods_core,ui,utils,vanilla}.lua`, `lsp_def/classes/` | `../reference-mods/smods/lsp_def/` | 2026-09-04 |
| DebugPlus | MPL-2.0 dev tool; `/` console, hold `Tab` menu; **no code copying** | https://github.com/WilsontheWolf/DebugPlus | 2026-09-04 |

## Mod metadata (`buildlab.json`)

| Item | Verified behaviour | Source | Verified |
|---|---|---|---|
| File discovery | any `*.json` inside the mod folder (depth > 1 under `Mods/`) is parsed as metadata; invalid → `Found invalid metadata JSON file ... ignoring`; valid → log `Valid JSON file found` | `../reference-mods/smods/src/preflight/loader.lua:300-336` | 2026-09-04 |
| Required fields | `id` (string), `name` (string), `author` (array of strings), `description` (string), `prefix` (string, no default, may not contain `$`) | `loader.lua:135-150`; https://docs.smods.dev/API%20Documentation/Mod-Metadata/ | 2026-09-04 |
| `main_file` | executed with `load(NFS.read(mod.path .. mod.main_file))` while `SMODS.current_mod = mod` | `loader.lua:749,783,796` | 2026-09-04 |
| Optional fields | `display_name` (defaults to `name`), `priority` (number, default 0, low loads first), `badge_colour`/`badge_text_colour` (hex `RRGGBB[AA]`, fallback `666665`/`FFFFFF`), `badge_shader`, `version`, `dependencies`, `conflicts`, `provides`, `dump_loc` | `loader.lua:144-152`; docs page above | 2026-09-04 |
| `version` format | `major.minor.patch[rev]`; parsed by `sUtil.V`; invalid → `0.0.0` | `loader.lua:151`; `../reference-mods/smods/src/preflight/sharedUtil.lua:61-84` | 2026-09-04 |
| Dependency syntax | `"Id (>=1.2.3)"`; ops `>= <= == >> <<`; alternatives with `|`; `Steamodded (>=26.829.0)` parses as major 26 / minor 829 / patch 0 | `loader.lua:153-186`, `sharedUtil.lua:61-73`; Cryptid uses `"Steamodded (>=1.0.0~BETA-2010b)"` (`../reference-mods/Cryptid/Cryptid.json`, GPL-3.0) | 2026-09-04 |
| `.lovelyignore` | a file named `.lovelyignore` in the mod folder = disabled by the Mods menu toggle | `loader.lua:337-339`; `src/ui.lua:1591` | 2026-09-04 |
| Metadata shape reference | `Cryptid.json` (GPL-3.0) used as the template for `buildlab.json` | `../reference-mods/Cryptid/Cryptid.json` | 2026-09-04 |

## Functions used so far

| API | Exact signature | Notes | Source | Verified | Used in |
|---|---|---|---|---|---|
| `sendInfoMessage` | `sendInfoMessage(message, logger)` | prints `YYYY-MM-DD HH:MM:SS :: INFO  :: <logger> :: <message>` to stdout (Lovely console + `Mods/lovely/log`). Siblings: `sendTraceMessage`, `sendDebugMessage`, `sendWarnMessage`, `sendErrorMessage`, `sendFatalMessage` (same args); `sendMessageToConsole(level, logger, message)` | `../reference-mods/smods/src/preflight/logging.lua:18-54`; https://docs.smods.dev/API%20Documentation/Logging/ | 2026-09-04 | `main.lua` |
| `SMODS.load_file` | `SMODS.load_file(path, id) -> chunk | nil, err` | `path` relative to the mod folder; `id` optional only while the mod is being loaded (`SMODS.current_mod` set). Returns a **function**; call it: `assert(SMODS.load_file("src/x.lua"))()` | `../reference-mods/smods/src/preflight/loader.lua:873-895`; https://docs.smods.dev/API%20Documentation/Utility/ | 2026-09-04 | `main.lua` (M2+) |
| `SMODS.current_mod` | table: the mod being loaded (`id`, `path`, `prefix`, `config`, …); `nil` after load | set at `loader.lua:749`, cleared at `:796`; stub `lsp_def/smods_core.lua:60` | 2026-09-04 | (not yet) |

## TO VERIFY before use (M2 / M3)

Not yet verified — do not call until a row above exists:
`SMODS.Rarity`, `SMODS.Joker`, `SMODS.Atlas`, `SMODS.add_card`, `SMODS.create_card`, `SMODS.Keybind`,
`SMODS.Challenge`, `SMODS.current_mod.config` persistence, `G.P_CENTER_POOLS`, `G.FUNCS.start_run`,
`Game:start_run`, `G.UIDEF.run_setup_option`, `create_option_cycle`, `UIBox_button`, `create_text_input`,
`Card:set_edition`, `Card:juice_up`, `CardArea` lifecycle in menus.

## M2 — rarity, atlas, Joker, localization (verified 2026-09-04 against smods stable 26.829.0)

| API | Exact signature / fields | Notes | Source | Used in |
|---|---|---|---|---|
| `SMODS.Atlas` | `SMODS.Atlas{key, path, px, py, atlas_table?, frames?, fps?}` | key is mod-prefixed (`bl_jokers`); Jokers reference it un-prefixed (`atlas='jokers'`) because referencing fields are prefixed too. Loads `assets/<1x|2x>/<path>`; either scale alone is enough (other is rescaled) | `../reference-mods/smods/src/game_object.lua:469-563`, `:74-80` | `impossible/rarity.lua` |
| `SMODS.Rarity` | `SMODS.Rarity{key, badge_colour=HEX'...', default_weight=0, pools={Joker=true|{weight=n}}, get_weight(self, weight, object_type)}` | key becomes `bl_impossible`; `inject` creates `G.P_JOKER_RARITY_POOLS[key]` and `G.C.RARITY[key]`; weight 0 is never selected by `SMODS.poll_rarity`; name from `misc.dictionary['k_'..key:lower()]` and `misc.labels[...]` | `game_object.lua:1026-1075`; `src/utils.lua:876-918`; Cryptid `lib/content.lua:354-374` (GPL-3.0) | `impossible/rarity.lua` |
| `SMODS.Joker` | fields: `key, atlas, pos{x,y}, rarity (1-4 \| 'Common'.. \| custom key), cost=3, unlocked=true, discovered=false, blueprint_compat=true, eternal_compat=true, perishable_compat=true, config={}, pools, no_collection, in_pool(self,args)`; callbacks `calculate(self, card, context)`, `loc_vars(self, info_queue, card)`, `add_to_deck(self, card, from_debuff)`, `remove_from_deck`, `set_ability`, `update` | final key `j_bl_<key>`; custom rarity asserted against `G.P_JOKER_RARITY_POOLS` | `game_object.lua:1413-1449`, `:1300-1408`; `lovely/center.toml:56-81` | `impossible/jokers/*.lua` |
| `config.extra` → `card.ability.extra` | every `config` key except `bonus` is copied to `card.ability` (tables deep-copied) | | `lovely/center.toml:22-37` | Jokers |
| `loc_vars` return | `{vars={...}, key?, set?, scale?, text_colour?}` | | `game_object.lua:1352-1408` | Jokers |
| `context.joker_main` | `{joker_main=true, cardarea=G.jokers, full_hand, scoring_hand, scoring_name, poker_hands}` | return `{xmult=n}` (also `x_mult`, `Xmult`); `{mult=n}`, `{chips=n}`, `{message=, colour=}` | `lovely/better_calc.toml:487-488`; `game_object.lua:3938-4036` (`x_mult` branch at 4014); `src/utils.lua:1287-1567` | Jokers |
| Localization file | `localization/en-us.lua` returns `{descriptions={Joker={j_bl_x={name, text={...}}}}, misc={dictionary={}, labels={}}}`; loaded en-us → default → language, file wins over `loc_txt` | text markup `{C:mult}`, `{X:mult,C:white}`, `#1#` as vanilla | `src/utils.lua:187-238`; vanilla `localization/en-us.lua:1032-1038` | `localization/en-us.lua` |
| `HEX(hex)` | `HEX('RRGGBB[AA]') -> {r,g,b,a}` | vanilla global | `../balatro-src/functions/misc_functions.lua:355` | rarity |
| `SMODS.current_mod.config` | merged `config.lua` defaults + `config/<id>.jkr`; saved only by `SMODS.save_all_config()` (exit Mods menu / restart keybind); `mod.config_tab = function() return nodes end` adds a Config tab | | `src/ui.lua:1656-1705`, `:555-565`; `src/preflight/loader.lua:782` | `main.lua`, `config.lua` |

## M3 — run injection (verified 2026-09-04)

| API | Exact signature / behaviour | Source | Used in |
|---|---|---|---|
| `G.FUNCS.start_run(e, args)` | `args = {stake, seed, challenge, savetext}`; clears queue, `G:delete_run()`, `G:start_run(args)` | `../balatro-src/functions/button_callbacks.lua:2958-2979`; SMODS defaults `args = args or {}` (`lovely/fixes.toml:8-16`) | `src/run_injector.lua` |
| `Game:start_run(args)` | reads `args.savetext/stake/seed/challenge` (+ SMODS `args.deck_choice={name=}`, `args.stake_choice=<order>`); challenge applied only when not loading a save | `../balatro-src/game.lua:2018-2168`; `smods/lovely/run_select.toml:22-45` | `src/hooks.lua` |
| Challenge table shape | `{name, id?, rules={custom={}, modifiers={{id, value}}}, jokers={{id, edition='negative'|'foil'|'holo'|'polychrome', eternal, pinned}}, consumeables={}, vouchers={}, deck={type=<deck name>}?, restrictions={banned_cards={}, banned_tags={}, banned_other={}}}`; `modifiers` assign `G.GAME.starting_params[id] = value` (ids `dollars, hands, discards, hand_size, joker_slots, consumable_slots, reroll_cost`); omitting `id` leaves `G.GAME.challenge` nil (unlocks/high scores vanilla); `restrictions.*` must be tables (SMODS calls them if functions) | `game.lua:2063-2149`; `challenges.lua:220-252`; `smods/lovely/challenge.toml:47-93` | `src/run_injector.lua` |
| `add_joker(joker, edition, silent, eternal)` | vanilla creator used by the challenge loop; `edition` is a type name → `card:set_edition{[edition]=true}` | `../balatro-src/functions/common_events.lua:372-384` | (indirect) |
| `get_starting_params()` | `{dollars=4, hand_size=8, discards=3, hands=4, reroll_cost=5, joker_slots=5, ante_scaling=1, consumable_slots=2, no_faces=false, erratic_suits_and_ranks=false}`; stake/deck effects modify it before the challenge modifiers overwrite | `../balatro-src/functions/misc_functions.lua:1868-1881`; `game.lua:2050-2061` | `src/run_config.lua` |
| Seed | `args.seed` → `G.GAME.seeded = true`, `pseudorandom.seed = args.seed` | `game.lua:2162-2168` | injector |
| `G.P_CENTERS[key]` / `G.P_STAKES[key]` | Back centres have `.name` (deck name used by `get_deck_from_name`); stakes have `.order` (1-based index = `G.GAME.stake`) | `game.lua:628-644`, `:252-260`; `smods/src/game_object.lua:798-845` | `run_config`, `injector` |
| `SMODS.Keybind` | `SMODS.Keybind{key_pressed='f9', held_keys={}, event='pressed'|'released'|'held', held_duration=1, action=function(self) end}` | `smods/src/game_object.lua:3776-3803`; `lovely/keybind.toml` | `run_injector.lua` (M3 temp) |
| `G.STAGE == G.STAGES.MAIN_MENU` | stage enum | `../balatro-src/globals.lua` (STAGES); used at `button_callbacks.lua:5313` | injector |
| `sendWarnMessage` / `sendErrorMessage` | `(message, logger)` | `smods/src/preflight/logging.lua:31-38` | hooks, injector |
