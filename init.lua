HideUI = LibStub("AceAddon-3.0"):NewAddon("HideUI")

local frame_names = { "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame", "PetActionBar", "MinimapCluster", "ObjectiveTrackerFrame",
    "BuffFrame", "MicroMenuContainer", "BagsBar", "MainMenuBar", "BattlefieldMapFrame", "MultiBarBottomLeft", "MultiBarBottomRight",
    "MultiBarRight", "MultiBarLeft", "Multibar5", "Multibar6", "Multibar7", "PlayerCastingBarFrame", "MainStatusTrackingBarContainer",
    "EncounterBar", "StanceBar", "Chatbox",
}
local frame_dic = {}
for _, name in ipairs(frame_names) do
    frame_dic[name] = {
        withAlpha = false,
        alpha = 0.5,
        combatEnable = true
    }
end
local defaults = {
    profile = {
        accountWide = true,
        isEnabled = true,
        globalOpacity = 0.5,
        isMouseover = true,
        mouseoverFadeIn = 0.3,
        mouseoverFadeOut = 0.4,
        isCombat = true,
        isInCombat = false,
        isAFK = true,
        frames = frame_dic
    }
}

function HideUI:OnInitialize()
    --Load DB
    self.db = LibStub("AceDB-3.0"):New("HideUIDB", defaults, true)
    --Load Modules
    HideUI:GetModule("DB_mod").db = self.db
end