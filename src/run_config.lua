--- RunConfig: the plain-data model behind a Build Lab run. Data, not code; JSON-serialisable.
---
--- {
---   version = 1,
---   deck  = 'b_red',          -- Back key (G.P_CENTERS), used by presets to drive the deck page
---   stake = 'stake_white',    -- Stake key (G.P_STAKES)
---   jokers = { {key='j_blueprint', edition='e_foil', stickers={eternal=true}}, {}, {}, {}, {} },
---   params = { dollars=nil, hands=nil, discards=nil, hand_size=nil, joker_slots=nil, consumable_slots=nil },
---   seed  = nil,
--- }
--- params: nil = leave vanilla (deck/stake effects apply); a number = absolute override.

BL.run_config = {}
local RC = BL.run_config

-- Slots: 5 base (vanilla joker_slots), one more per Negative-edition Joker (they don't use a slot:
-- card.lua:410-413), hard cap 20 (paged 5 per page). RC.SLOTS is the storage size.
RC.BASE_SLOTS = 5
RC.MAX_SLOTS = 20
RC.SLOTS = RC.MAX_SLOTS

-- Vanilla edition centre keys (../balatro-src/game.lua:658-662). 'e_base' = no edition.
RC.EDITIONS = { 'e_base', 'e_foil', 'e_holo', 'e_polychrome', 'e_negative' }
RC.EDITION_SET = {}
for _, e in ipairs(RC.EDITIONS) do RC.EDITION_SET[e] = true end

-- Vanilla starting params and the ids the challenge system accepts
-- (get_starting_params: ../balatro-src/functions/misc_functions.lua:1868-1881;
--  applied via rules.modifiers at game.lua:2101-2106).
RC.PARAMS = { 'dollars', 'hands', 'discards', 'hand_size', 'joker_slots', 'consumable_slots' }
RC.PARAM_DEFAULTS = { dollars = 4, hands = 4, discards = 3, hand_size = 8, joker_slots = 5, consumable_slots = 2 }
RC.PARAM_LIMITS = {
    dollars = { 0, 500 }, hands = { 1, 25 }, discards = { 0, 25 },
    hand_size = { 1, 25 }, joker_slots = { 0, 20 }, consumable_slots = { 0, 20 },
}

-- Stickers the vanilla challenge loader can apply at run start (game.lua:2067-2078).
RC.STICKERS = { 'eternal', 'pinned' }

function RC.new()
    local cfg = { version = 1, deck = 'b_red', stake = 'stake_white', jokers = {}, params = {}, seed = nil }
    for i = 1, RC.SLOTS do cfg.jokers[i] = {} end
    return cfg
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

--- Returns a validated deep copy. Unknown fields are dropped; bad values reset.
--- Slots whose Joker key is not loaded keep the key and get `missing = true` (never a crash).
function RC.sanitize(src)
    local cfg = RC.new()
    if type(src) ~= 'table' then return cfg end
    if type(src.deck) == 'string' and G.P_CENTERS[src.deck] and G.P_CENTERS[src.deck].set == 'Back' then
        cfg.deck = src.deck
    end
    if type(src.stake) == 'string' and G.P_STAKES and G.P_STAKES[src.stake] then
        cfg.stake = src.stake
    end
    if type(src.jokers) == 'table' then
        for i = 1, RC.SLOTS do
            local s = src.jokers[i]
            if type(s) == 'table' and type(s.key) == 'string' and s.key ~= '' then
                local slot = { key = s.key }
                local center = G.P_CENTERS[s.key]
                if not (center and center.set == 'Joker') then slot.missing = true end
                if type(s.edition) == 'string' and RC.EDITION_SET[s.edition] and s.edition ~= 'e_base' then
                    slot.edition = s.edition
                end
                if type(s.stickers) == 'table' then
                    for _, st in ipairs(RC.STICKERS) do
                        if s.stickers[st] == true then
                            slot.stickers = slot.stickers or {}
                            slot.stickers[st] = true
                        end
                    end
                end
                cfg.jokers[i] = slot
            end
        end
    end
    if type(src.params) == 'table' then
        for _, p in ipairs(RC.PARAMS) do
            local v = tonumber(src.params[p])
            if v then cfg.params[p] = clamp(math.floor(v), RC.PARAM_LIMITS[p][1], RC.PARAM_LIMITS[p][2]) end
        end
    end
    if type(src.seed) == 'string' and src.seed ~= '' then
        cfg.seed = string.upper(string.sub(src.seed, 1, 8))
    end
    return cfg
end

function RC.copy(cfg)
    return RC.sanitize(cfg)
end

function RC.set_joker(cfg, slot, key)
    if slot < 1 or slot > RC.SLOTS then return end
    if key then
        cfg.jokers[slot] = { key = key, edition = cfg.jokers[slot] and cfg.jokers[slot].edition or nil }
    else
        cfg.jokers[slot] = {}
    end
end

function RC.set_edition(cfg, slot, edition)
    local s = cfg.jokers[slot]
    if not s then return end
    if edition == 'e_base' or not RC.EDITION_SET[edition or ''] then s.edition = nil else s.edition = edition end
end

--- How many Jokers this config can start with: joker_slots (or 5) + Negatives, capped.
function RC.capacity(cfg)
    local base = (cfg.params and cfg.params.joker_slots) or RC.BASE_SLOTS
    local negatives = 0
    for i = 1, RC.SLOTS do
        local s = cfg.jokers[i]
        if s and s.key and not s.missing and s.edition == 'e_negative' then negatives = negatives + 1 end
    end
    return math.max(1, math.min(RC.MAX_SLOTS, base + negatives))
end

--- Number of visible slots: at least 5, at most capacity (so an empty freed slot is offered).
function RC.visible_slots(cfg)
    local cap = RC.capacity(cfg)
    local last_filled = 0
    for i = 1, RC.SLOTS do
        local s = cfg.jokers[i]
        if s and s.key then last_filled = i end
    end
    return math.max(RC.BASE_SLOTS, cap, last_filled)
end

--- Filled slot indices beyond capacity (they will not be started).
function RC.overflow_slots(cfg)
    local cap = RC.capacity(cfg)
    local out = {}
    for i = cap + 1, RC.SLOTS do
        local s = cfg.jokers[i]
        if s and s.key and not s.missing then out[#out + 1] = i end
    end
    return out
end

function RC.filled_slots(cfg)
    local n = 0
    for i = 1, RC.SLOTS do
        local s = cfg.jokers[i]
        if s and s.key and not s.missing then n = n + 1 end
    end
    return n
end

function RC.missing_slots(cfg)
    local out = {}
    for i = 1, RC.SLOTS do
        local s = cfg.jokers[i]
        if s and s.key and s.missing then out[#out + 1] = s.key end
    end
    return out
end
