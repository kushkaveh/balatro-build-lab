--- The Understudy — copies the Jokers directly left and right. Spec: product plan §9.4.
--- Delegation via SMODS.blueprint_effect(copier, copied_card, context) (smods/src/utils.lua:2385-2411):
--- it honours blueprint_compat, debuff and context.no_blueprint, caps recursion at #G.jokers.cards, and
--- exposes the copier chain in context.blueprint_copiers_stack. Vanilla Blueprint/Brainstorm are rewritten
--- onto the same helper (lovely/better_calc.toml:2128-2179). Two effects are merged with the `extra`
--- chain handled by SMODS.calculate_effect (smods/src/utils.lua:1425-1427).
--- Cycle guard: never copy another Understudy (both mirror outward only) and never copy a Joker that is
--- already in the current copier chain.
--- Pattern from Cryptid items/misc_joker.lua:7580-7586 (Old Blueprint → SMODS.blueprint_effect, GPL-3.0).

local function in_chain(context, joker)
    for _, c in ipairs(context.blueprint_copiers_stack or {}) do
        if c == joker then return true end
    end
    return false
end

local function append_extra(head, tail)
    local t = head
    while t.extra do t = t.extra end
    t.extra = tail
    return head
end

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
    config = {},

    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,

    calculate = function(self, card, context)
        if not G.jokers or not G.jokers.cards then return end
        local idx
        for i, j in ipairs(G.jokers.cards) do
            if j == card then idx = i break end
        end
        if not idx then return end

        local function copyable(other)
            if not other then return false end
            if other.config.center.key == card.config.center.key then return false end
            if in_chain(context, other) then return false end
            return true
        end

        local left, right = G.jokers.cards[idx - 1], G.jokers.cards[idx + 1]
        local a = copyable(left) and SMODS.blueprint_effect(card, left, context) or nil
        local b = copyable(right) and SMODS.blueprint_effect(card, right, context) or nil

        if a and b then
            a.colour = a.colour or G.C.BLUE
            return append_extra(a, b)
        end
        local ret = a or b
        if ret then ret.colour = ret.colour or G.C.BLUE end
        return ret
    end,
}
