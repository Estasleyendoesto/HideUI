local FrameManager = HideUI:NewModule("FrameManager", "AceEvent-3.0")
local FrameTemplate
local ChatFrame
local Data

local GAME_FRAMES = {}
local FINDING_FRAMES_INTERVAL = 1.7
local FINDING_FRAMES_REPEATS = 3
local MOUSEOVER_TIME_INTERVAL = 0.2
local C_TIMER

function FrameManager:OnInitialize()
    Data          = HideUI:GetModule("Data")
    FrameTemplate = HideUI:GetModule("FrameTemplate")
    ChatFrame  = HideUI:GetModule("ChatFrame")
end

function FrameManager:OnEnable()
    self:RegisterMessage("GLOBAL_SETTINGS_CHANGED", "GlobalSettingsUpdate")
    self:RegisterMessage("FRAME_SETTINGS_CHANGED", "FrameSettingsUpdate")
    self:RegisterMessage("PLAYER_STATE_CHANGED", "EventReceiver")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnInstance")
    self:OnLoader()
end

function FrameManager:OnDisable()
    self:UnregisterMessage("GLOBAL_SETTINGS_CHANGED")
    self:UnregisterMessage("FRAME_SETTINGS_CHANGED")
    self:UnregisterMessage("PLAYER_STATE_CHANGED")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:TimeHandler(false) --Mouseover Off
    self:UnbindFrames()

    -- Cancela el timer de búsqueda
    if C_TIMER then
        C_TIMER:Cancel()
        C_TIMER = nil
    end
end

-------------------------------------------------------------------------------->>>
-- Builder
function FrameManager:OnInstance()
    C_TIMER = C_Timer.NewTicker(FINDING_FRAMES_INTERVAL, function()
        self.BindFrames(self)
    end, FINDING_FRAMES_REPEATS)
    self:TimeHandler(true)
end

function FrameManager:OnLoader()
    -- Se ejecuta solo y cuando activemos el addon estando dentro del mundo
    self:BindFrames()
    self:TimeHandler(true)
end

-------------------------------------------------------------------------------->>>
-- Binding Frames
function FrameManager:BindFrames()
    local globals = Data:Find("globals")
    local frames  = Data:Find("frames")
    local temp = {}
    for _, data in pairs(frames) do
        local frame = GAME_FRAMES[data.name] or _G[data.name]
        if frame then
            if not frame.HideUI then
                frame.HideUI = FrameTemplate:Create(frame, data, globals)
                frame.HideUI:OnReady()
            end
            temp[data.name] = frame
        else
            if data.name == "Chatbox" then
                frame = {}
                frame.HideUI = ChatFrame:Create(data, globals)
                frame.HideUI:OnChatReady()
                temp[data.name] = frame
            end
        end
    end
    GAME_FRAMES = temp
end

function FrameManager:UnbindFrames()
    for _, frame in pairs(GAME_FRAMES) do
        if frame and frame.HideUI then
            frame.HideUI:OnDestroy()
            frame.HideUI = nil
        end
    end
    GAME_FRAMES = {}
end

function FrameManager:BindFrame(name)
    local globals = Data:Find("globals")
    local data  = Data:Find("frames")[name]
    local frame = GAME_FRAMES[name] or _G[name]
    if frame and data then
        if not frame.HideUI then
            frame.HideUI = FrameTemplate:Create(frame, data, globals)
            frame.HideUI:OnReady()
        end
        GAME_FRAMES[name] = frame
    end
end

function FrameManager:UnbindFrame(name)
    local frame = GAME_FRAMES[name]
    if frame and frame.HideUI then
        frame.HideUI:OnDestroy()
        frame.HideUI = nil
    end
    GAME_FRAMES[name] = nil
end

-------------------------------------------------------------------------------->>>
-- Global and Frame settings
function FrameManager:IsEventField(field)
    if field == "isAFKEnabled" or
       field == "isMountEnabled" or
       field == "isCombatEnabled" or
       field == "isInstanceEnabled"
    then
        return true
    else
        return false
    end
end

function FrameManager:GlobalSettingsUpdate(msg, field) --From Controller
    if field == "globalAlphaAmount" then
        for _, frame in pairs(GAME_FRAMES) do
            if frame and frame.HideUI then
                frame.HideUI:OnAlphaUpdate(field, "Global")
            end
        end
    elseif self:IsEventField(field) then
        for _, frame in pairs(GAME_FRAMES) do
            if frame and frame.HideUI and not frame.HideUI:IsActive() then
                frame.HideUI:OnEventUpdate(field, "Global")
            end
        end
    end
end

function FrameManager:FrameSettingsUpdate(msg, name, field) --From Controller
    local frame = GAME_FRAMES[name]
    if frame and frame.HideUI then
        if frame.HideUI:IsActive() then
            if field == "alphaAmount" or field == "isAlphaEnabled" then
                frame.HideUI:OnAlphaUpdate(field, "Custom")
            elseif self:IsEventField(field) then
                frame.HideUI:OnEventUpdate(field, "Custom")
            elseif field == "isEnabled" then
                frame.HideUI:OnFrameToggle("Custom")
            else
                frame.HideUI:OnExtraUpdate(field)
            end
        else
            if field == "isEnabled" then
                frame.HideUI:OnFrameToggle("Global")
            end
        end
    end
end

-------------------------------------------------------------------------------->>>
-- Event Receiver
function FrameManager:EventReceiver(msg, event) --From EventManager
    for _, frame in pairs(GAME_FRAMES) do
        if frame and frame.HideUI then
            if frame.HideUI:IsActive() then
                frame.HideUI:OnEvent(event, "Custom")
            else
                frame.HideUI:OnEvent(event, "Global")
            end
        end
    end
end

-------------------------------------------------------------------------------->>>
-- Mouseover
function FrameManager:TimeHandler(enabled)
    if enabled then
        if not self.timer then
            self.timer = C_Timer.NewTicker(MOUSEOVER_TIME_INTERVAL, function()
                self:OnLoop()
            end)
        end
    else
        if self.timer then
            self.timer:Cancel()
            self.timer = nil
        end
    end
end

function FrameManager:OnLoop()
    for _, frame in pairs(GAME_FRAMES) do
        if frame and frame.HideUI then
            if frame.HideUI:IsActive() then
                frame.HideUI:OnMouseover("Custom")
            else
                frame.HideUI:OnMouseover("Global")
            end
        end
    end
end