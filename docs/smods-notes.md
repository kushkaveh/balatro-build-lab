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
