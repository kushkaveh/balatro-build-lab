--- Velvet Rope — every Blind lets one more Rare in, Negative.
--- Context (verified): setting_blind fires once per blind selection via SMODS.calculate_context
--- ({setting_blind=true, blind=...}, better_calc.toml:990-1005).
--- Creation: SMODS.add_card{set='Joker', rarity=3, edition='e_negative', key_append} — rarity 3 is the
--- vanilla Rare pool index used by get_current_pool (smods/lovely/pool.toml:77-85, game_object.lua:1058-1075);
--- the Negative edition raises G.jokers.config.card_limit inside Card:add_to_deck (card.lua:630-640).
--- Blueprint-compatible: a copy lets another one in (like vanilla Riff-Raff under Blueprint).
--- Hard cap: skip when the Joker area already holds `cap` cards.

SMODS.Joker {
    key = 'velvet_rope',
    atlas = 'jokers',
    pos = { x = 1, y = 1 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { cap = 30 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cap } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.retrigger_joker then
            local cap = card.ability.extra.cap
            if not G.jokers or #G.jokers.cards >= cap then return end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    if not G.jokers or #G.jokers.cards >= cap then return true end
                    local ok, new_card = pcall(SMODS.add_card, {
                        set = 'Joker',
                        rarity = 3,
                        edition = 'e_negative',
                        key_append = 'bl_velvet',
                    })
                    if ok and new_card then
                        new_card:juice_up(0.3, 0.5)
                    elseif not ok then
                        sendWarnMessage('Velvet Rope could not create a Joker: ' .. tostring(new_card), 'BuildLab')
                    end
                    return true
                end,
            }))
            return { message = localize('bl_velvet'), colour = G.C.DARK_EDITION }
        end
    end,
}
