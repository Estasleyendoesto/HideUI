local Data = HideUI:NewModule("Data")

local frames = { "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame", "PetActionBar", "MinimapCluster", "ObjectiveTrackerFrame",
"BuffFrame", "MicroMenuContainer", "BagsBar", "MainMenuBar", "BattlefieldMapFrame", "MultiBarBottomLeft", "MultiBarBottomRight",
"MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7", "PlayerCastingBarFrame", "MainStatusTrackingBarContainer",
"SecondaryStatusTrackingBarContainer", "EncounterBar", "StanceBar", "ZoneAbilityFrame", "PartyFrame", "Chatbox"
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
        --Cluster
        cluster = false,
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
    frames_table.Chatbox.cluster = true
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
    }
}
---

local DEFAULT_PROFILE = "Default"

function Data:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HideUIDB", defaults, DEFAULT_PROFILE)
    self:LoadProfile()
    -- self.db:ResetDB("Default") --DEBUG
    -- self.db:ResetProfile() --DEBUG
end

function Data:Find(field)
    if field then
        local profile = self:GetProfile()
        return profile[field]
    end
end

function Data:CheckFrame(frame)
    if frame then
        local profile = self:GetProfile()
        local exists = profile.frames[frame] or nil
        if exists then
            return true
        else
            return false
        end
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

function Data:LoadProfile()
    local char_profile = self:GetCharProfileName()
    local isRegistered = self:HasProfile(char_profile)
    if isRegistered then
        self.db:SetProfile(char_profile)
        if not self.db.profile.globals.isCharacter then
            self.db:SetProfile(DEFAULT_PROFILE)
        end
    else
        self.db:SetProfile(DEFAULT_PROFILE)
    end
end

function Data:ChangeProfile(choice)
    local char_profile = self:GetCharProfileName()
    if choice then
        self.db:SetProfile(char_profile)

        if not self.db.profile.globals or not self.db.profile.frames then
            self.db:CopyProfile(DEFAULT_PROFILE)
        end

        self.db.profile.globals.isCharacter = true
    else
        self.db.profile.globals.isCharacter = false

        self.db:SetProfile(DEFAULT_PROFILE)
        self.db.profile.globals.isEnabled = true --siempre activo
    end
end

function Data:GetProfile()
    return self.db.profile, self.db:GetCurrentProfile()
end

function Data:HasProfile(profile_name)
    local profiles = self.db:GetProfiles()
    for _, name in ipairs(profiles) do
        if name == profile_name then
            return true
        end
    end

    return false
end

function Data:GetCharProfileName()
    return UnitName("player") .. "@" .. GetRealmName()
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

    for _, field in pairs(database) do
        if field.source == "community" then
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
                --Cluster
                cluster = false,
            }
        end
    end
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
        cluster = input.cluster or false,
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