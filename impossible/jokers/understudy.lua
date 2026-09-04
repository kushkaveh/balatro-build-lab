--- The Understudy (M2 placeholder: flat X2 Mult). Real copy/positioning logic lands in M8.
--- SMODS.Joker fields verified: ../reference-mods/smods/src/game_object.lua:1413-1449 (class defaults),
--- lovely/center.toml:22-37 (config.extra -> card.ability.extra), :56-81 (calculate hook),
--- game_object.lua:1352-1408 (loc_vars return {vars=...}).
--- joker_main context + xmult return key: lovely/better_calc.toml:487-488, game_object.lua:4014.

SMODS.Joker {
    key = 'understudy',
    atlas = 'jokers',
    pos = { x = 3, y = 0 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { xmult = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end,
}
