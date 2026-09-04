--- RunConfig -> challenge-shaped table consumed by vanilla Game:start_run.
---
--- Vanilla applies (game.lua:2063-2157, only when not loading a save):
---   challenge.jokers[i] = {id, edition, eternal, pinned}  -> add_joker(id, edition, k ~= 1)
---     (common_events.lua:372-384; edition is the type name, e.g. 'negative' -> set_edition{negative=true})
---   challenge.rules.modifiers[i] = {id, value}           -> G.GAME.starting_params[id] = value
---   challenge.id (omitted here)                          -> G.GAME.challenge; nil keeps unlocks/high scores vanilla
--- Deck and stake do NOT go through the challenge: SMODS run select passes args.deck_choice = {name=}
--- and args.stake_choice = <order> (lovely/run_select.toml:22-45, src/utils/run_select.lua:321-322).
--- Reference for the fake-challenge idea: Balatro-DeckCreator DeckCreator.lua:2750-2776 (GPL-3.0).

BL.injector = {}
local INJ = BL.injector
local RC = BL.run_config

function INJ.to_challenge(cfg)
    cfg = RC.sanitize(cfg)
    local ch = {
        name = 'Build Lab',
        rules = { custom = {}, modifiers = {} },
        jokers = {},
        consumeables = {},
        vouchers = {},
        restrictions = { banned_cards = {}, banned_tags = {}, banned_other = {} },
    }
    for _, p in ipairs(RC.PARAMS) do
        if cfg.params[p] ~= nil then
            ch.rules.modifiers[#ch.rules.modifiers + 1] = { id = p, value = cfg.params[p] }
        end
    end
    for i = 1, RC.SLOTS do
        local s = cfg.jokers[i]
        if s and s.key and not s.missing then
            local j = { id = s.key }
            if s.edition and s.edition ~= 'e_base' then j.edition = string.sub(s.edition, 3) end
            if s.stickers and s.stickers.eternal then j.eternal = true end
            if s.stickers and s.stickers.pinned then j.pinned = true end
            ch.jokers[#ch.jokers + 1] = j
        end
    end
    return ch
end

--- Build the args table for G.FUNCS.start_run(nil, args) (button_callbacks.lua:2958-2979).
function INJ.run_args(cfg)
    cfg = RC.sanitize(cfg)
    local back = G.P_CENTERS[cfg.deck] or G.P_CENTERS.b_red
    local stake = G.P_STAKES[cfg.stake] or G.P_STAKES.stake_white
    return {
        build_lab = cfg,
        deck_choice = { name = back.name },
        stake_choice = stake.order,
        stake = stake.order,
        seed = cfg.seed,
    }
end

--- Start a run directly from a config (used by the M3 dev keybind; the run-select page uses
--- SMODS.RunSelect.Functions.start_run instead).
function INJ.start_run(cfg)
    if G.STAGE ~= G.STAGES.MAIN_MENU then
        sendWarnMessage('Build Lab: start_run only from the main menu', 'BuildLab')
        return
    end
    G.FUNCS.start_run(nil, INJ.run_args(cfg))
end

------------------------------------------------------------------------------------------------
-- M3 TEMPORARY: F9 at the main menu starts a hardcoded run. Removed in M4.
-- SMODS.Keybind{key_pressed, held_keys, event='pressed', action=function(self)}
-- (verified: ../reference-mods/smods/src/game_object.lua:3776-3803, lovely/keybind.toml)
------------------------------------------------------------------------------------------------
SMODS.Keybind {
    key_pressed = 'f9',
    action = function(self)
        local cfg = RC.new()
        cfg.deck = 'b_red'
        cfg.stake = 'stake_white'
        cfg.jokers[1] = { key = 'j_blueprint', edition = 'e_foil' }
        cfg.jokers[2] = { key = 'j_bl_understudy', edition = 'e_negative' }
        cfg.params.dollars = 20
        sendInfoMessage('F9: starting hardcoded Build Lab run', 'BuildLab')
        INJ.start_run(cfg)
    end,
}
