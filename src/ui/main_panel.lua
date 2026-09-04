--- Build Lab main panel: five Joker slots rendered as real Cards in CardAreas, an edition cycler under
--- each slot (live shader preview), a compact header (Presets / Advanced / Clear) and a one-line summary.
--- Height budget: the whole panel must stay under the SMODS deck-preview column (5.95 units,
--- run_select.lua:565) so the page never pushes the nav bar (screen is 11.5 units, globals.lua:272).
--- Imitates SMODS' run-select selection grid (src/utils/run_select.lua:376-439, black rounded box) and the
--- vanilla Collection (UI_definitions.lua:3535-3575) for Cards: Card(x, y, G.CARD_W, G.CARD_H,
--- G.P_CARDS.empty, center) then area:emplace(card).
--- Panel swapping follows G.FUNCS.change_tab (button_callbacks.lua:1299-1314). Cyclers: create_option_cycle
--- (UI_definitions.lua:1955-2045); its args table is handed back as cycle_config (button_callbacks.lua:571-579),
--- so extra fields (bl_slot / bl_param) ride along.
--- Seed input is the SMODS nav-bar one (run_select.lua:146-166), so the panel has none.

BL.ui = BL.ui or {}
local MP = {}
BL.ui.main_panel = MP
local RC = BL.run_config

MP.PANEL_W = 8.7
MP.areas = {}
MP.modal_open = false

-- Edition labels from vanilla misc.labels (en-us.lua:3820-3830).
local EDITION_LABEL_KEYS = { e_foil = 'foil', e_holo = 'holographic', e_polychrome = 'polychrome', e_negative = 'negative' }

local function edition_label(key)
    local lk = EDITION_LABEL_KEYS[key]
    if not lk then return localize('bl_edition_base') end
    return localize(lk, 'labels')
end

local function edition_index(key)
    for i, e in ipairs(RC.EDITIONS) do if e == key then return i end end
    return 1
end

-- Param cycler value lists ("Auto" = nil = leave vanilla). Extra values are inserted if a config holds them.
local PARAM_STEPS = {
    dollars = { 0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 25, 30, 40, 50, 75, 100, 150, 200, 300, 500 },
    hands = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 25 },
    discards = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 25 },
    hand_size = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 20, 25 },
    joker_slots = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20 },
    consumable_slots = { 0, 1, 2, 3, 4, 5, 6, 8, 10, 15, 20 },
}

--- The live RunConfig for this run-select session.
function MP.config()
    local choices = SMODS.RunSelect.Setup.choices
    if type(choices.build_lab) ~= 'table' or not choices.build_lab.jokers then
        choices.build_lab = RC.new()
    end
    return choices.build_lab
end

--- Remove slot cards and unregister our CardAreas (same scrub SMODS does in build_selection_areas,
--- run_select.lua:380-389). Safe to call when the UIBox already removed them.
function MP.cleanup()
    for _, area in ipairs(MP.areas) do
        if area.cards then
            remove_all(area.cards)
            area.cards = {}
        end
        for j = #G.I.CARDAREA, 1, -1 do
            if G.I.CARDAREA[j] == area then table.remove(G.I.CARDAREA, j) end
        end
    end
    MP.areas = {}
    MP.modal_open = false
end

local function build_slot_areas()
    MP.cleanup()
    for i = 1, RC.SLOTS do
        -- CardArea(X, Y, W, H, config): cardarea.lua:5-30; 'title' areas draw no background (cardarea.lua:276)
        MP.areas[i] = CardArea(G.ROOM.T.w, G.ROOM.T.h, G.CARD_W, G.CARD_H,
            { card_limit = 1, type = 'title', highlight_limit = 0, bl_slot = i })
    end
end

