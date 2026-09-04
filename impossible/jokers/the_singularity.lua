--- The Singularity — absorbs every Joker or consumable that is sold or destroyed.
--- Contexts (verified): selling_card {card=<sold>} goes to every Joker except the sold one, for Jokers and
--- consumables (better_calc.toml:1254-1269, vanilla card.lua:2395); joker_type_destroyed {card=<card>} when a
--- non-playing card is destroyed via start_dissolve / shatter / SMODS.pinch_and_remove
--- (better_calc.toml:1922-1950, smods/src/utils.lua:3005-3010). using_consumeable is deliberately ignored.
--- Playing cards are excluded with SMODS.is_playing_card (utils.lua:2999-3003) — that is The Fun Hoe's domain.
--- Copies get joker_main's current XMult only; absorption is guarded to the real card and de-duplicated per
--- card instance (card.sort_id, card.lua:24-25) so a sale followed by a destruction counts once.

local function round2(x)
    return math.floor(x * 100 + 0.5) / 100
end

local function absorbable(other, self_card)
    if not other or other == self_card then return false end
    if SMODS.is_playing_card(other) then return false end
    local set = other.ability and other.ability.set
    if set == 'Joker' then return true end
    if other.ability and other.ability.consumeable then return true end
    if set and SMODS.ConsumableTypes and SMODS.ConsumableTypes[set] then return true end
    return false
end

SMODS.Joker {
    key = 'the_singularity',
    atlas = 'jokers',
    pos = { x = 4, y = 1 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { xmult = 1, gain = 0.4, absorbed = 0, last_id = 0 } },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return { vars = { e.gain, e.xmult, e.absorbed } }
    end,

    calculate = function(self, card, context)
        local e = card.ability.extra

        if (context.selling_card or context.joker_type_destroyed) and context.card
            and not context.blueprint and not context.retrigger_joker then
            local other = context.card
            if absorbable(other, card) then
                local id = other.sort_id or 0
                if id ~= 0 and id == e.last_id then return end
                e.last_id = id
                e.absorbed = e.absorbed + 1
                e.xmult = round2(e.xmult + e.gain)
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { e.xmult } },
                    colour = G.C.DARK_EDITION,
                }
            end
        end

        if context.joker_main and e.xmult > 1 then
            return { xmult = e.xmult }
        end
    end,
}
