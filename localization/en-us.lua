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
            bl_clear_all = 'Clear all',
            bl_slots_used = 'slots',
            bl_overflow = 'Over the slot limit: remove a Joker, make one Negative, or raise Joker Slots',
            bl_negative_tip = 'Negative Jokers free up a slot: an extra slot opens for each one',
            bl_advanced_title = 'Starting parameters',
            bl_reset_auto = 'Reset to Auto',
            bl_advanced_hint = 'Auto keeps the deck and stake effects. Set a value to override it.',
            bl_hint = 'Pick a Joker for each slot, then cycle its edition. Hover a card for details.',
            bl_param_dollars = 'Money',
            bl_param_hands = 'Hands',
            bl_param_discards = 'Discards',
            bl_param_hand_size = 'Hand Size',
            bl_param_joker_slots = 'Joker Slots',
            bl_param_consumable_slots = 'Consumable Slots',
            bl_load = 'Load',
            bl_overwrite = 'Overwrite',
            bl_delete = 'Delete',
            bl_save_current = 'Save current as',
            bl_preset_name = 'Preset name',
            bl_preset_need_name = 'Type a name first',
            bl_preset_corrupt = 'presets.json was unreadable and has been reset (backup: presets.json.corrupt)',
            bl_no_presets = 'No presets yet',
            -- Joker messages
            bl_regrow = 'Regrown!',
            bl_joins_family = 'Joins the family!',
            bl_zoomies = 'Zoomies!',
            bl_new_trick = 'New trick!',
            bl_forged = 'Forged!',
            -- config tab
            bl_cfg_allow_in_shop = 'Impossible Jokers in shops',
            bl_cfg_allow_in_shop_info = 'Tiny weight (0.1%). Off = Build Lab only.',
            bl_cfg_disable_builder = 'Hide the Build Lab page',
            bl_cfg_disable_builder_info = 'The Impossible Jokers still load. Takes effect on next run setup.',
        },
        labels = {
            k_bl_impossible = 'Impossible',
        },
    },
}