--- (Re)create the preview card for one slot from the config.
function MP.populate_slot(i)
    local area = MP.areas[i]
    if not area then return end
    if area.cards then remove_all(area.cards) end
    area.cards = {}
    local slot = MP.config().jokers[i]
    local center = slot and slot.key and G.P_CENTERS[slot.key]
    if not (center and center.set == 'Joker') then return end
    local card = Card(area.T.x, area.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center,
        { bypass_discovery_center = true, bypass_discovery_ui = true })
    card.params.bl_slot = i
    -- SMODS Card:set_edition accepts 'e_<type>' keys (smods/src/overrides.lua:2072-2107); nil removes
    if slot.edition and slot.edition ~= 'e_base' then card:set_edition(slot.edition, true, true) end
    area:emplace(card)
end

function MP.populate_all()
    for i = 1, RC.SLOTS do MP.populate_slot(i) end
end

--- Swap the panel content (main panel <-> picker / presets / advanced). def_fn returns a ROOT node.
function MP.swap(def_fn)
    if not G.OVERLAY_MENU then return end
    local e = G.OVERLAY_MENU:get_UIE_by_ID('bl_panel')
    if not e then return end
    e.config.object:remove()
    e.config.object = UIBox { definition = def_fn(), config = { offset = { x = 0, y = 0 }, parent = e, type = 'cm' } }
    e.UIBox:recalculate()
end

function MP.show_main()
    MP.modal_open = false
    MP.swap(MP.root)
end

------------------------------------------------------------------------------------------------
-- Shared node helpers (used by the picker and presets panels too)
------------------------------------------------------------------------------------------------

--- Standard sub-screen header: title on the left, optional right-hand nodes.
function MP.header(title, right_nodes)
    return { n = G.UIT.R, config = { align = 'cm', minw = MP.PANEL_W, minh = 0.5, padding = 0.03 }, nodes = {
        { n = G.UIT.C, config = { align = 'cl', minw = 3.2 }, nodes = {
            { n = G.UIT.T, config = { text = title, scale = 0.42, colour = G.C.WHITE, shadow = true } },
        } },
        { n = G.UIT.C, config = { align = 'cr', minw = MP.PANEL_W - 3.2, padding = 0.02 }, nodes = right_nodes or {} },
    } }
end

function MP.small_button(args)
    return UIBox_button {
        id = args.id, ref_table = args.ref_table, button = args.button, label = { args.label },
        minw = args.minw or 1.3, minh = 0.42, scale = 0.32, colour = args.colour or G.C.RED, col = true,
    }
end

------------------------------------------------------------------------------------------------
-- Main panel nodes
------------------------------------------------------------------------------------------------

local function edition_cycler(i)
    local slot = MP.config().jokers[i]
    local labels = {}
    for k, e in ipairs(RC.EDITIONS) do labels[k] = edition_label(e) end
    return create_option_cycle {
        bl_slot = i,
        options = labels,
        current_option = edition_index(slot and slot.edition or 'e_base'),
        opt_callback = 'bl_cycle_edition',
        w = 1.0, h = 0.42, scale = 0.62, text_scale = 0.38,
        colour = G.C.DARK_EDITION,
        no_pips = true,
    }
end

local function slot_column(i)
    local slot = MP.config().jokers[i]
    local filled = slot and slot.key
    return { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = {
        -- slot frame (reads as a Joker slot even when empty)
        { n = G.UIT.R, config = { align = 'cm', colour = G.C.L_BLACK, r = 0.1, padding = 0.04, emboss = 0.04 }, nodes = {
            { n = G.UIT.O, config = { object = MP.areas[i], focus_args = { snap_to = (i == 1) } } },
        } },
        filled and { n = G.UIT.R, config = { align = 'cm' }, nodes = { edition_cycler(i) } }
            or { n = G.UIT.R, config = { align = 'cm', minh = 0.42 }, nodes = {
                { n = G.UIT.T, config = { text = localize('bl_empty_slot'), scale = 0.28, colour = G.C.UI.TEXT_INACTIVE } } } },
        { n = G.UIT.R, config = { align = 'cm', padding = 0.02 }, nodes = {
            UIBox_button { id = 'bl_pick_' .. i, ref_table = { slot = i }, button = 'bl_pick_slot',
                label = { localize(filled and 'bl_change' or 'bl_pick') }, minw = filled and 0.95 or 1.4, minh = 0.38, scale = 0.28, colour = G.C.BLUE, col = true },
            filled and UIBox_button { id = 'bl_clear_' .. i, ref_table = { slot = i }, button = 'bl_clear_slot',
                label = { 'X' }, minw = 0.38, minh = 0.38, scale = 0.28, colour = G.C.RED, col = true } or nil,
        } },
    } }
