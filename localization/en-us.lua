-- Format verified against ../reference-mods/smods/localization/en-us.lua and
-- ../reference-mods/smods/src/utils.lua:187-238 (load order, file wins over loc_txt).
-- Text markup as used by vanilla localization/en-us.lua (e.g. j_hanging_chad, lines 1032-1038).
return {
    descriptions = {
        Joker = {
            j_bl_fun_hoe = {
                name = 'The Fun Hoe',
                text = {
                    'Scored {C:attention}face cards{} are',
                    '{C:red}harvested{} after scoring',
                    'This Joker gains {X:mult,C:white} X#1# {} Mult',
                    'for each harvested card',
                    '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult, #3# harvested)',
                    '{C:inactive}Harvested cards return if sold',
                },
            },
            j_bl_bambino = {
                name = 'Bambino',
                text = {
                    'At end of round, the Joker to the right',
                    '{C:dark_edition}joins the family{} (becomes {C:dark_edition}Negative{})',
                    '{X:mult,C:white} X1 {} Mult plus {X:mult,C:white} X#1# {} Mult',
                    'for each {C:dark_edition}Negative{} Joker',
                    '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
                },
            },
            j_bl_jazzy_clown = {
                name = 'Jazzy Clown',
                text = {
                    '{C:attention}Fetch:{} retrigger the leftmost',
                    'scored card {C:attention}#1#{} times',
                    'Every {C:attention}#2#{} hands played,',
                    'Jazzy learns a new trick: {C:attention}+1{} retrigger',
                    '{C:green}#3# in #4#{} chance each hand for {C:attention}Zoomies{}:',
                    'retrigger {C:attention}all{} scored cards once',
                },
            },
            j_bl_understudy = {
                name = 'The Understudy',
                text = {
                    'Copies the abilities of the Jokers',
                    '{C:attention}directly left and right{} of this card',
                },
            },
            j_bl_forger = {
                name = 'The Forger',
                text = {
                    'When a hand is played, each scored card',
                    'with no enhancement gains a',
                    '{C:attention}random enhancement{}, and one',
                    'random scored card gains a {C:red}Red Seal{}',
                },
            },
        },
    },
    misc = {
        dictionary = {
            k_bl_impossible = 'Impossible',
            -- run-select page (SMODS nav button uses 'run_select_' .. page key)
            run_select_build_lab = 'Build Lab',
            run_select_bl_build_lab = 'Build Lab',
            bl_starting_jokers = 'Build Lab',
            bl_jokers_short = 'Jokers',
            bl_empty_slot = 'Empty slot',
            bl_missing = 'Missing mod',
            bl_missing_hint = 'From mods you don\'t have:',
            bl_pick = 'Pick',
            bl_change = 'Swap',
            bl_slot = 'Slot',
            bl_search = 'Search Jokers',
            bl_filter_all = 'All rarities',
            bl_filter_modded = 'Modded',
            bl_edition_base = 'Base',
            bl_advanced = 'Advanced',
            bl_auto = 'Auto',
            bl_presets = 'Presets',
            bl_clear_all = 'Clear all',
            bl_slots_used = 'Joker slots',
            bl_slots = 'Slots',
            bl_of = 'of',
            bl_more_slots = 'A free slot is waiting on the next page.',
            bl_overflow = 'Too many Jokers for your slots: remove one, make one Negative, or raise Joker Slots in Advanced.',
            bl_negative_tip = 'Negative Jokers take no slot, so each one opens an extra slot.',
            bl_advanced_title = 'Run Settings',
            bl_reset_auto = 'Reset all',
            bl_advanced_hint = 'Auto keeps your deck and stake effects. Pick a value to override it.',
            bl_hint = 'Pick Jokers for your slots and set their editions. Hover any card for details.',
            bl_param_dollars = 'Money',
            bl_param_hands = 'Hands',
            bl_param_discards = 'Discards',
            bl_param_hand_size = 'Hand Size',
            bl_param_joker_slots = 'Joker Slots',
            bl_param_consumable_slots = 'Consumable Slots',
            bl_load = 'Load',
            bl_overwrite = 'Overwrite',
            bl_delete = 'Delete',
            bl_save_current = 'Save as',
            bl_preset_name = 'Name this build',
            bl_preset_need_name = 'Give the build a name first.',
            bl_preset_corrupt = 'presets.json could not be read, so it was reset. A backup was kept as presets.json.corrupt.',
            bl_no_presets = 'No saved builds yet. Set up your slots, name the build below and save it.',
            -- Joker messages
            bl_regrow = 'Regrown!',
            bl_joins_family = 'Joins the family!',
            bl_zoomies = 'Zoomies!',
            bl_new_trick = 'New trick!',
            bl_forged = 'Forged!',
            -- config tab
            bl_cfg_allow_in_shop = 'Impossible Jokers in shops',
            bl_cfg_allow_in_shop_info = 'Rare (about 0.1%). Off means Build Lab only.',
            bl_cfg_disable_builder = 'Hide the Build Lab page',
            bl_cfg_disable_builder_info = 'Impossible Jokers still load. Applies the next time you open New Run.',
        },
        labels = {
            k_bl_impossible = 'Impossible',
        },
    },
}
