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
        alphaAmount = 0.5,
        isEnabled = false,
        isAlphaEnabled = false,
        isCombatEnabled = true,
        isAFKEnabled = true,
        isMountEnabled = true,
        isMouseoverEnabled = true,
        isInstanceEnabled = true,
    }
end
local globals = {
    isAccountWide = true,
    isEnabled = true,
    globalAlphaAmount = 0.5,
    isMouseoverEnabled = true,
    mouseoverFadeInAmount = 0.3,
    mouseoverFadeOutAmount = 0.4,
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