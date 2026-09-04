--- Impossible rarity + the content pack's shared atlas.
--- Pattern adapted from Cryptid lib/content.lua:354-374 (SMODS.Rarity 'exotic'/'epic', GPL-3.0).

-- SMODS.Atlas{key, path, px, py}: file at assets/<1x|2x>/<path>; key becomes 'bl_jokers' and
-- Jokers reference it as atlas = 'jokers' (auto-prefixed).
-- (verified: ../reference-mods/smods/src/game_object.lua:469-563, :74-80)
SMODS.Atlas {
    key = 'jokers',
    path = 'Jokers_bl.png',
    px = 71,
    py = 95,
}

-- SMODS.Rarity{key, badge_colour, default_weight, pools, get_weight}
-- Final key is 'bl_impossible'; Jokers must use rarity = 'bl_impossible'.
-- Name comes from localization misc.dictionary/labels 'k_bl_impossible'.
-- default_weight 0 => never rolled by SMODS.poll_rarity (utils.lua:876-918).
-- (verified: ../reference-mods/smods/src/game_object.lua:1026-1075)
SMODS.Rarity {
    key = 'impossible',
    badge_colour = HEX('AA0F3C'),
    default_weight = 0,
    pools = { Joker = true },
    get_weight = function(self, weight, object_type)
        if BL.config and BL.config.allow_in_shop then
            return BL.config.shop_weight or 0
        end
        return 0
    end,
}

BL.IMPOSSIBLE = 'bl_impossible'
BL.IMPOSSIBLE_COST = 50
