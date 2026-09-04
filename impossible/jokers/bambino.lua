--- Bambino — Negative-Joker engine. Spec: product plan §9.2.
--- Contexts (verified): end_of_round via SMODS.calculate_context({end_of_round=true, game_over=...})
--- which sets context.main_eval for the jokers pass (better_calc.toml:961; smods/src/utils.lua:2179-2207);
--- joker_main + xmult (better_calc.toml:487, game_object.lua:4014).
--- Negative conversion: Card:set_edition({negative=true}, immediate) raises G.jokers.config.card_limit
--- for cards already in the deck (../balatro-src/card.lua:387-462; SMODS override overrides.lua:2072-2136).
--- Neighbour lookup idiom from Cryptid items/misc_joker.lua:9116-9189 and items/spooky.lua:19-35 (GPL-3.0).

SMODS.Joker {
    key = 'bambino',
    atlas = 'jokers',
    pos = { x = 1, y = 0 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { xmult_per = 0.5 } },

    loc_vars = function(self, info_queue, card)
        local n = 0
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j.edition and j.edition.negative then n = n + 1 end
            end
        end
        return { vars = { card.ability.extra.xmult_per, 1 + card.ability.extra.xmult_per * n } }
    end,

    calculate = function(self, card, context)
        -- One conversion per round: the Joker to the right joins the family.
        if context.end_of_round and context.main_eval and not context.blueprint and not context.retrigger_joker
            and not context.game_over then
            local idx
            for i, j in ipairs(G.jokers.cards) do
                if j == card then idx = i break end
            end
            local other = idx and G.jokers.cards[idx + 1]
            if other and not (other.edition and other.edition.negative) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        other:set_edition({ negative = true }, true)
                        other:juice_up(0.3, 0.5)
                        return true
                    end,
                }))
                return { message = localize('bl_joins_family'), colour = G.C.DARK_EDITION }
            else
                -- rightmost or already-Negative neighbour: Bambino sulks
                card:juice_up(0.3, 0.4)
            end
        end

        if context.joker_main then
            local n = 0
            for _, j in ipairs(G.jokers.cards) do
                if j.edition and j.edition.negative then n = n + 1 end
            end
            if n > 0 then
                return { xmult = 1 + card.ability.extra.xmult_per * n }
            end
        end
    end,
}
