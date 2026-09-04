--- Joker picker: paged grid of real Joker cards from G.P_CENTER_POOLS.Joker with text search and a
--- rarity filter. Replaces the main panel inside the Build Lab page (same UIBox swap as change_tab).
--- Cards are drawn at 0.8 scale (Card accepts any w/h — SMODS draws stake chips at 0.99, runselectpage.lua:180)
--- so two rows fit the 5.95-unit height budget of the run-select page.
--- Imitates the Collection (UI_definitions.lua:3535-3575, button_callbacks.lua:602-621) for the grid and
--- SMODS' run-select cycler (run_select.lua:441-495) for the prev/next paging buttons.

BL.ui = BL.ui or {}
local PK = {}
BL.ui.joker_picker = PK
local RC = BL.run_config
local MP = BL.ui.main_panel

PK.ROWS, PK.COLS = 2, 5
PK.PER_PAGE = PK.ROWS * PK.COLS
PK.SCALE = 0.8

PK.areas = {}
PK.state = { slot = 1, query = '', applied_query = '', rarity = 1, page = 1, pages = 1, page_text = '', count_text = '', filtered = {} }

-- Rarity filter options. Vanilla rarities are ints 1-4 on centres (smods game_object.lua:1434-1447);
-- custom rarities keep their string key.
PK.RARITY_OPTIONS = {
    { label = 'bl_filter_all' },
    { label = 'k_common', rarity = 1 },
    { label = 'k_uncommon', rarity = 2 },
    { label = 'k_rare', rarity = 3 },
    { label = 'k_legendary', rarity = 4 },
    { label = 'k_bl_impossible', rarity = 'bl_impossible' },
    { label = 'bl_filter_modded', modded = true },
}

function PK.cleanup()
    for _, area in ipairs(PK.areas) do
        if area.cards then
            remove_all(area.cards)
            area.cards = {}
        end
        for j = #G.I.CARDAREA, 1, -1 do
            if G.I.CARDAREA[j] == area then table.remove(G.I.CARDAREA, j) end
        end
    end
    PK.areas = {}
end

local function center_name(center)
    local ok, name = pcall(localize, { type = 'name_text', set = 'Joker', key = center.key })
    if ok and type(name) == 'string' then return name end
    return center.name or center.key
end

