--- The Smelter — melts enhancements off scored cards for permanent +Mult.
--- Context (verified): individual fires per scored card during scoring with context.other_card and
--- context.cardarea == G.play (smods/src/utils.lua:2230-2240), i.e. BEFORE `after` where The Forger stamps
--- (better_calc.toml:810). The card's own enhancement has already scored in that step (utils.lua:2231).
--- Mutation: Card:set_ability(G.P_CENTERS.c_base, nil, true) (../balatro-src/card.lua:223; c_base is the
--- plain-card centre used by card_from_control, misc_functions.lua:1627).
--- Copies (Blueprint/Brainstorm/Understudy) get joker_main's current Mult only; melting is guarded.

SMODS.Joker {
    key = 'the_smelter',
    atlas = 'jokers',
    pos = { x = 2, y = 1 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { mult = 0, mult_gain = 15, melted = 0 } },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return { vars = { e.mult_gain, e.mult, e.melted } }
    end,

    calculate = function(self, card, context)
        local e = card.ability.extra

        if context.individual and context.cardarea == G.play and context.other_card
            and not context.blueprint and not context.retrigger_joker then
            local pc = context.other_card
            if pc.config and pc.config.center and pc.config.center.set == 'Enhanced' and not pc.debuff then
                pc:set_ability(G.P_CENTERS.c_base, nil, true)
                e.mult = e.mult + e.mult_gain
                e.melted = e.melted + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        pc:juice_up(0.3, 0.4)
                        play_sound('tarot2', 1.2, 0.4)
                        return true
                    end,
                }))
                return { message = localize('bl_melted'), colour = G.C.MULT, card = card }
            end
        end

        if context.joker_main and e.mult > 0 then
            return { mult = e.mult }
        end
    end,
}
