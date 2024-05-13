local AFKManager = HideUI:NewModule("AFKManager", "AceEvent-3.0")

function AFKManager:OnEnable()
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnAFK")
    self:OnAFK()
end

function AFKManager:OnDisable()    
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED", "OnAFK")
    self:SendMessage("PLAYER_AFK_STATE_CHANGED", false)
end

function AFKManager:OnAFK()
    if UnitIsAFK("player") then
        self:SendMessage("PLAYER_AFK_STATE_CHANGED", true)
    else
        self:SendMessage("PLAYER_AFK_STATE_CHANGED", false)
    end
end