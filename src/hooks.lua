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