end

local function summary_text(cfg)
    local parts = {}
    for _, p in ipairs(RC.PARAMS) do
        if cfg.params[p] ~= nil then parts[#parts + 1] = localize('bl_param_' .. p) .. ' ' .. cfg.params[p] end
    end
    local missing = RC.missing_slots(cfg)
    if #missing > 0 then
        return localize('bl_missing_hint') .. ' ' .. table.concat(missing, ', '), G.C.RED
    end
    if #parts > 0 then return table.concat(parts, '  ·  '), G.C.UI.TEXT_LIGHT end
    return localize('bl_hint'), G.C.UI.TEXT_INACTIVE
end

--- ROOT node for the main panel (goes inside the 'bl_panel' O-node).
function MP.root()
    build_slot_areas()
    local slots = {}
    for i = 1, RC.SLOTS do slots[#slots + 1] = slot_column(i) end
    MP.populate_all()

    local cfg = MP.config()
    local text, colour = summary_text(cfg)

    return { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR }, nodes = {
        { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = {
            MP.header(localize('bl_starting_jokers'), {
                MP.small_button { id = 'bl_presets_open', button = 'bl_presets_open', label = localize('bl_presets'), colour = G.C.GREEN, minw = 1.4 },
                MP.small_button { id = 'bl_advanced_open', button = 'bl_advanced_open', label = localize('bl_advanced'), colour = G.C.ORANGE, minw = 1.5 },
                MP.small_button { id = 'bl_clear_all', button = 'bl_clear_all', label = localize('bl_clear_all'), colour = G.C.RED, minw = 1.3 },
            }),
            { n = G.UIT.R, config = { align = 'cm', minw = MP.PANEL_W, colour = G.C.BLACK, padding = 0.1, r = 0.1, emboss = 0.05 }, nodes = slots },
            { n = G.UIT.R, config = { align = 'cm', minw = MP.PANEL_W, minh = 0.35 }, nodes = {
                { n = G.UIT.T, config = { text = text, scale = 0.28, colour = colour } },
            } },
        } },
    } }
end

--- Node returned to SMODS create_page(): a column holding the swappable panel.
function MP.page_node()
    return { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = {
        { n = G.UIT.O, config = { id = 'bl_panel', object = UIBox { definition = MP.root(), config = { offset = { x = 0, y = 0 } } } } },
    } }
end

------------------------------------------------------------------------------------------------
-- Advanced sub-screen: starting parameters
------------------------------------------------------------------------------------------------

local function param_cycler(name)
    local cfg = MP.config()
    local current = cfg.params[name]
    local values = { false }
    local labels = { localize('bl_auto') }
    local inserted = false
    for _, v in ipairs(PARAM_STEPS[name]) do
        if current and not inserted and current < v then
            values[#values + 1] = current; labels[#labels + 1] = tostring(current); inserted = true
        end
        if current == v then inserted = true end
        values[#values + 1] = v; labels[#labels + 1] = tostring(v)
    end
    if current and not inserted then values[#values + 1] = current; labels[#labels + 1] = tostring(current) end
    local idx = 1
    for k, v in ipairs(values) do if v == current then idx = k end end
    return create_option_cycle {
        bl_param = name,
        bl_values = values,
        label = localize('bl_param_' .. name),
        options = labels,
        current_option = idx,
        opt_callback = 'bl_cycle_param',
        w = 1.6, h = 0.55, scale = 0.8, text_scale = 0.42,
        colour = G.C.RED,
        no_pips = true,
    }
end

function MP.advanced_root()
    local rows = {}
    local per_row = 3
    for r = 1, math.ceil(#RC.PARAMS / per_row) do
        local cols = {}
        for c = 1, per_row do
            local p = RC.PARAMS[(r - 1) * per_row + c]
            if p then cols[#cols + 1] = { n = G.UIT.C, config = { align = 'cm', padding = 0.08, minw = 2.8 }, nodes = { param_cycler(p) } } end
        end
        rows[#rows + 1] = { n = G.UIT.R, config = { align = 'cm', padding = 0.05 }, nodes = cols }
    end
    return { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR }, nodes = {
        { n = G.UIT.C, config = { align = 'cm', padding = 0.03 }, nodes = {
            MP.header(localize('bl_advanced_title'), {
                MP.small_button { id = 'bl_params_reset', button = 'bl_params_reset', label = localize('bl_reset_auto'), colour = G.C.RED, minw = 1.6 },
                MP.small_button { id = 'bl_advanced_back', button = 'bl_advanced_back', label = localize('b_back'), colour = G.C.ORANGE, minw = 1.3 },
            }),
            { n = G.UIT.R, config = { align = 'cm', minw = MP.PANEL_W, minh = 3.6, colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05 }, nodes = {
                { n = G.UIT.C, config = { align = 'cm' }, nodes = rows },
            } },
            { n = G.UIT.R, config = { align = 'cm', minw = MP.PANEL_W, minh = 0.35 }, nodes = {
                { n = G.UIT.T, config = { text = localize('bl_advanced_hint'), scale = 0.28, colour = G.C.UI.TEXT_INACTIVE } },
            } },
        } },
    } }
end

------------------------------------------------------------------------------------------------
-- Callbacks (G.FUNCS.<button>(e); e.config.ref_table is the button's ref_table)
------------------------------------------------------------------------------------------------

function MP.on_slot_click(i)
    if MP.modal_open then return end
    if BL.ui.joker_picker then
        BL.ui.joker_picker.open(i)
    end
end

G.FUNCS.bl_pick_slot = function(e)
    MP.on_slot_click(e.config.ref_table.slot)
end

G.FUNCS.bl_clear_slot = function(e)
    RC.set_joker(MP.config(), e.config.ref_table.slot, nil)
    play_sound('cardSlide1', nil, 0.4)
    MP.show_main()
end

G.FUNCS.bl_clear_all = function(e)
    local cfg = MP.config()
    for i = 1, RC.SLOTS do RC.set_joker(cfg, i, nil) end
    play_sound('cardSlide1', nil, 0.4)
    MP.show_main()
end

-- Edition cycler: update the config and re-shade the preview card in place.
G.FUNCS.bl_cycle_edition = function(args)
    local i = args.cycle_config.bl_slot
    local edition = RC.EDITIONS[args.to_key] or 'e_base'
    RC.set_edition(MP.config(), i, edition)
    local area = MP.areas[i]
    local card = area and area.cards and area.cards[1]
    if card then
        if edition == 'e_base' then card:set_edition(nil, true, true) else card:set_edition(edition, true, true) end
        card:juice_up(0.3, 0.3)
    end
end

G.FUNCS.bl_advanced_open = function(e)
    MP.modal_open = true
    play_sound('button', nil, 0.4)
    MP.swap(MP.advanced_root)
end

G.FUNCS.bl_advanced_back = function(e)
    play_sound('cancel', nil, 0.4)
    MP.show_main()
end

G.FUNCS.bl_cycle_param = function(args)
    local cc = args.cycle_config
    local v = cc.bl_values[args.to_key]
    MP.config().params[cc.bl_param] = v or nil
end

G.FUNCS.bl_params_reset = function(e)
    MP.config().params = {}
    play_sound('cardSlide1', nil, 0.4)
    MP.swap(MP.advanced_root)
end

G.FUNCS.bl_presets_open = function(e)
    if BL.ui.presets_modal then
        BL.ui.presets_modal.open()
    else
        play_sound('cancel', nil, 0.4)
    end
end
