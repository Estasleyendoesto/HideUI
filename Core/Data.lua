local Data = HideUI:NewModule("Data")

local frames = { "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame", "PetActionBar", "MinimapCluster", "ObjectiveTrackerFrame",
"BuffFrame", "MicroMenuContainer", "BagsBar", "MainMenuBar", "BattlefieldMapFrame", "MultiBarBottomLeft", "MultiBarBottomRight",
"MultiBarRight", "MultiBarLeft", "Multibar5", "Multibar6", "Multibar7", "PlayerCastingBarFrame", "MainStatusTrackingBarContainer",
"EncounterBar", "StanceBar", "ZoneAbilityFrame", "PartyFrame", "Chatbox"
}
local frames_table = {}
for _, frame in ipairs(frames) do
    frames_table[frame] = {
        name = frame,
        source = "blizzard", --blizzard, community
        isEnabled = false,
        isMouseoverEnabled = true,
        --Alpha amount
        alphaAmount = 0.5,
        combatAlphaAmount = 1,
        afkAlphaAmount = 0,
        mountAlphaAmount = 0,
        instanceAlphaAmount = 1,
        --Events
        isCombatEnabled = true,
        isAFKEnabled = true,
        isMountEnabled = true,
        isInstanceEnabled = true,
    }
end
local globals = {
    isEnabled = true,
    isCharacter = false,
    isMouseoverEnabled = true,
    mouseoverFadeInDuration = 0.3,
    mouseoverFadeOutDuration = 0.4,
    --Alpha amount
    alphaAmount = 0.5,
    combatAlphaAmount = 1,
    afkAlphaAmount = 0,
    mountAlphaAmount = 0,
    instanceAlphaAmount = 1,
    --Events
    isCombatEnabled = true,
    isAFKEnabled = true,
    isMountEnabled = true,
    isInstanceEnabled = true,
    combatEndDelay = 1,
}
-- Unique additional parameters
do
    frames_table.Chatbox.isTextModeEnabled = false
end

-- Initial values
local INITIAL_GLOBALS
local INITIAL_FRAMES
do
    INITIAL_GLOBALS = {}
    for k, v in pairs(globals) do
        INITIAL_GLOBALS[k] = v
    end

    INITIAL_FRAMES = {}
    for frame_name, frame_tbl in pairs(frames_table) do
        local frame = {}
        for k, v in pairs(frame_tbl) do
            frame[k] = v
        end
        INITIAL_FRAMES[frame_name] = frame
    end
end

-- Defaults
local defaults = {
    profile = {
        globals = globals,
        frames  = frames_table,
    },
    char = nil,
}

---
function Data:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HideUIDB", defaults, "Default")
    -- self.db:ResetDB("Default") --DEBUG
    -- self.db:ResetProfile() --DEBUG
end

function Data:Find(field)
    if field then
        local profile = self:GetProfile()
        return profile[field]
    end
end

function Data:UpdateGlobals(field, input)
    if field then
        local profile = self:GetProfile()
        profile.globals[field] = input
    end
end

function Data:UpdateFrame(frame, field, input)
    if frame and field then
        local profile = self:GetProfile()
        profile.frames[frame][field] = input
    end
end

function Data:IsCharacterProfile()
    local empty = next(self.db.char) == nil
    if empty then
        return false
    else
        return self.db.char.globals.isCharacter
    end
end

function Data:SetCharacterProfile(choice)
    local empty = next(self.db.char) == nil
    if empty then
        self:ChangeProfile(true)
    end
    self.db.char.globals.isCharacter = choice
end

function Data:GetProfile()
    if self:IsCharacterProfile() then
        return self.db.char
    else
        return self.db.profile
    end
end

function Data:RestoreGlobals()
    local fresh_globals = self:CopyGlobals(INITIAL_GLOBALS)
    local profile = self:GetProfile()
    profile.globals = fresh_globals
end

function Data:RestoreBlizzardFrames()
    local profile = self:GetProfile()
    local database = profile.frames
    local fresh_frames = self:CopyFrames(INITIAL_FRAMES)
    for frame, fields in pairs(fresh_frames) do
        local source = fields.source
        if source == "blizzard" then
            database[frame] = fresh_frames[frame]
        end
    end
end

function Data:RestoreCommunityFrames()
    local profile = self:GetProfile()
    local database = profile.frames

    for frame, field in pairs(database) do
        local source = field.source
        if source == "community" then
            database[field.name] = {
                name = field.name,
                alias = field.alias or nil,
                source = "community",
                isEnabled = false,
                isMouseoverEnabled = true,
                --Alpha amount
                alphaAmount = 0.5,
                combatAlphaAmount = 1,
                afkAlphaAmount = 0,
                mountAlphaAmount = 0,
                instanceAlphaAmount = 1,
                --Events
                isCombatEnabled = true,
                isAFKEnabled = true,
                isMountEnabled = true,
                isInstanceEnabled = true,
            }
        end
    end
end

function Data:ChangeProfile(force)
    local profile_name
    if self:IsCharacterProfile() or force then
        local empty = next(self.db.char) == nil
        if empty then
            self.db.char.globals = self:CopyGlobals(self.db.profile.globals)
            self.db.char.frames = self:CopyFrames(self.db.profile.frames)
        end
        profile_name = UnitName("player") .. "@" .. GetRealmName()
    else
        profile_name = "Default"
    end
    self.db:SetProfile(profile_name)
end

function Data:RegisterFrame(input)
    local data = {
        name = input.name,
        source = input.source or "community",
        isEnabled = input.isEnabled or false,
        isMouseoverEnabled = input.isMouseoverEnabled or true,
        alphaAmount = input.alphaAmount or 0.5,
        isAFKEnabled = input.isAFKEnabled or true,
        isMountEnabled = input.isMountEnabled or true,
        isCombatEnabled = input.isCombatEnabled or true,
        isInstanceEnabled = input.isInstanceEnabled or true,
        combatAlphaAmount = input.combatAlphaAmount or 1,
        afkAlphaAmount = input.afkAlphaAmount or 0,
        mountAlphaAmount = input.mountAlphaAmount or 0,
        instanceAlphaAmount = input.instanceAlphaAmount or 1,
    }

    local profile = self:GetProfile()
    profile.frames[input.name] = data
end

function Data:UnregisterFrame(name)
    local profile = self:GetProfile()
    profile.frames[name] = nil
end

function Data:CopyGlobals(globals_table)
    local new_globals = {}
    for k, v in pairs(globals_table) do
        new_globals[k] = v
    end
    return new_globals
end

function Data:CopyFrames(frame_table)
    local new_frames = {}
    for frame_name, frame_tbl in pairs(frame_table) do
        local frame = {}
        for k, v in pairs(frame_tbl) do
            frame[k] = v
        end
        new_frames[frame_name] = frame
    end
    return new_frames
end