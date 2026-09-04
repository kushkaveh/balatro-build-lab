--- The Dude — abides. Unused hands and discards become permanent XMult at end of round.
--- Context (verified): end_of_round via SMODS.calculate_context({end_of_round=true, game_over=...}) which sets
--- context.main_eval for the jokers pass (better_calc.toml:957-964; utils.lua:2179-2207).
--- Counters: G.GAME.current_round.hands_left / discards_left (read by vanilla Dusk, Acrobat, Delayed
--- Gratification: ../balatro-src/card.lua:1675, 3360, 3688); still unreset when end_round runs.
--- Copies get joker_main's current XMult only; the gain is guarded to the real card.

local function round2(x)
    return math.floor(x * 100 + 0.5) / 100
end

SMODS.Joker {
    key = 'the_dude',
    atlas = 'jokers',
    pos = { x = 3, y = 1 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { xmult = 1, gain = 0.3 } },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return { vars = { e.gain, e.xmult } }
    end,

    calculate = function(self, card, context)
        local e = card.ability.extra

        if context.end_of_round and context.main_eval and not context.blueprint and not context.retrigger_joker
            and not context.game_over then
            local round = G.GAME and G.GAME.current_round or {}
            local unused = (round.hands_left or 0) + (round.discards_left or 0)
            if unused > 0 then
                e.xmult = round2(e.xmult + e.gain * unused)
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { e.xmult } },
                    colour = G.C.MULT,
                }
            end
        end

        if context.joker_main and e.xmult > 1 then
            return { xmult = e.xmult }
        end
    end,
}
