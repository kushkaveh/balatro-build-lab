# CLAUDE.md — Build Lab operating manual

Read this before writing anything. Product plan: `build-lab-technical-product-plan.md` (§12 structure,
§13 milestones, §9 Joker specs). Condensed architecture: `docs/architecture.md`.

## Ground rules (from the project owner, verbatim)

1. First set up references: clone Steamodded/smods, Eremel/Galdur, SpectralPack/Cryptid, and
   adambennett/Balatro-DeckCreator into `../reference-mods/` (read-only), and ask me to place extracted
   Balatro source at `../balatro-src/`. Never call an SMODS, G.*, or Card API you haven't verified in
   docs.smods.dev, SMODS source, vanilla source, or a GPL reference mod — log every verified signature in
   `docs/smods-notes.md` with a source link. Copy patterns only from GPL projects, with a credit comment.
   Never invent APIs.
2. Follow the repo structure in §12 and the milestones in §13 exactly, in order: M1 boot → M2 Impossible
   rarity + placeholder Joker → M3 hardcoded run injection → M4 Build Lab tab → M5 Joker picker →
   M6 editions + params → M7 presets → M8 the five real Impossible Jokers (one commit each, specs in §9) →
   M9 polish.
3. All UI must be native Balatro UIBox trees imitating the closest vanilla screen (run setup, Collection).
   No custom chrome. All vanilla hooks live only in `src/hooks.lua`, wrap-and-call-original. No base-game
   edits; no Lovely patches unless unavoidable and documented in `docs/patches.md`.
4. Smallest change → I run the game and report/screenshot → verify against `docs/test-checklist.md` →
   commit as "M<n>: <feature>". Stop and wait for my in-game confirmation at the end of every milestone
   before continuing. When something crashes, ask me for the Lovely log before changing code.

## Additional rules (§15 of the plan)

5. UI work: find the closest vanilla screen in `../balatro-src/functions/UI_definitions.lua`, read its
   `G.UIDEF.*` function, imitate its node structure.
6. If Balatro/SMODS updates break the mod: `git log docs/smods-notes.md` to see which APIs we depend on,
   re-verify each against the new source, fix `src/hooks.lua` first.
7. Never copy code from DebugPlus (MPL-2.0) or ZokersModMenu (unlicensed). Ideas only.
8. Placeholder art until the owner supplies final art: labeled solid-colour 71×95 sprites in the atlas.

## Environment (this machine, verified 2026-09-04)

| What | Where |
|---|---|
| Game | `<Balatro folder>\Balatro.exe` (v1.0.1o) |
| Lovely | v0.9.0, `version.dll` next to `Balatro.exe` |
| Mods dir | `%AppData%\Balatro\Mods\` (`%AppData%\Balatro\Mods\`) |
| SMODS | `Mods\Steamodded\` — stable 26.829.0 |
| DebugPlus | `Mods\DebugPlus\` — dev tool, `/` opens console, hold `Tab` for debug menu |
| This mod | `Mods\BuildLab` is a **directory junction** → `K:\Projects\buildlabmod` (this repo) |
| Lovely log | `%AppData%\Balatro\Mods\lovely\log\` — ask the owner to paste it after any crash |
| Patched-source dumps | `%AppData%\Balatro\Mods\lovely\dump\` |
| SMODS source (stable + main) | `K:\Projects\reference-mods\smods\` (read-only; `lsp_def/` has typed API stubs) |
| GPL reference mods | `K:\Projects\reference-mods\{Galdur,Cryptid,Balatro-DeckCreator}\` (read-only) |
| Vanilla source | `K:\Projects\balatro-src\` (extracted from the exe, read-only, not in git) |
| Hot restart with mods | `Alt+F5` or hold `M` in-game |
| Tools | git, gh (not logged in), Python 3.13 (used for zip extraction; no 7-Zip) |

## Workflow per change
1. Find the API in source → add a row to `docs/smods-notes.md` (signature, link, date).
2. Make the smallest change. Update `main.lua` load order only when a new module file exists.
3. Tell the owner exactly what to click and what to expect; wait for the report/screenshot.
4. Tick `docs/test-checklist.md`; commit `M<n>: <feature>`. Milestone commits only after in-game confirmation.
5. The agent cannot see the game. Never claim something renders; ask.

## Conventions
See `docs/conventions.md`: prefix `bl`, keys `j_bl_<name>`, one file per Joker, `BL` namespace,
hooks only in `src/hooks.lua`, credit comments on adapted GPL code.
