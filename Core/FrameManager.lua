local FrameManager = HideUI:NewModule("FrameManager", "AceEvent-3.0")
local Base
local Cluster
local Data

local GAME_FRAMES = {}
local FINDING_FRAMES_INTERVAL = 1.7
local FINDING_FRAMES_REPEATS  = 3
local MOUSEOVER_TIME_INTERVAL = 0.2
local C_TIMER

local EVENT_FIELDS = {
    isAFKEnabled = true,
    isMountEnabled = true,
    isCombatEnabled = true,
    isInstanceEnabled = true
}

function FrameManager:OnInitialize()
    Data      = HideUI:GetModule("Data")
    Base      = HideUI:GetModule("Base")
    Cluster   = HideUI:GetModule("Cluster")
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

-- HideUI Inject
-------------------------------------------------------------------------------->>>
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

-- Binding Frames
-------------------------------------------------------------------------------->>>
function FrameManager:InitializeFrame(frame, props, globals)
    -- Impide que vuelva a crearse y ejecutarse si ya ha sido creado
    if frame and frame.HideUI then
        return frame
    end

    -- Crea si no existe
    if frame and not frame.HideUI then
        frame.HideUI = Base:Create(frame, props, globals)
    elseif not frame and props.cluster then
        frame = {}
        frame.HideUI = Cluster:Create(props, globals)
    end

    -- Si ha sido creado exitosamente, ejecuta
    if frame and frame.HideUI then
        frame.HideUI:OnReady()
    end

    return frame
end

function FrameManager:BindFrame(name)
    local globals = Data:Find("globals")
    local props  = Data:Find("frames")[name]
    local frame = GAME_FRAMES[name] or _G[name]
    if props then
        frame = self:InitializeFrame(frame, props, globals)
        if frame then
            GAME_FRAMES[name] = frame
        end
    end
end

function FrameManager:BindFrames()
    local globals = Data:Find("globals")
    local frames  = Data:Find("frames")
    local temp = {}
    local frame
    for _, props in pairs(frames) do
        frame = GAME_FRAMES[props.name] or _G[props.name]
        frame = self:InitializeFrame(frame, props, globals)
        if frame then
            temp[props.name] = frame
        end
    end
    GAME_FRAMES = temp
end

function FrameManager:UnbindFrame(name)
    local frame = GAME_FRAMES[name]
    if frame and frame.HideUI then
        frame.HideUI:OnDestroy()
        frame.HideUI = nil
    end
    GAME_FRAMES[name] = nil
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

-- Global and Frame settings
-------------------------------------------------------------------------------->>>
-- From Dispatcher
function FrameManager:GlobalSettingsUpdate(msg, field)
    for _, frame in pairs(GAME_FRAMES) do
        if frame and frame.HideUI then
            self:SendSettings(frame, field)
        end
    end
end

-- From Dispatcher
function FrameManager:FrameSettingsUpdate(msg, frame_name, field)
    local frame = GAME_FRAMES[frame_name]
    if frame and frame.HideUI then
        self:SendSettings(frame, field)
        -- Envía todos los fields, necesario filtrar en su correspondiente.
        frame.HideUI:SetExtra(field)

        if field == "isEnabled" then
            frame.HideUI:Refresh()
        end
    end
end

function FrameManager:SendSettings(frame, field)
    if field == "alphaAmount" then
        frame.HideUI:SetBaseAlpha()
    elseif string.find(field, "AlphaAmount") then
        frame.HideUI:SetSelectedAlpha(field)
    elseif EVENT_FIELDS[field] then
        frame.HideUI:SetSelectedEvent(field)
    end
end

-- Event Receiver
-------------------------------------------------------------------------------->>>
-- From EventManager
function FrameManager:EventReceiver(msg, event)
    -- Se encarga de comunicar a todos los frames todos los eventos detectados
    for _, frame in pairs(GAME_FRAMES) do
        if frame and frame.HideUI then
            frame.HideUI:EventListener(event)
        end
    end
end

-- Mouseover
-------------------------------------------------------------------------------->>>
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
            frame.HideUI:OnMouseover()
        end
    end
end