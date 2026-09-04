# Lovely patches

**Current count: 0.** Build Lab uses no Lovely `.toml` patches. Everything goes through SMODS objects and
wrap-and-call-original hooks in `src/hooks.lua`.

If a patch ever becomes unavoidable, add it under `lovely/` and document it here with this template so the
next Balatro/SMODS update is diffable:

## `<patch file name>.toml`

- **Target file:** `<vanilla file, e.g. functions/UI_definitions.lua>`
- **Vanilla snippet (verbatim, from `../balatro-src/`):**
  ```lua
  ```
- **Patch type:** pattern / regex / copy
- **Why a hook was not possible:**
- **Date added / Balatro version / SMODS version:**
