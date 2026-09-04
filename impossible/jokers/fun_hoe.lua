--- The Fun Hoe — destruction-scaling XMult. Spec: product plan §9.1.
--- Contexts (verified): destroying_card is set only for scoring cards in G.play and a truthy `remove`
--- destroys the card (smods/src/utils.lua:2334-2372); joker_main + xmult (better_calc.toml:487,
--- game_object.lua:4014); selling_self fires from Card:sell_card (better_calc.toml:1024-1039).
--- Copies (Blueprint/Brainstorm/Understudy) reach this calculate with context.blueprint set
--- (smods/src/utils.lua:2385-2411); harvesting and regrowth are guarded so they only run on the real card.
--- Recreating harvested cards: SMODS.add_card{set='Base'|'Enhanced', enhancement, rank, suit, seal,
--- edition, area} (smods/src/utils.lua:375-448, 4505-4526); playing-card fields card.base.value/suit
--- (../balatro-src/card.lua:111-134), card.seal, card.edition.type, card.config.center.key.
--- Destroy-on-score pattern adapted from Cryptid items/misc_joker.lua:385-435 (GPL-3.0).

SMODS.Joker {
    key = 'fun_hoe',
    atlas = 'jokers',
    pos = { x = 0, y = 0 },
    rarity = BL.IMPOSSIBLE,
    cost = BL.IMPOSSIBLE_COST,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { xmult = 1, xmult_gain = 0.5, harvested = 0, garden = {} } },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return { vars = { e.xmult_gain, e.xmult, e.harvested } }
    end,

    calculate = function(self, card, context)
        local e = card.ability.extra

        -- Harvest: scored face cards are destroyed after scoring (same phase as Glass breaking).
        if context.destroying_card and not context.blueprint and not context.retrigger_joker then
            local pc = context.destroying_card
            if pc:is_face() and not pc.debuff and not SMODS.is_eternal(pc) then
                e.garden[#e.garden + 1] = {
                    rank = pc.base.value,
                    suit = pc.base.suit,
                    enhancement = (pc.config.center.key ~= 'c_base') and pc.config.center.key or nil,
                    seal = pc.seal,
                    edition = pc.edition and pc.edition.type or nil,
                }
                e.harvested = e.harvested + 1
                e.xmult = e.xmult + e.xmult_gain
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize { type = 'variable', key = 'a_xmult', vars = { e.xmult } }, colour = G.C.MULT })
                return { remove = true }
            end
        end

        if context.joker_main and e.xmult > 1 then
            return { xmult = e.xmult }
        end

        -- The court grows back: harvested cards return to the deck when this Joker is sold.
        if context.selling_self and not context.blueprint and not context.retrigger_joker then
            if #e.garden > 0 and G.deck then
                for _, proto in ipairs(e.garden) do
                    local t = {
                        set = proto.enhancement and 'Enhanced' or 'Base',
                        rank = proto.rank,
                        suit = proto.suit,
                        area = G.deck,
                        skip_materialize = true,
                        silent = true,
                    }
                    if proto.enhancement then t.enhancement = proto.enhancement end
                    if proto.seal then t.seal = proto.seal end
                    if proto.edition then t.edition = 'e_' .. proto.edition end
                    local ok, err = pcall(SMODS.add_card, t)
                    if not ok then sendWarnMessage('Fun Hoe regrow failed: ' .. tostring(err), 'BuildLab') end
                end
                e.garden = {}
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('bl_regrow'), colour = G.C.GREEN })
            end
        end
    end,
}
