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
    isEnabled = true,
    isCharacter = false,
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
-- Unique parameters
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
        if self:IsCharacterProfile() then
            return self.db.char[field]
        else
            return self.db.profile[field]
        end
    end
end

function Data:UpdateGlobals(field, input)
    if field then
        if self:IsCharacterProfile() then
            self.db.char.globals[field] = input
        else
            self.db.profile.globals[field] = input
        end
    end
end

function Data:UpdateFrame(frame, field, input)
    if frame and field then
        if self:IsCharacterProfile() then
            self.db.char.frames[frame][field] = input
        else
            self.db.profile.frames[frame][field] = input
        end
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

function Data:RestoreGlobals()
    local clean_globals = self:CopyGlobals(INITIAL_GLOBALS)
    if self:IsCharacterProfile() then
        self.db.char.globals = clean_globals
    else
        self.db.profile.globals = clean_globals
    end
end

function Data:RestoreDefaultFrames()
end

function Data:RestoreCommunityFrames()
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