local function update_texts()
    local st = PK.state
    st.page_text = localize('k_page') .. ' ' .. st.page .. '/' .. st.pages
    st.count_text = tostring(#st.filtered) .. ' ' .. localize('bl_jokers_short')
end

function PK.apply_filter()
    local st = PK.state
    local q = string.lower(st.query or '')
    local opt = PK.RARITY_OPTIONS[st.rarity] or PK.RARITY_OPTIONS[1]
    st.filtered = {}
    for _, center in ipairs(G.P_CENTER_POOLS.Joker) do
        local keep = true
        if opt.rarity ~= nil and center.rarity ~= opt.rarity then keep = false end
        if opt.modded and not center.mod then keep = false end
        if keep and q ~= '' then
            local hay = string.lower(center_name(center) .. ' ' .. center.key)
            if not string.find(hay, q, 1, true) then keep = false end
        end
        if keep then st.filtered[#st.filtered + 1] = center end
    end
    st.applied_query = st.query
    st.pages = math.max(1, math.ceil(#st.filtered / PK.PER_PAGE))
    if st.page > st.pages then st.page = 1 end
    update_texts()
end

local function build_areas()
    PK.cleanup()
    local w, h = G.CARD_W * PK.SCALE, G.CARD_H * PK.SCALE
    for i = 1, PK.PER_PAGE do
        PK.areas[i] = CardArea(G.ROOM.T.w, G.ROOM.T.h, w, h,
            { card_limit = 1, type = 'title', highlight_limit = 0, card_w = w, bl_pick_area = i })
    end
end

function PK.populate()
    local st = PK.state
    local first = (st.page - 1) * PK.PER_PAGE
    local w, h = G.CARD_W * PK.SCALE, G.CARD_H * PK.SCALE
    for i = 1, PK.PER_PAGE do
        local area = PK.areas[i]
        if area then
            if area.cards then remove_all(area.cards) end
            area.cards = {}
            local center = st.filtered[first + i]
            if center then
                local card = Card(area.T.x, area.T.y, w, h, G.P_CARDS.empty, center,
                    { bypass_discovery_center = true, bypass_discovery_ui = true })
                card.params.bl_pick = center.key
                area:emplace(card)
            end
        end
    end
    update_texts()
end

function PK.open(slot)
    PK.state.slot = slot
    PK.state.page = 1
    MP.modal_open = true
    play_sound('button', nil, 0.4)
    MP.swap(PK.root)
end

function PK.close()
    PK.cleanup()
    MP.show_main()
end

--- Card:click hook lands here (src/hooks.lua).
function PK.on_card_click(card)
    local key = card.params and card.params.bl_pick
    if not key then return end
    RC.set_joker(MP.config(), PK.state.slot, key)
    play_sound('card1', nil, 0.5)
    card:juice_up(0.3, 0.4)
    PK.close()
end

------------------------------------------------------------------------------------------------
-- Nodes
------------------------------------------------------------------------------------------------

function PK.root()
    build_areas()
    PK.apply_filter()
    PK.populate()

    local rows = {}
    for r = 1, PK.ROWS do
        local cols = {}
        for c = 1, PK.COLS do
            local idx = (r - 1) * PK.COLS + c
            cols[#cols + 1] = { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = {
                { n = G.UIT.O, config = { object = PK.areas[idx], focus_args = { snap_to = (idx == 1) } } },
            } }
        end
        rows[#rows + 1] = { n = G.UIT.R, config = { align = 'cm', padding = 0.02 }, nodes = cols }
    end

    local rarity_labels = {}
    for i, opt in ipairs(PK.RARITY_OPTIONS) do rarity_labels[i] = localize(opt.label) end

    return { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR }, nodes = {
        { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = {
            -- header: Back | title | search | rarity
            { n = G.UIT.R, config = { align = 'cm', minw = MP.PANEL_W, minh = 0.5, padding = 0.02 }, nodes = {
                MP.small_button { id = 'bl_picker_back', button = 'bl_picker_back', label = localize('b_back'), colour = G.C.ORANGE, minw = 1.1 },
                { n = G.UIT.C, config = { align = 'cm', minw = 1.5 }, nodes = {
                    { n = G.UIT.T, config = { text = localize('bl_slot') .. ' ' .. PK.state.slot, scale = 0.38, colour = G.C.WHITE, shadow = true } },
                } },
                { n = G.UIT.C, config = { align = 'cm', padding = 0.02, func = 'bl_picker_poll' }, nodes = {
                    create_text_input { w = 2.6, h = 0.5, text_scale = 0.35, max_length = 20, prompt_text = localize('bl_search'), ref_table = PK.state, ref_value = 'query', colour = G.C.BLUE },
                } },
                { n = G.UIT.C, config = { align = 'cm' }, nodes = {
                    create_option_cycle { options = rarity_labels, current_option = PK.state.rarity, opt_callback = 'bl_picker_rarity',
                        w = 2.2, h = 0.5, scale = 0.7, text_scale = 0.36, colour = G.C.RED, no_pips = true },
                } },
            } },
            -- grid
            { n = G.UIT.R, config = { align = 'cm', minw = MP.PANEL_W, colour = G.C.BLACK, padding = 0.1, r = 0.1, emboss = 0.05 }, nodes = {
                { n = G.UIT.C, config = { align = 'cm' }, nodes = rows },
            } },
            -- footer: count | < page >
            { n = G.UIT.R, config = { align = 'cm', minw = MP.PANEL_W, minh = 0.45, padding = 0.02 }, nodes = {
                { n = G.UIT.C, config = { align = 'cl', minw = 3.2 }, nodes = {
                    { n = G.UIT.T, config = { ref_table = PK.state, ref_value = 'count_text', scale = 0.3, colour = G.C.UI.TEXT_INACTIVE } },
                } },
                { n = G.UIT.C, config = { align = 'cr', minw = MP.PANEL_W - 3.2 }, nodes = {
                    UIBox_button { id = 'bl_picker_prev', button = 'bl_picker_prev', label = { '<' }, minw = 0.5, minh = 0.42, scale = 0.35, colour = G.C.RED, col = true },
                    { n = G.UIT.C, config = { align = 'cm', minw = 1.8 }, nodes = {
                        { n = G.UIT.T, config = { ref_table = PK.state, ref_value = 'page_text', scale = 0.34, colour = G.C.WHITE, shadow = true } },
                    } },
                    UIBox_button { id = 'bl_picker_next', button = 'bl_picker_next', label = { '>' }, minw = 0.5, minh = 0.42, scale = 0.35, colour = G.C.RED, col = true },
                } },
            } },
        } },
    } }
end

------------------------------------------------------------------------------------------------
-- Callbacks
------------------------------------------------------------------------------------------------

-- Per-frame node func (like G.FUNCS.can_start_run): refilter when the typed query changes.
G.FUNCS.bl_picker_poll = function(e)
    if PK.state.query ~= PK.state.applied_query then
        PK.state.page = 1
        PK.apply_filter()
        PK.populate()
    end
end

-- create_option_cycle callback receives {from_val, to_val, from_key, to_key, cycle_config}
-- (button_callbacks.lua:571-579)
G.FUNCS.bl_picker_rarity = function(args)
    PK.state.rarity = args.to_key
    PK.state.page = 1
    PK.apply_filter()
    PK.populate()
end

G.FUNCS.bl_picker_prev = function(e)
    local st = PK.state
    st.page = st.page - 1
    if st.page < 1 then st.page = st.pages end
    play_sound('cardSlide1', nil, 0.3)
    PK.populate()
end

G.FUNCS.bl_picker_next = function(e)
    local st = PK.state
    st.page = st.page + 1
    if st.page > st.pages then st.page = 1 end
    play_sound('cardSlide1', nil, 0.3)
    PK.populate()
end

G.FUNCS.bl_picker_back = function(e)
    play_sound('cancel', nil, 0.4)
    PK.close()
end
