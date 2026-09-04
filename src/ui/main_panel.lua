--- Build Lab main panel: five Joker slots rendered as real Cards in CardAreas.
--- Imitates SMODS' run-select selection grid (src/utils/run_select.lua:376-439, black rounded box with
--- CardAreas of type 'title_2') and the vanilla Collection (UI_definitions.lua:3535-3575, Cards created
--- with Card(x, y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center) then area:emplace(card)).
--- Panel swapping follows G.FUNCS.change_tab (button_callbacks.lua:1299-1314): remove the O-node's
--- UIBox object, create a new one with parent = node, then UIBox:recalculate().

BL.ui = BL.ui or {}
local MP = {}
BL.ui.main_panel = MP
local RC = BL.run_config

MP.areas = {}
MP.modal_open = false

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
    local cfg = MP.config()
    local slot = cfg.jokers[i]
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

--- Swap the panel content (main panel <-> picker / presets). def_fn returns a ROOT node.
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
-- Node builders
------------------------------------------------------------------------------------------------

local function slot_label(i)
    local slot = MP.config().jokers[i]
    if slot and slot.key then
        if slot.missing then return localize('bl_missing') end
        return localize { type = 'name_text', set = 'Joker', key = slot.key }
    end
    return localize('bl_empty_slot')
end

local function slot_column(i)
    local slot = MP.config().jokers[i]
    local filled = slot and slot.key
    return { n = G.UIT.C, config = { align = 'cm', padding = 0.04 }, nodes = {
        { n = G.UIT.R, config = { align = 'cm' }, nodes = {
            { n = G.UIT.O, config = { object = MP.areas[i], focus_args = { snap_to = (i == 1) } } },
        } },
        { n = G.UIT.R, config = { align = 'cm', minh = 0.35, maxw = G.CARD_W + 0.2 }, nodes = {
            { n = G.UIT.T, config = { text = slot_label(i), scale = 0.26, colour = filled and G.C.WHITE or G.C.UI.TEXT_INACTIVE } },
        } },
        { n = G.UIT.R, config = { align = 'cm', padding = 0.02 }, nodes = {
            UIBox_button { id = 'bl_pick_' .. i, ref_table = { slot = i }, button = 'bl_pick_slot',
                label = { localize(filled and 'bl_change' or 'bl_pick') }, minw = 0.9, minh = 0.4, scale = 0.3, colour = G.C.BLUE, col = true },
            filled and UIBox_button { id = 'bl_clear_' .. i, ref_table = { slot = i }, button = 'bl_clear_slot',
                label = { 'X' }, minw = 0.4, minh = 0.4, scale = 0.3, colour = G.C.RED, col = true } or nil,
        } },
    } }
end

--- ROOT node for the main panel (goes inside the 'bl_panel' O-node).
function MP.root()
    build_slot_areas()
    local slots = {}
    for i = 1, RC.SLOTS do slots[#slots + 1] = slot_column(i) end
    MP.populate_all()

    local cfg = MP.config()
    local missing = RC.missing_slots(cfg)

    return { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR }, nodes = {
        { n = G.UIT.C, config = { align = 'cm', padding = 0.05 }, nodes = {
            { n = G.UIT.R, config = { align = 'cm', padding = 0.05 }, nodes = {
                { n = G.UIT.T, config = { text = localize('bl_starting_jokers'), scale = 0.45, colour = G.C.WHITE, shadow = true } },
            } },
            { n = G.UIT.R, config = { align = 'cm', minh = G.CARD_H + 1.2, minw = 8.7, colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05 }, nodes = slots },
            (#missing > 0) and { n = G.UIT.R, config = { align = 'cm', padding = 0.05 }, nodes = {
                { n = G.UIT.T, config = { text = localize('bl_missing_hint') .. ' ' .. table.concat(missing, ', '), scale = 0.3, colour = G.C.RED } },
            } } or nil,
        } },
    } }
end

--- Node returned to SMODS create_page(): a column holding the swappable panel.
function MP.page_node()
    return { n = G.UIT.C, config = { align = 'cm', padding = 0.05 }, nodes = {
        { n = G.UIT.O, config = { id = 'bl_panel', object = UIBox { definition = MP.root(), config = { offset = { x = 0, y = 0 } } } } },
    } }
end

------------------------------------------------------------------------------------------------
-- Button callbacks (G.FUNCS.<button>(e); e.config.ref_table is the button's ref_table)
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
