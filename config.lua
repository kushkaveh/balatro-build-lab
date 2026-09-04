-- Build Lab default config. SMODS merges the saved config/BuildLab.jkr over this table
-- (verified: ../reference-mods/smods/src/ui.lua:1656-1685). Access via BL.config.
return {
    -- Impossible Jokers can roll in shops/packs. Off = weight 0 (Build Lab only).
    allow_in_shop = false,
    -- Weight used when allow_in_shop is on (Common is 0.7, Rare 0.05).
    shop_weight = 0.001,
    -- Hide the Build Lab run-select page (content pack still loads).
    disable_builder = false,
}
