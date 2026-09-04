-- Format verified against ../reference-mods/smods/localization/en-us.lua and
-- ../reference-mods/smods/src/utils.lua:187-238 (load order, file wins over loc_txt).
-- Text markup as used by vanilla localization/en-us.lua (e.g. j_hanging_chad, lines 1032-1038).
return {
    descriptions = {
        Joker = {
            j_bl_understudy = {
                name = 'The Understudy',
                text = {
                    '{X:mult,C:white} X#1# {} Mult',
                    '{C:inactive}(placeholder: copies neighbours in M8)',
                },
            },
        },
    },
    misc = {
        dictionary = {
            k_bl_impossible = 'Impossible',
            -- run-select page (SMODS nav button uses 'run_select_' .. page key)
            run_select_build_lab = 'Build Lab',
            bl_starting_jokers = 'Starting Jokers',
            bl_jokers_short = 'Jokers',
            bl_empty_slot = 'Empty',
            bl_missing = 'Missing mod',
            bl_missing_hint = 'Not loaded:',
            bl_pick = 'Pick',
            bl_change = 'Change',
            bl_slot = 'Slot',
            bl_search = 'Search...',
            bl_filter_all = 'All',
            bl_filter_modded = 'Modded',
            bl_edition_base = 'Base',
            bl_advanced = 'Advanced',
            bl_auto = 'Auto',
            bl_presets = 'Presets',
            bl_param_dollars = 'Money',
            bl_param_hands = 'Hands',
            bl_param_discards = 'Discards',
            bl_param_hand_size = 'Hand Size',
            bl_param_joker_slots = 'Joker Slots',
            bl_param_consumable_slots = 'Consumable Slots',
        },
        labels = {
            k_bl_impossible = 'Impossible',
        },
    },
}
