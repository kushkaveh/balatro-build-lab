--- Presets panel: list rows (name, deck, mini Joker cards, Load / Overwrite / Delete) and a save row
--- with a vanilla text input. Swapped into the Build Lab page like the picker.
--- Rows imitate vanilla list layouts (create_UIBox_generic_options rows in UI_definitions.lua) and the
--- mini-card preview uses CardAreas with a reduced card_w like DeckCreator GUI.lua:3342 (GPL-3.0).
--- Loading a preset also drives the SMODS deck/stake pages: it writes Setup.choices.deck_choice /
--- stake_choice and refreshes the previews via SMODS.RunSelect.Functions.populate_preview_ui /
--- populate_stake_tower (src/utils/run_select.lua:594, 688).

BL.ui = BL.ui or {}
local PM = {}
BL.ui.presets_modal = PM
local RC = BL.run_config
local MP = BL.ui.main_panel
local P = BL.presets

PM.PER_PAGE = 4
PM.MINI = 0.42
PM.areas = {}
PM.state = { name = '', page = 1, pages = 1, page_text = '', notice = '' }

function PM.cleanup()
    for _, area in ipairs(PM.areas) do
        if area.cards then
            remove_all(area.cards)
            area.cards = {}
        end
        for j = #G.I.CARDAREA, 1, -1 do
            if G.I.CARDAREA[j] == area then table.remove(G.I.CARDAREA, j) end
        end
    end
    PM.areas = {}
end

function PM.open()
    PM.state.page = 1
    PM.state.notice = (P.status == 'corrupt') and localize('bl_preset_corrupt') or ''
    P.status = nil
    MP.modal_open = true
    play_sound('button', nil, 0.4)
    MP.swap(PM.root)
end

function PM.close()
    PM.cleanup()
    MP.show_main()
end

--- Apply a preset config to the run-select session (slots, params, deck page, stake page).
function PM.apply(cfg)
    cfg = RC.sanitize(cfg)
    local choices = SMODS.RunSelect.Setup.choices
    choices.build_lab = cfg
    if G.P_CENTERS[cfg.deck] then
        choices.deck_choice = cfg.deck
        if SMODS.RunSelect.Internals.preview_area then
            SMODS.RunSelect.Functions.populate_preview_ui('deck_choice', cfg.deck, true)
        end
    end
    if G.P_STAKES[cfg.stake] then
        choices.stake_choice = cfg.stake
        if SMODS.RunSelect.Internals.stake_tower then
            SMODS.RunSelect.Functions.populate_stake_tower(cfg.stake, true)
        end
    end
end

--- Current panel config plus the deck/stake chosen on the SMODS pages.
function PM.current_config()
    local cfg = RC.copy(MP.config())
    local choices = SMODS.RunSelect.Setup.choices
    if type(choices.deck_choice) == 'string' and G.P_CENTERS[choices.deck_choice] then cfg.deck = choices.deck_choice end
    if type(choices.stake_choice) == 'string' and G.P_STAKES[choices.stake_choice] then cfg.stake = choices.stake_choice end
    return cfg
end

------------------------------------------------------------------------------------------------
-- Nodes
------------------------------------------------------------------------------------------------

