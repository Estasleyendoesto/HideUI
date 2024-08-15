local Data = HideUI:NewModule("Data")

local frames = { "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame", "PetActionBar", "MinimapCluster", "ObjectiveTrackerFrame",
"BuffFrame", "MicroMenuContainer", "BagsBar", "MainMenuBar", "BattlefieldMapFrame", "MultiBarBottomLeft", "MultiBarBottomRight",
"MultiBarRight", "MultiBarLeft", "Multibar5", "Multibar6", "Multibar7", "PlayerCastingBarFrame", "MainStatusTrackingBarContainer",
"EncounterBar", "StanceBar", "ZoneAbilityFrame", "PartyFrame", "WorldFrame", "Chatbox"
}
local frames_table = {}
for _, frame in ipairs(frames) do
    frames_table[frame] = {
        name = frame,
        source = "oficial",
        isEnabled = false,
        isMouseoverEnabled = true,
        isAlphaEnabled = false,
        --Alpha amount
        alphaAmount = 0.5,
        combatAlphaAmount = 1,
        afkAlphaAmount = 1,
        mountAlphaAmount = 1,
        instanceAlphaAmount = 1,
        --Events
        isCombatEnabled = true,
        isAFKEnabled = true,
        isMountEnabled = true,
        isInstanceEnabled = true,
    }
end
local globals = {
    isCharacter = false,
    isEnabled = true,
    isMouseoverEnabled = true,
    mouseoverFadeInDuration = 0.3,
    mouseoverFadeOutDuration = 0.4,
    --Alpha amount
    globalAlphaAmount = 0.5,
    combatAlphaAmount = 1,
    afkAlphaAmount = 1,
    mountAlphaAmount = 1,
    instanceAlphaAmount = 1,
    --Events
    isCombatEnabled = true,
    isAFKEnabled = true,
    isMountEnabled = true,
    isInstanceEnabled = true,
    combatEndDelay = 1,
}
local defaults = {
    profile = {
        globals = globals,
        frames  = frames_table,
    }
}

-- Defaults
local default_globals = {}
for k, v in pairs(globals) do
    default_globals[k] = v
end

local default_frames = {}
for frame_name, frame_tbl in pairs(frames_table) do
    local frame = {}
    for k, v in pairs(frame_tbl) do
        frame[k] = v
    end
    default_frames[frame_name] = frame
end

-- Extras
defaults.profile.frames.Chatbox.isTextModeEnabled = false

---
function Data:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HideUIDB", defaults, true)
    -- self.db:ResetProfile() --DEBUG
end

function Data:Find(field)
    if field then
        return self.db.profile[field]
    else
        print("HideUI: No se encuentra" .. field .. "en el registro.")
    end
end

function Data:UpdateGlobals(field, input)
    if field then
        self.db.profile.globals[field] = input
    else
        print("HideUI: No puede actualizar " .. field .. " en el registro.")
    end
end

function Data:UpdateFrame(frame, field, input)
    if frame and field then
        self.db.profile.frames[frame][field] = input
    else
        print("HideUI: No puede actualizar ".. frame ..", ".. field .." en el registro.")
    end
end

function Data:ResetGlobals()
    self.db.profile.globals = {}
    for k, v in pairs(default_globals) do
        self.db.profile.globals[k] = v
    end
end

function Data:ResetDefaultFrames()
end

function Data:ResetCommunityFrames()
end

function Data:ChangeProfile(default)
    if default then
        -- Change to default global profile
    else
        -- Change to specific character profile
    end
end