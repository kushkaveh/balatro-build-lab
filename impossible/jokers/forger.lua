--- The Forger — deck transformation. Spec: product plan §9.5.
--- Context (verified): after fires once per played hand with context.scoring_hand, after the destroy
--- pass (better_calc.toml:810; vanilla order state_events.lua:950-996 then :1068). blueprint_compat=false
--- means SMODS.blueprint_effect refuses to copy it (smods/src/utils.lua:2386).
--- Card mutation: Card:set_ability(center, initial, delay_sprites) (../balatro-src/card.lua:223) and
--- Card:set_seal('Red', silent, immediate) with capitalised seal keys from G.P_SEALS (game.lua:218-223,
--- card.lua:464-499). Enhancement centres m_bonus..m_lucky (game.lua:648-655).
--- RNG: pseudorandom_element(list, pseudoseed(key)) (misc_functions.lua:253-313; SMODS lovely/pool.toml:10-27).
--- Stamping pattern adapted from Cryptid items/misc_joker.lua:1502-1531 and :9840-9861 (GPL-3.0).

SMODS.Joker {
    key = 'forger',
    atlas = 'jokers',
    pos = { x = 4, y = 0 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { enhancements = { 'm_bonus', 'm_mult', 'm_wild', 'm_glass', 'm_steel', 'm_stone', 'm_gold', 'm_lucky' } } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = 'Other', key = 'red_seal' }
        return { vars = {} }
    end,

    calculate = function(self, card, context)
        if context.after and not context.blueprint and not context.retrigger_joker and context.scoring_hand then
            local stamped = 0
            local sealable = {}
            for _, pc in ipairs(context.scoring_hand) do
                if not pc.destroyed and not pc.shattered and not pc.getting_sliced then
                    if pc.config.center.key == 'c_base' then
                        local key = pseudorandom_element(card.ability.extra.enhancements, pseudoseed('bl_forger'))
                        if key and G.P_CENTERS[key] then
                            pc:set_ability(G.P_CENTERS[key], nil, true)
                            stamped = stamped + 1
                            G.E_MANAGER:add_event(Event({
                                func = function() pc:juice_up(0.3, 0.4) return true end,
                            }))
                        end
                    end
                    if not pc.seal then sealable[#sealable + 1] = pc end
                end
            end
            local sealed = false
            if #sealable > 0 then
                local target = pseudorandom_element(sealable, pseudoseed('bl_forger_seal'))
                if target then
                    target:set_seal('Red', nil, true)
                    sealed = true
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target:juice_up(0.3, 0.4)
                            play_sound('gold_seal', 1.2, 0.4)
                            return true
                        end,
                    }))
                end
            end
            if stamped > 0 or sealed then
                return { message = localize('bl_forged'), colour = G.C.GREEN }
            end
        end
    end,
}
