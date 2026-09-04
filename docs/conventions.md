# Conventions

## Naming
- Mod id `BuildLab`, prefix `bl`. SMODS prepends the prefix to every registered key: a Joker declared
  with `key = 'understudy'` becomes `j_bl_understudy`; the atlas `key = 'jokers'` becomes `bl_jokers`
  (referenced from Jokers as `atlas = 'jokers'`); the rarity `key = 'impossible'` becomes `bl_impossible`
  (referenced from Jokers as `rarity = 'bl_impossible'`, i.e. the prefixed form).
- One file per Joker under `impossible/jokers/`: `fun_hoe.lua`, `bambino.lua`, `jazzy_clown.lua`,
  `understudy.lua`, `forger.lua`. Atlas column = `pos.x` = 0..4 in that order.
- Localization keys mirror object keys (`j_bl_understudy`) in `localization/en-us.lua`; our dictionary
  strings are prefixed `bl_`; the run-select page label is `run_select_build_lab` (SMODS convention).
- Lua locals and functions: `snake_case`. One global namespace `BL` (`BL.config`, `BL.run_config`,
  `BL.injector`, `BL.presets`, `BL.ui.*`). Button callbacks are `G.FUNCS.bl_*`.

## Where code may live
- `src/hooks.lua` is the **only** file allowed to reassign a vanilla or SMODS function. Pattern:
  ```lua
  local ref = G.FUNCS.some_function
  G.FUNCS.some_function = function(...)
      local ret = ref(...)
      -- our work
      return ret
  end
  ```
  Each hook gets a comment block: what it wraps, why, and the `../balatro-src/` (or smods) file:line.
- `src/` never references Impossible Jokers by key (except preset data); `impossible/` never touches UI.
- UI files build `UIBox` trees from vanilla helpers only, imitating a named vanilla/SMODS screen (say
  which one in the file header). Sub-screens swap the `bl_panel` node; never open a second overlay.
- Menu `CardArea`s: create with type `'title'`, register nothing else, and scrub them (remove cards, drop
  from `G.I.CARDAREA`) on rebuild and in the `exit_overlay_menu` hook.

## Verification rule
Every `SMODS.*`, `G.*`, `Card:*`, `CardArea:*` call must have a row in `docs/smods-notes.md` before it is
used. Copied GPL snippets carry a credit comment: `-- adapted from <project> <file>:<lines> (GPL-3.0)`.
Run `python tools/luacheck.py .` before every commit.

## Commits
- One feature per commit. Message format: `M<n>: <feature>` (e.g. `M5: joker picker paging`).
- A milestone is committed only after the owner confirms it in-game against `docs/test-checklist.md`
  (the owner waived the per-milestone gate for M2–M9 on 2026-09-04; those commits await the consolidated
  in-game pass).

## Calc-context cheatsheet (Steamodded 26.829.0, verified — see smods-notes.md M8)
| Context | Fires | Fields | Return |
|---|---|---|---|
| `before` | once per played hand, before scoring | `full_hand, scoring_hand, scoring_name, poker_hands` | `{message, colour}` |
| `individual` | per scored / held card | `other_card, cardarea (G.play/G.hand/'unscored')` | `{chips, mult, xmult, message}` |
| `repetition` | per scored / held card | `other_card, cardarea, scoring_hand` | `{repetitions=n, message, card}` |
| `joker_main` | once per hand, joker pass | `cardarea=G.jokers, scoring_hand...` | `{chips, mult, xmult, message}` |
| `destroying_card` | per scored card after scoring | `destroying_card, destroy_card, full_hand` | `{remove=true}` |
| `after` | once per played hand, after destruction | `scoring_hand, full_hand...` | `{message}` |
| `end_of_round` | once per round (jokers pass has `main_eval`) | `game_over, beat_boss` | `{message, saved}` |
| `selling_self` | when this Joker is sold | — | side effects |
| copy flags | present when reached through a copier | `blueprint (depth), blueprint_card, blueprint_copiers_stack, retrigger_joker` | guard mutations |
Rule of thumb: mutate `card.ability.extra` only when `not context.blueprint and not context.retrigger_joker`.
