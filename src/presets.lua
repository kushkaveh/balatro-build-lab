--- Presets: named RunConfigs persisted as JSON in the mod folder (shareable file), plus two built-ins.
--- File I/O via the nativefs global NFS (smods/src/preflight/core.lua:32; nativefs.read/write/getInfo at
--- libs/nativefs/nativefs.lua:257, 290, 402). JSON via the rxi json global JSON (core.lua:47;
--- JSON.encode/JSON.decode at libs/json/json.lua:134, 375 — decode raises on bad input, so pcall).
--- Never `load()` preset data; it is validated by BL.run_config.sanitize (unknown Jokers -> missing slot).
--- File idea from Balatro-DeckCreator Persistence.lua:43-103 (GPL-3.0): merge, dedupe, never crash.

BL.presets = {}
local P = BL.presets
local RC = BL.run_config

P.FILE = BL.mod.path .. 'presets.json'
P.MAX_NAME = 24
P.status = nil -- 'corrupt' when the file was reset

P.BUILTIN = {
    {
        name = 'Facepocalypse', builtin = true,
        config = {
            deck = 'b_red', stake = 'stake_white',
            jokers = {
                { key = 'j_bl_fun_hoe' },
                { key = 'j_pareidolia' },
                { key = 'j_sock_and_buskin', edition = 'e_foil' },
                { key = 'j_hanging_chad' },
                { key = 'j_bl_jazzy_clown' },
            },
            params = {},
        },
    },
    {
        name = 'Baron Machine', builtin = true,
        config = {
            deck = 'b_red', stake = 'stake_white',
            jokers = {
                { key = 'j_baron' },
                { key = 'j_bl_understudy' },
                { key = 'j_mime' },
                { key = 'j_bl_forger' },
                { key = 'j_blueprint', edition = 'e_negative' },
            },
            params = {},
        },
    },
}

P.user = nil

local function clean_name(name)
    name = tostring(name or ''):gsub('^%s+', ''):gsub('%s+$', '')
    return string.sub(name, 1, P.MAX_NAME)
end

function P.load()
    if P.user then return P.user end
    P.user = {}
    if not NFS.getInfo(P.FILE) then return P.user end
    local raw = NFS.read(P.FILE)
    local ok, data = pcall(JSON.decode, raw or '')
    if not ok or type(data) ~= 'table' or type(data.presets) ~= 'table' then
        P.status = 'corrupt'
        sendWarnMessage('presets.json is not valid; backing it up to presets.json.corrupt and starting fresh', 'BuildLab')
        pcall(NFS.write, P.FILE .. '.corrupt', raw or '')
        pcall(NFS.remove, P.FILE)
        return P.user
    end
    local seen = {}
    for _, e in ipairs(data.presets) do
        if type(e) == 'table' and type(e.name) == 'string' then
            local name = clean_name(e.name)
            if name ~= '' and not seen[name] then
                seen[name] = true
                P.user[#P.user + 1] = { name = name, config = RC.sanitize(e.config) }
            end
        end
    end
    return P.user
end

function P.save_file()
    local ok, str = pcall(JSON.encode, { version = 1, presets = P.user or {} })
    if not ok then
        sendErrorMessage('Could not serialise presets: ' .. tostring(str), 'BuildLab')
        return false
    end
    local success, err = NFS.write(P.FILE, str)
    if not success then sendErrorMessage('Could not write presets.json: ' .. tostring(err), 'BuildLab') end
    return success
end

--- Built-ins (sanitised) followed by user presets.
function P.all()
    local out = {}
    for _, b in ipairs(P.BUILTIN) do
        out[#out + 1] = { name = b.name, builtin = true, config = RC.sanitize(b.config) }
    end
    for _, u in ipairs(P.load()) do out[#out + 1] = u end
    return out
end

function P.find_user(name)
    for i, u in ipairs(P.load()) do
        if u.name == name then return u, i end
    end
end

--- Save (or overwrite) a user preset. Returns the stored entry or nil.
function P.save(name, cfg)
    name = clean_name(name)
    if name == '' then return nil end
    local entry = P.find_user(name)
    if entry then
        entry.config = RC.sanitize(cfg)
    else
        entry = { name = name, config = RC.sanitize(cfg) }
        table.insert(P.load(), entry)
    end
    P.save_file()
    return entry
end

function P.delete(name)
    local _, idx = P.find_user(name)
    if idx then
        table.remove(P.user, idx)
        P.save_file()
        return true
    end
    return false
end
