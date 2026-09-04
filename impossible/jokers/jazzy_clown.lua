--- Jazzy Clown — retrigger engine. Spec: product plan §9.3.
--- Contexts (verified): repetition with context.other_card / context.cardarea == G.play and the return
--- {repetitions = n} (smods/src/utils.lua:2244-2251, 1612-1639); leftmost scored card idiom
--- `context.other_card == context.scoring_hand[1]` from vanilla Hanging Chad (../balatro-src/card.lua:3352-3358);
--- before / after fire once per played hand (better_calc.toml:633, :810).
--- Probability: SMODS.pseudorandom_probability(trigger_obj, seed, numerator, denominator, identifier)
--- and SMODS.get_probability_vars(trigger_obj, num, den, identifier) for the displayed odds
--- (smods/src/utils.lua:3215-3231) — Oops! All 6s is applied inside.
--- Repetition return shape adapted from Cryptid items/exotic.lua:101-128 (GPL-3.0).

SMODS.Joker {
    key = 'jazzy_clown',
    atlas = 'jokers',
    pos = { x = 2, y = 0 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { retriggers = 3, hands_played = 0, trick_every = 3, zoomies_num = 1, zoomies_den = 4, zoomies = false } },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        local num, den = SMODS.get_probability_vars(card, e.zoomies_num, e.zoomies_den, 'bl_zoomies')
        return { vars = { e.retriggers, e.trick_every, num, den } }
    end,

    calculate = function(self, card, context)
        local e = card.ability.extra

        -- Roll Zoomies once per hand, on the real card only.
        if context.before and not context.blueprint and not context.retrigger_joker then
            e.zoomies = SMODS.pseudorandom_probability(card, 'bl_zoomies', e.zoomies_num, e.zoomies_den, 'bl_zoomies')
            if e.zoomies then
                return { message = localize('bl_zoomies'), colour = G.C.GREEN }
            end
        end

        -- Fetch (leftmost scored card) + Zoomies (every scored card)
        if context.repetition and context.cardarea == G.play and context.other_card then
            local reps = 0
            if context.scoring_hand and context.other_card == context.scoring_hand[1] then
                reps = reps + e.retriggers
            end
            if e.zoomies then reps = reps + 1 end
            if reps > 0 then
                return { message = localize('k_again_ex'), repetitions = reps, card = card }
            end
        end

        -- Training montage: every 3rd hand played learns a new trick.
        if context.after and not context.blueprint and not context.retrigger_joker then
            e.hands_played = e.hands_played + 1
            e.zoomies = false
            if e.hands_played % e.trick_every == 0 then
                e.retriggers = e.retriggers + 1
                return { message = localize('bl_new_trick'), colour = G.C.FILTER }
            end
        end
    end,
}
