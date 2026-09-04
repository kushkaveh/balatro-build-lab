--- Build Lab — entry point.
--- Loads modules in order and nothing else. See docs/architecture.md.
---
--- SMODS executes this file via load(NFS.read(mod.path .. main_file)) with
--- SMODS.current_mod set to this mod (verified: ../reference-mods/smods/src/preflight/loader.lua:749-783).
--- SMODS.load_file(path) returns a chunk relative to the mod folder; call it to run
--- (verified: ../reference-mods/smods/src/preflight/loader.lua:873-895).

local MOD_VERSION = "0.1.0"

-- Logging: sendInfoMessage(message, logger) -> Lovely console + %AppData%/Balatro/Mods/lovely/log
-- (verified: ../reference-mods/smods/src/preflight/logging.lua:26-29)
sendInfoMessage("Build Lab v" .. MOD_VERSION .. " loaded", "BuildLab")

-- Module load order (uncommented milestone by milestone; see §12 of the product plan):
--
-- M3+  assert(SMODS.load_file("src/hooks.lua"))()          -- ALL vanilla function wraps
-- M3+  assert(SMODS.load_file("src/run_config.lua"))()     -- RunConfig model + validation + defaults
-- M3+  assert(SMODS.load_file("src/run_injector.lua"))()   -- config -> challenge ruleset + post-start add_card
-- M7+  assert(SMODS.load_file("src/presets.lua"))()        -- save/load JSON, missing-mod degradation
-- M4+  assert(SMODS.load_file("src/ui/buildlab_tab.lua"))()
-- M4+  assert(SMODS.load_file("src/ui/main_panel.lua"))()
-- M5+  assert(SMODS.load_file("src/ui/joker_picker.lua"))()
-- M7+  assert(SMODS.load_file("src/ui/presets_modal.lua"))()
-- M2+  assert(SMODS.load_file("impossible/rarity.lua"))()
-- M2+  assert(SMODS.load_file("impossible/jokers/understudy.lua"))()
-- M8+  assert(SMODS.load_file("impossible/jokers/fun_hoe.lua"))()
-- M8+  assert(SMODS.load_file("impossible/jokers/bambino.lua"))()
-- M8+  assert(SMODS.load_file("impossible/jokers/jazzy_clown.lua"))()
-- M8+  assert(SMODS.load_file("impossible/jokers/forger.lua"))()
