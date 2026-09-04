--- Build Lab page in the SMODS run-select flow (deck page -> stake page -> Build Lab -> Play).
---
--- SMODS.RunSelectPage fields used here are read by ../reference-mods/smods/src/utils/run_select.lua:
---   definition(page_def)   create_page():103        include_deck_preview / include_stake_tower :74-83
---   set_default(self, last) :45, :70                optional(self) get_page_key():350, Game:start_run hook :339
---   can_continue(self)     run_select_can_change_page():245     quick_start_text() nav_bar():129
--- The page's choice lives in SMODS.RunSelect.Setup.choices[key]; on Play every choice is copied
--- into the args of G.FUNCS.start_run (run_select.lua:303-330), where src/hooks.lua reads args.build_lab.
--- Nav-button label: localize('run_select_' .. key) (run_select.lua:203-204).
--- Class definition: ../reference-mods/smods/src/game_objects/runselectpage.lua:1-99.

BL.ui = BL.ui or {}

SMODS.RunSelectPage {
    key = 'build_lab',
    page = 3,
    include_deck_preview = true,
    include_stake_tower = true,

    optional = function(self)
        return not (BL.config and BL.config.disable_builder)
    end,

    set_default = function(self, choice)
        return BL.run_config.sanitize(choice)
    end,

    selected_text = function(self, selection)
        local n = selection and BL.run_config.filled_slots(selection) or 0
        return tostring(n) .. ' ' .. localize('bl_jokers_short')
    end,

    quick_start_text = function()
        local last = G.PROFILES[G.SETTINGS.profile].last_choices
            and G.PROFILES[G.SETTINGS.profile].last_choices.build_lab
        if type(last) ~= 'table' then return nil end
        local n = BL.run_config.filled_slots(last)
        if n == 0 then return nil end
        return localize('run_select_build_lab') .. ': ' .. tostring(n) .. ' ' .. localize('bl_jokers_short')
    end,

    can_continue = function(self)
        return not (BL.ui.main_panel and BL.ui.main_panel.modal_open)
    end,

    definition = function(page_def)
        return BL.ui.main_panel.page_node()
    end,
}

------------------------------------------------------------------------------------------------
-- Mods menu > Build Lab > Config tab.
-- SMODS renders mod.config_tab() as a tab (smods/src/ui.lua:555-565) and persists mod.config when
-- the Mods menu closes (SMODS.save_all_config, ui.lua:1697-1720). Toggle pattern from Cryptid
-- Cryptid.lua:413-419 (GPL-3.0). shop_weight is fixed in config.lua (0.001) and applied by the
-- rarity's get_weight when allow_in_shop is on.
------------------------------------------------------------------------------------------------
BL.mod.config_tab = function()
    return { n = G.UIT.ROOT, config = { align = 'cm', padding = 0.05, colour = G.C.CLEAR }, nodes = {
        { n = G.UIT.C, config = { align = 'cm', padding = 0.1 }, nodes = {
            { n = G.UIT.R, config = { align = 'cm', padding = 0.05 }, nodes = {
                create_toggle { label = localize('bl_cfg_allow_in_shop'), ref_table = BL.config, ref_value = 'allow_in_shop',
                    w = 4.5, scale = 0.8, label_scale = 0.35, info = { localize('bl_cfg_allow_in_shop_info') } },
            } },
            { n = G.UIT.R, config = { align = 'cm', padding = 0.05 }, nodes = {
                create_toggle { label = localize('bl_cfg_disable_builder'), ref_table = BL.config, ref_value = 'disable_builder',
                    w = 4.5, scale = 0.8, label_scale = 0.35, info = { localize('bl_cfg_disable_builder_info') } },
            } },
            { n = G.UIT.R, config = { align = 'cm', padding = 0.1 }, nodes = {
                { n = G.UIT.T, config = { text = 'Build Lab v' .. BL.VERSION, scale = 0.3, colour = G.C.UI.TEXT_INACTIVE } },
            } },
        } },
    } }
end
