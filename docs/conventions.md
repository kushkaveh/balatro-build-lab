# Conventions

## Naming
- Mod id `BuildLab`, prefix `bl`. SMODS prepends the prefix to every registered key, so a Joker declared
  with `key = 'understudy'` becomes `j_bl_understudy`; an atlas declared with `key = 'jokers'` becomes `bl_jokers`.
- One file per Joker under `impossible/jokers/`: `fun_hoe.lua`, `bambino.lua`, `jazzy_clown.lua`,
  `understudy.lua`, `forger.lua`.
- Localization keys mirror object keys (`j_bl_understudy`) in `localization/en-us.lua`.
- Lua locals and functions: `snake_case`. Module tables: `BL.<module>` (one global namespace, `BL`).

## Where code may live
- `src/hooks.lua` is the **only** file allowed to reassign a vanilla or SMODS function. Pattern:
  ```lua
  local ref = G.FUNCS.some_function
  G.FUNCS.some_function = function(...)
      -- pre
      local ret = ref(...)
      -- post
      return ret
  end
  ```
  Each hook gets a comment block: what it wraps, why, and the `../balatro-src/` file:line it was read from.
- `buildlab/` code never references Impossible Jokers by key; `impossible/` code never references the UI.
- UI files build `UIBox` trees from vanilla helpers only, imitating a named vanilla screen (say which one in
  the file header).

## Verification rule
Every `SMODS.*`, `G.*`, `Card:*`, `CardArea:*` call must have a row in `docs/smods-notes.md` before it is
used. Copied GPL snippets carry a credit comment: `-- adapted from <project> <file>:<lines> (GPL-3.0)`.

## Commits
- One feature per commit. Message format: `M<n>: <feature>` (e.g. `M5: joker picker paging`).
- A milestone is committed only after the user confirms it in-game against `docs/test-checklist.md`.

## Calc-context cheatsheet
To be filled at M8 from `../reference-mods/smods/src/` and docs.smods.dev (Better Calc). Contexts we expect to
use: `joker_main`, `individual`, `repetition`, `after`, `end_of_round`, `destroy_card`/`destroying_card`,
plus the Blueprint/Brainstorm copy machinery. Do not use any of them before verifying and logging the exact
field names.
