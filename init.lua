HideUI = LibStub("AceAddon-3.0"):NewAddon("HideUI")

local defaults = {
    profile = {
        accountWide = true,
        isEnabled = true,
        globalOpacity = 50,
        isMouseover = true,
        mouseoverFadeIn = 0.5,
        mouseoverFadeOut = 0.5,
    },
}

function HideUI:OnInitialize()
    --Load DB
    self.db = LibStub("AceDB-3.0"):New("HideUIDB", defaults, true)
    --Load Modules
    HideUI:GetModule("UI_mod").db = self.db
    HideUI:GetModule("Core_mod").db = self.db
end