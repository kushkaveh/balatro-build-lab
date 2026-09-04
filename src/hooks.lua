--- ALL vanilla / SMODS function wraps live in this file. Wrap-and-call-original only.
--- Each hook: what it wraps, why, and where the original was read.

BL.hooks = BL.hooks or {}

------------------------------------------------------------------------------------------------
-- Game:start_run(args)
-- Why: translate a Build Lab RunConfig (args.build_lab) into a challenge-shaped table that vanilla
--      already knows how to apply (starting Jokers with editions, starting_params modifiers).
-- Original: ../balatro-src/game.lua:2018 (reads args.savetext/stake/seed/challenge; challenge
--           applied at 2063-2149 only when not loading a save).
-- SMODS already wraps this twice (src/utils.lua:3284, src/utils/run_select.lua:332) and adds
--           args.deck_choice / args.stake_choice (lovely/run_select.toml:22-45). We wrap outermost.
------------------------------------------------------------------------------------------------
local game_start_run_ref = Game.start_run
function Game:start_run(args)
    if args and args.build_lab and not args.savetext and BL.injector then
        local ok, challenge = pcall(BL.injector.to_challenge, args.build_lab)
        if ok and challenge then
            args.challenge = challenge
            BL.injector.last_started = args.build_lab
        else
            sendErrorMessage('Build Lab injection failed: ' .. tostring(challenge), 'BuildLab')
        end
    end
    return game_start_run_ref(self, args)
end

------------------------------------------------------------------------------------------------
-- G.FUNCS.exit_overlay_menu()
-- Why: drop our menu CardAreas/cards when the run-setup overlay closes (SMODS does the same for
--      its own areas: src/utils/run_select.lua:749-753; Galdur galdur.lua:210-219, GPL-3.0).
-- Original: ../balatro-src/functions/button_callbacks.lua:1359-1371.
------------------------------------------------------------------------------------------------
local exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function(...)
    local ret = exit_overlay_menu_ref(...)
    if BL.ui then
        if BL.ui.main_panel then BL.ui.main_panel.cleanup() end
        if BL.ui.joker_picker then BL.ui.joker_picker.cleanup() end
    end
    return ret
end

------------------------------------------------------------------------------------------------
-- Card:click()
-- Why: clicking a Build Lab slot card opens the picker; clicking a picker card selects it.
--      Same routing idea as SMODS run select (run_select.lua:908-930) keyed on card.params.
-- Original: ../balatro-src/card.lua:4610-4623.
------------------------------------------------------------------------------------------------
local card_click_ref = Card.click
function Card:click()
    if self.params then
        if self.params.bl_slot and BL.ui and BL.ui.main_panel then
            BL.ui.main_panel.on_slot_click(self.params.bl_slot)
            return
        end
        if self.params.bl_pick and BL.ui and BL.ui.joker_picker then
            BL.ui.joker_picker.on_card_click(self)
            return
        end
    end
    return card_click_ref(self)
end
