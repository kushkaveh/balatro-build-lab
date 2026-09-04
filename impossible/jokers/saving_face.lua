--- Saving Face — "every face erased, an ace takes its place."
--- Context (verified): remove_playing_cards fires after any playing-card destruction with
--- context.removed = {destroyed cards}: scoring destruction (better_calc.toml:730-733, incl. Glass and
--- Fun Hoe harvests), discard destruction (:761-764) and SMODS.destroy_cards (smods/src/utils.lua:3064).
--- Face test: Card:is_face(true) ignores debuff and honours Pareidolia (../balatro-src/card.lua:964-970).
--- Creation: SMODS.add_card{set='Enhanced', enhancement, rank='Ace', area=G.deck} — suit is randomised
--- by SMODS when omitted (smods/src/utils.lua:395-409), card lands in the deck (utils.lua:4505-4526).
--- Blueprint-compatible: copies also fire (like vanilla DNA under Blueprint); creations are queued through
--- G.E_MANAGER so a Fun Hoe + Pareidolia chain never loops inside one frame.

local ENHANCEMENTS = { 'm_bonus', 'm_mult', 'm_wild', 'm_glass', 'm_steel', 'm_stone', 'm_gold', 'm_lucky' }

SMODS.Joker {
    key = 'saving_face',
    atlas = 'jokers',
    pos = { x = 0, y = 1 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { aces = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.aces } }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and context.removed and G.deck then
            local faces = 0
            for _, pc in ipairs(context.removed) do
                if pc.is_face and pc:is_face(true) then faces = faces + 1 end
            end
            if faces == 0 then return end
            local total = faces * card.ability.extra.aces
            for n = 1, total do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.08,
                    func = function()
                        if not G.deck then return true end
                        local enhancement = pseudorandom_element(ENHANCEMENTS, pseudoseed('bl_saving_face'))
                        local ok, err = pcall(SMODS.add_card, {
                            set = 'Enhanced',
                            enhancement = enhancement,
                            rank = 'Ace',
                            area = G.deck,
                            skip_materialize = true,
                            silent = true,
                        })
                        if not ok then sendWarnMessage('Saving Face could not create an Ace: ' .. tostring(err), 'BuildLab') end
                        if n == total then
                            play_sound('card1', 1.1, 0.5)
                            card:juice_up(0.3, 0.4)
                        end
                        return true
                    end,
                }))
            end
            return { message = localize('bl_ace_place'), colour = G.C.FILTER }
        end
    end,
}
