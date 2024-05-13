local AFK_mod = HideUI:NewModule("AFK_mod", "AceEvent-3.0")
local DB_mod

local FrameHandler_mod
local Chat_mod

function AFK_mod:OnInitialize()
    --Load Modules
    DB_mod = HideUI:GetModule("DB_mod")
    FrameHandler_mod = HideUI:GetModule("FrameHandler_mod")
    Chat_mod = HideUI:GetModule("Chat_mod")
end

function AFK_mod:OnEnable()
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnAFKBehaviour")
    if UnitIsAFK("player") then
        if DB_mod:Find("isAFK") then
            self:OnAFKEnable()
        end
    end
end

function AFK_mod:OnDisable()
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED", "OnAFKBehaviour")
    if DB_mod:Find("isEnabled") then
        -- Reset opacity
        self:OnAFKDisable()
    end
end

function AFK_mod:OnAFKBehaviour(event, unit)
    if UnitIsAFK("player") then
        if DB_mod:Find("isAFK") then
            self:OnAFKEnable()
        end
    else
        if DB_mod:Find("isAFK") then
            self:OnAFKDisable()
        end
    end
end

function AFK_mod:OnAFKEnable()
    FrameHandler_mod.inAFK = true
    FrameHandler_mod.globalOpacity = 0
    FrameHandler_mod:FadeOutFrames(0)
    Chat_mod.inAFK = true
    Chat_mod.globalOpacity = 0
    Chat_mod:FadeOutChats(nil, nil, true)
end

function AFK_mod:OnAFKDisable()
    FrameHandler_mod.globalOpacity = DB_mod:Find("globalOpacity")
    FrameHandler_mod:FadeInFrames(FrameHandler_mod.globalOpacity)
    FrameHandler_mod.inAFK = false
    Chat_mod.globalOpacity = DB_mod:Find("globalOpacity")
    Chat_mod:FadeInChats(Chat_mod.globalOpacity)
    Chat_mod.inAFK = false
end