local function mini_area(entry)
    local w, h = G.CARD_W * PM.MINI, G.CARD_H * PM.MINI
    local area = CardArea(G.ROOM.T.w, G.ROOM.T.h, RC.SLOTS * w, h,
        { card_limit = RC.SLOTS, type = 'title', highlight_limit = 0, card_w = w })
    PM.areas[#PM.areas + 1] = area
    for i = 1, RC.SLOTS do
        local s = entry.config.jokers[i]
        local center = s and s.key and G.P_CENTERS[s.key]
        if center and center.set == 'Joker' then
            local card = Card(area.T.x, area.T.y, w, h, G.P_CARDS.empty, center, { bypass_discovery_center = true, bypass_discovery_ui = true })
            if s.edition then card:set_edition(s.edition, true, true) end
            area:emplace(card)
        end
    end
    return { n = G.UIT.O, config = { object = area } }
end

local function safe_name(set, key, fallback)
    local ok, name = pcall(localize, { type = 'name_text', set = set, key = key })
    if ok and type(name) == 'string' then return name end
    return fallback
end

local function preset_row(entry)
    local cfg = entry.config
    local deck = G.P_CENTERS[cfg.deck] and safe_name('Back', cfg.deck, cfg.deck) or cfg.deck
    local stake = G.P_STAKES[cfg.stake] and safe_name('Stake', cfg.stake, cfg.stake) or cfg.stake
    local missing = RC.missing_slots(cfg)
    local summary = deck .. ' / ' .. stake .. ' / ' .. RC.filled_slots(cfg) .. ' ' .. localize('bl_jokers_short')
    return { n = G.UIT.R, config = { align = 'cm', padding = 0.06, r = 0.1, colour = G.C.L_BLACK, minw = 8.7 }, nodes = {
        { n = G.UIT.C, config = { align = 'cl', minw = 2.6, maxw = 2.6, padding = 0.03 }, nodes = {
            { n = G.UIT.R, config = { align = 'cl' }, nodes = {
                { n = G.UIT.T, config = { text = entry.name, scale = 0.38, colour = entry.builtin and G.C.ORANGE or G.C.WHITE, shadow = true } },
            } },
            { n = G.UIT.R, config = { align = 'cl' }, nodes = {
                { n = G.UIT.T, config = { text = summary, scale = 0.25, colour = G.C.UI.TEXT_INACTIVE } },
            } },
            (#missing > 0) and { n = G.UIT.R, config = { align = 'cl' }, nodes = {
                { n = G.UIT.T, config = { text = localize('bl_missing_hint') .. ' ' .. #missing, scale = 0.25, colour = G.C.RED } },
            } } or nil,
        } },
        { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = { mini_area(entry) } },
        { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = {
            UIBox_button { ref_table = { name = entry.name, builtin = entry.builtin }, button = 'bl_preset_load', label = { localize('bl_load') }, minw = 1.1, minh = 0.4, scale = 0.3, colour = G.C.BLUE, col = true },
            (not entry.builtin) and UIBox_button { ref_table = { name = entry.name }, button = 'bl_preset_overwrite', label = { localize('bl_overwrite') }, minw = 1.1, minh = 0.4, scale = 0.3, colour = G.C.ORANGE, col = true } or nil,
            (not entry.builtin) and UIBox_button { ref_table = { name = entry.name }, button = 'bl_preset_delete', label = { localize('bl_delete') }, minw = 1.1, minh = 0.4, scale = 0.3, colour = G.C.RED, col = true } or nil,
        } },
    } }
end

function PM.root()
    PM.cleanup()
    local all = P.all()
    local st = PM.state
    st.pages = math.max(1, math.ceil(#all / PM.PER_PAGE))
    if st.page > st.pages then st.page = 1 end
    st.page_text = localize('k_page') .. ' ' .. st.page .. '/' .. st.pages

    local rows = {}
    local first = (st.page - 1) * PM.PER_PAGE
    for i = first + 1, math.min(#all, first + PM.PER_PAGE) do rows[#rows + 1] = preset_row(all[i]) end
    if #rows == 0 then
        rows[1] = { n = G.UIT.R, config = { align = 'cm', minh = 1 }, nodes = {
            { n = G.UIT.T, config = { text = localize('bl_no_presets'), scale = 0.35, colour = G.C.UI.TEXT_INACTIVE } } } }
    end

    return { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR }, nodes = {
        { n = G.UIT.C, config = { align = 'cm', padding = 0.05 }, nodes = {
            { n = G.UIT.R, config = { align = 'cm', padding = 0.05 }, nodes = {
                { n = G.UIT.T, config = { text = localize('bl_presets'), scale = 0.45, colour = G.C.WHITE, shadow = true } },
            } },
            (st.notice ~= '') and { n = G.UIT.R, config = { align = 'cm' }, nodes = {
                { n = G.UIT.T, config = { text = st.notice, scale = 0.3, colour = G.C.RED } } } } or nil,
            { n = G.UIT.R, config = { align = 'cm', minw = 8.7, colour = G.C.BLACK, padding = 0.12, r = 0.1, emboss = 0.05 }, nodes = {
                { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = rows },
            } },
            -- save row
            { n = G.UIT.R, config = { align = 'cm', padding = 0.06 }, nodes = {
                create_text_input { w = 3, max_length = P.MAX_NAME, prompt_text = localize('bl_preset_name'), ref_table = PM.state, ref_value = 'name', colour = G.C.BLUE },
                { n = G.UIT.C, config = { align = 'cm', minw = 0.2 } },
                UIBox_button { id = 'bl_preset_save', button = 'bl_preset_save', label = { localize('bl_save_current') }, minw = 2.2, minh = 0.5, scale = 0.35, colour = G.C.GREEN, col = true },
            } },
            -- pager + back
            { n = G.UIT.R, config = { align = 'cm', padding = 0.06 }, nodes = {
                UIBox_button { id = 'bl_presets_back', button = 'bl_presets_back', label = { localize('b_back') }, minw = 1.6, minh = 0.5, scale = 0.35, colour = G.C.ORANGE, col = true },
                { n = G.UIT.C, config = { align = 'cm', minw = 0.4 } },
                UIBox_button { button = 'bl_presets_prev', label = { '<' }, minw = 0.6, minh = 0.5, scale = 0.4, colour = G.C.RED, col = true },
                { n = G.UIT.C, config = { align = 'cm', minw = 2.0 }, nodes = {
                    { n = G.UIT.T, config = { ref_table = PM.state, ref_value = 'page_text', scale = 0.4, colour = G.C.WHITE, shadow = true } },
                } },
                UIBox_button { button = 'bl_presets_next', label = { '>' }, minw = 0.6, minh = 0.5, scale = 0.4, colour = G.C.RED, col = true },
            } },
        } },
    } }
end

------------------------------------------------------------------------------------------------
-- Callbacks
------------------------------------------------------------------------------------------------

local function refresh()
    MP.swap(PM.root)
end

G.FUNCS.bl_preset_load = function(e)
    local name = e.config.ref_table.name
    local entry
    for _, p in ipairs(P.all()) do if p.name == name then entry = p end end
    if not entry then return end
    PM.apply(entry.config)
    play_sound('tarot1', nil, 0.5)
    PM.close()
end

G.FUNCS.bl_preset_overwrite = function(e)
    P.save(e.config.ref_table.name, PM.current_config())
    play_sound('generic1', nil, 0.4)
    refresh()
end

G.FUNCS.bl_preset_delete = function(e)
    P.delete(e.config.ref_table.name)
    play_sound('cancel', nil, 0.4)
    refresh()
end

G.FUNCS.bl_preset_save = function(e)
    local name = PM.state.name
    if not name or name:gsub('%s', '') == '' then
        play_sound('cancel', nil, 0.4)
        PM.state.notice = localize('bl_preset_need_name')
        refresh()
        return
    end
    P.save(name, PM.current_config())
    PM.state.name = ''
    PM.state.notice = ''
    play_sound('generic1', nil, 0.4)
    refresh()
end

G.FUNCS.bl_presets_prev = function(e)
    PM.state.page = PM.state.page - 1
    if PM.state.page < 1 then PM.state.page = PM.state.pages end
    play_sound('cardSlide1', nil, 0.3)
    refresh()
end

G.FUNCS.bl_presets_next = function(e)
    PM.state.page = PM.state.page + 1
    if PM.state.page > PM.state.pages then PM.state.page = 1 end
    play_sound('cardSlide1', nil, 0.3)
    refresh()
end

G.FUNCS.bl_presets_back = function(e)
    play_sound('cancel', nil, 0.4)
    PM.close()
end
