HideUI = LibStub("AceAddon-3.0"):NewAddon("HideUI")

local defaults = {
    profile = {
        accountWide = true,
        isEnabled = true,
        globalOpacity = 42,
        isMouseover = true,
        mouseoverFadeIn = 0.3,
        mouseoverFadeOut = 0.4,
        isCombat = true,
        isAFK = true,
        
        --Chat Tabs Fade
        chatTabShowDelay = 0,
        ChatTabHideDelay = 1,
        ChatFrameFadeTime = 0.15,
        ChatFrameFadeOutTime = 2.0,
    },
}

function HideUI:OnInitialize()
    --Load DB
    self.db = LibStub("AceDB-3.0"):New("HideUIDB", defaults, true)
    --Load Modules
    HideUI:GetModule("DB_mod").db = self.db
end