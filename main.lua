--- Build Lab — entry point.
--- Loads modules in order and nothing else. See docs/architecture.md.
---
--- SMODS executes this file via load(NFS.read(mod.path .. main_file)) with
--- SMODS.current_mod set to this mod (verified: ../reference-mods/smods/src/preflight/loader.lua:749-783).
--- SMODS.load_file(path) returns a chunk relative to the mod folder; call it to run
--- (verified: ../reference-mods/smods/src/preflight/loader.lua:873-895).

BL = BL or {}
BL.VERSION = '0.4.0'
BL.mod = SMODS.current_mod
-- mod.config is the merged config.lua + saved config (verified: smods/src/ui.lua:1656-1685, loader.lua:782)
BL.config = SMODS.current_mod.config or {}

local function run_module(path)
    local chunk, err = SMODS.load_file(path)
    if not chunk then error(err) end
    chunk()
end

-- Logging: sendInfoMessage(message, logger) -> Lovely console + %AppData%/Balatro/Mods/lovely/log
-- (verified: ../reference-mods/smods/src/preflight/logging.lua:26-29)
sendInfoMessage('Build Lab v' .. BL.VERSION .. ' loading', 'BuildLab')

-- Module load order (uncommented milestone by milestone; see §12 of the product plan):
--
run_module('src/hooks.lua')          -- ALL vanilla function wraps
run_module('src/run_config.lua')     -- RunConfig model + validation + defaults
run_module('src/run_injector.lua')   -- config -> challenge ruleset
-- M7+  run_module('src/presets.lua')        -- save/load JSON, missing-mod degradation
run_module('src/ui/main_panel.lua')
run_module('src/ui/buildlab_tab.lua')
-- M5+  run_module('src/ui/joker_picker.lua')
-- M7+  run_module('src/ui/presets_modal.lua')

-- Content pack (works standalone)
run_module('impossible/rarity.lua')
run_module('impossible/jokers/understudy.lua')
-- M8+  run_module('impossible/jokers/fun_hoe.lua')
-- M8+  run_module('impossible/jokers/bambino.lua')
-- M8+  run_module('impossible/jokers/jazzy_clown.lua')
-- M8+  run_module('impossible/jokers/forger.lua')

sendInfoMessage('Build Lab v' .. BL.VERSION .. ' loaded', 'BuildLab')
