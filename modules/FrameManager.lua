local FrameManager = HideUI:NewModule("FrameManager", "AceEvent-3.0")
local FrameTemplate
local ChatboxTemplate
local Model

local GAME_FRAMES = {}
local FINDING_FRAMES_INTERVAL = 1.7
local FINDING_FRAMES_REPEATS = 3
local MOUSEOVER_TIME_INTERVAL = 0.2

function FrameManager:OnInitialize()
    Model = HideUI:GetModule("Model")
    FrameTemplate = HideUI:GetModule("FrameTemplate")
    ChatboxTemplate = HideUI:GetModule("ChatboxTemplate")
end

function FrameManager:OnEnable()
    --Global Settings
    self:RegisterMessage("GLOBAL_SETTINGS_CHANGED", "GlobalSettingsUpdate")
    --Frame Settings
    self:RegisterMessage("FRAME_SETTINGS_CHANGED", "FrameSettingsUpdate")
    --After Full Game Loaded
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnInstance")
    --State Handler
    self:RegisterMessage("PLAYER_STATE_CHANGED", "EventReceiver")
    --Bind Frames
    self:BindFrames()
    --Mouseover
    self:TimeHandler(true)
end

function FrameManager:OnDisable()
    --Global Settings
    self:UnregisterMessage("GLOBAL_SETTINGS_CHANGED")
    --Frame Settings
    self:UnregisterMessage("FRAME_SETTINGS_CHANGED")
    --After Full Game Loaded
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    --State Handler
    self:UnregisterMessage("PLAYER_STATE_CHANGED")
    --Mouseover
    self:TimeHandler(false)
    --Flush
    self:UnbindFrames()
end

-------------------------------------------------------------------------------->>>
-- Binding Frames
function FrameManager:BindFrames()
    local temp = {}
    local globals = {
        isMouseoverEnabled = Model:Find("isMouseoverEnabled"),
        globalAlphaAmount = Model:Find("globalAlphaAmount"),
        mouseoverFadeInAmount = Model:Find("mouseoverFadeInAmount"),
        mouseoverFadeOutAmount = Model:Find("mouseoverFadeOutAmount"),
        isAFKEnabled = Model:Find("isAFKEnabled"),
        isMountEnabled = Model:Find("isMountEnabled"),
        isCombatEnabled = Model:Find("isCombatEnabled"),
        isInstanceEnabled = Model:Find("isInstanceEnabled"),
    }
    for _, dataframe in pairs(Model:Find("frames")) do
        local frame = _G[dataframe.name]
        if frame and not frame.HideUI then
            frame.HideUI = FrameTemplate:Create(frame, dataframe, globals)
            frame.HideUI:OnCreate()
        else
            if dataframe.name == "Chatbox" then
                frame = {}
                frame.HideUI = ChatboxTemplate:Create(dataframe, globals)
                frame.HideUI:OnCreate()
            end
        end
        temp[dataframe.name] = frame
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

-------------------------------------------------------------------------------->>>
-- Instance
function FrameManager:OnInstance()
    C_Timer.NewTicker(FINDING_FRAMES_INTERVAL, function() self.BindFrames(self) end, FINDING_FRAMES_REPEATS)
    self:TimeHandler(true)
end

-------------------------------------------------------------------------------->>>
-- State Handler
function FrameManager:EventReceiver(msg, event)
    for _, frame in pairs(GAME_FRAMES) do
        if frame and frame.HideUI then
            frame.HideUI:OnEvent(event)
        end
    end
end

function FrameManager:VerifyStateSetting(frame, field, from)
    if field == "isAFKEnabled" or
       field == "isMountEnabled" or
       field == "isCombatEnabled" or
       field == "isInstanceEnabled" or
      (field == "isEnabled" and from == "Custom")
    then
        frame.HideUI:OnStateConfig(field, from)
    end
end

-------------------------------------------------------------------------------->>>
-- Global and Frame settings
function FrameManager:GlobalSettingsUpdate(msg, field, input)
    for _, frame  in pairs(GAME_FRAMES) do
        if frame and frame.HideUI then
            frame.HideUI.globals[field] = input
            if field == "globalAlphaAmount" then
                frame.HideUI:OnAlphaUpdate("Global")
            else
                self:VerifyStateSetting(frame, field, "Global")
            end
        end
    end
end

function FrameManager:FrameSettingsUpdate(msg, frame_name, field, input)
    local frame = GAME_FRAMES[frame_name]
    if frame and frame.HideUI then
        frame.HideUI.args[field] = input
        if field == "alphaAmount" then
            frame.HideUI:OnAlphaUpdate("Custom")
        elseif field == "isAlphaEnabled" or field == "isEnabled" then
            frame.HideUI:OnAlphaEvent("Custom")
        else
            self:VerifyStateSetting(frame, field, "Custom")
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
            frame.HideUI:OnMouseover()
        end
    end
end

-------------------------------------------------------------------------------->>>
-- FrameTemplate
-- function FrameManager:CreateFrameTemplate()
--     local template = {}
--     template.name = "HideUI"
--     template.type = "Frame"

--     return template
-- end

-- function FrameManager:CreateChatTemplate()
--     local template = self:CreateFrameTemplate()
--     template.type = "Chatbox"

--     return template
-- end


--[[ local FrameManager = HideUI:NewModule("FrameManager", "AceEvent-3.0")
local Model

local CUSTOMIZED_FRAME_SETTINGS = {}
local UI_FRAMES = {}

local DEFAULT_ALPHA = 1
local GLOBAL_ALPHA = 1

local LAST_STATE_ALPHA_AMOUNT = nil

local FADE_IN_DURATION = 0.5
local FADE_OUT_DURATION = 0.5

local POST_UI_FRAMES_UPDATE_DELAY = 0.8

function FrameManager:OnInitialize()
    Model = HideUI:GetModule("Model")
end

function FrameManager:OnEnable()
    GLOBAL_ALPHA = Model:Find("globalAlphaAmount")
    CUSTOMIZED_FRAME_SETTINGS = Model:Find("frames")

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "PlayerEnteringWorld")

    self:RegisterMessage("GLOBAL_ALPHA_UPDATED", "UpdateGlobalAlpha")
    self:RegisterMessage("FRAME_ALPHA_ENABLED", "UpdateCustomizedAlpha")
    self:RegisterMessage("FRAME_ALPHA_DISABLED", "UpdateCustomizedAlpha")
    self:RegisterMessage("FRAME_ALPHA_UPDATED", "UpdateCustomizedAlpha")
    self:RegisterMessage("MOUSEIN_ON_UI_FRAME", "OnMouseOverEnter")
    self:RegisterMessage("MOUSEOUT_ON_UI_FRAME", "OnMouseOverOut")

    self:RegisterMessage("PLAYER_STATE_CHANGED", "PlayerStateHandler")
end

function FrameManager:OnDisable()
    LAST_STATE_ALPHA_AMOUNT = nil

    self:UpdateGlobalAlpha("GLOBAL_ALPHA_DISABLED")

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")

    self:UnregisterMessage("GLOBAL_ALPHA_UPDATED")
    self:UnregisterMessage("FRAME_ALPHA_ENABLED")
    self:UnregisterMessage("FRAME_ALPHA_DISABLED")
    self:UnregisterMessage("FRAME_ALPHA_UPDATED")
    self:UnregisterMessage("MOUSEIN_ON_UI_FRAME")
    self:UnregisterMessage("MOUSEOUT_ON_UI_FRAME")

    self:UnregisterMessage("PLAYER_STATE_CHANGED")
end

----------------------------------------------------------------
-- Events, Messages
----------------------------------------------------------------
function FrameManager:PlayerEnteringWorld() --PLAYER_ENTERING_WORLD
    --Primer barrido con letargo necesario
    --Da tiempo a la detección del primer evento para controlar el alpha
    C_Timer.After(POST_UI_FRAMES_UPDATE_DELAY, function() 
        self:UpdateUIFrames()
        if LAST_STATE_ALPHA_AMOUNT then
            self:UpdateGlobalAlpha()
        else
            self:UpdateGlobalAlpha("GLOBAL_ALPHA_ENABLED")
        end
    end)
end

function FrameManager:UpdateUIFrames() 
    local temp = {}

    for frame_name, frame in pairs(CUSTOMIZED_FRAME_SETTINGS) do
        local frame = UI_FRAMES[frame_name] or _G[frame_name]
        if frame then
            temp[frame_name] = frame
        end
    end

    UI_FRAMES = temp
    self:SendMessage("UI_FRAMES_UPDATED", UI_FRAMES) --SEND TO MOUSEOVER mod
end

function FrameManager:UpdateGlobalAlpha(msg, amount) --GLOBAL_ALPHA_...
    for _, frame in pairs(UI_FRAMES) do
        if frame and frame:IsVisible() and frame:IsShown() then
            local alpha = self:CustomizedAlpha(frame) or amount or GLOBAL_ALPHA

            if     msg == "GLOBAL_ALPHA_ENABLED" then --OnEnable()
                UIFrameFadeOut(frame, FADE_OUT_DURATION, frame:GetAlpha(), alpha)

            elseif msg == "GLOBAL_ALPHA_DISABLED" then --OnDisable()
                UIFrameFadeIn(frame, FADE_IN_DURATION, frame:GetAlpha(), DEFAULT_ALPHA)

            elseif msg == "GLOBAL_ALPHA_UPDATED" then --Slider()
                frame:SetAlpha(alpha)
                if amount then GLOBAL_ALPHA = amount end
            else
                -- STATE MANAGER
                local state_alpha = self:CustomizedAlpha(frame) or LAST_STATE_ALPHA_AMOUNT
                UIFrameFadeOut(frame, FADE_OUT_DURATION, frame:GetAlpha(), state_alpha)
            end

        end
    end
end

function FrameManager:UpdateCustomizedAlpha(msg, frame_name) --FRAME_ALPHA...
    local frame = UI_FRAMES[frame_name]
    if frame and frame:IsVisible() and frame:IsShown() then
        local alpha = self:CustomizedAlpha(frame) or GLOBAL_ALPHA

        -- STATES
        if     msg == "FRAME_ALPHA_ENABLED" then
            UIFrameFadeOut(frame, FADE_OUT_DURATION, frame:GetAlpha(), alpha)
        elseif msg == "FRAME_ALPHA_DISABLED" then
            UIFrameFadeIn(frame, FADE_IN_DURATION, frame:GetAlpha(), LAST_STATE_ALPHA_AMOUNT or alpha) --STATE
        elseif msg == "FRAME_ALPHA_UPDATED" then
            frame:SetAlpha(alpha)
        else
            print(msg) --no exists
        end

    end
end

-- ----------------------------------------------------------------
-- CUSTOM ALPHA
-- ----------------------------------------------------------------
function FrameManager:CustomizedAlpha(frame) 
    local frame_settings = CUSTOMIZED_FRAME_SETTINGS[frame:GetName()]

    if frame_settings.isAlphaEnabled then
        return frame_settings.alphaAmount
    else
        return nil
    end
end

-- ----------------------------------------------------------------
-- MOUSEOVER
-- ----------------------------------------------------------------
function FrameManager:OnMouseOverEnter(msg, frame, fade_duration) --MOUSEIN_ON_UI_FRAME
    frame.HideUI_isFadedIn = true
    UIFrameFadeIn(frame, fade_duration, frame:GetAlpha(), DEFAULT_ALPHA)
end

function FrameManager:OnMouseOverOut(msg, frame, fade_duration) --MOUSEOUT_ON_UI_FRAME
    if frame.HideUI_isFadedIn then
        local alpha = self:CustomizedAlpha(frame) or LAST_STATE_ALPHA_AMOUNT or GLOBAL_ALPHA --STATE
        UIFrameFadeOut(frame, fade_duration, frame:GetAlpha(), alpha)
        frame.HideUI_isFadedIn = false
    end
end

-- ----------------------------------------------------------------
-- STATES
-- ----------------------------------------------------------------
function FrameManager:PlayerStateHandler(msg, state)
    local states = {
        --AFK
        PLAYER_AFK_STATE_ENTERED     = {alphaAmount = 0},
        PLAYER_AFK_STATE_RETURNED    = {alphaAmount = 0},
        PLAYER_AFK_STATE_EXITED      = {alphaAmount = GLOBAL_ALPHA},
        --Mount
        PLAYER_MOUNT_STATE_ENTERED   = {alphaAmount = 0},
        PLAYER_MOUNT_STATE_RETURNED  = {alphaAmount = 0},
        PLAYER_MOUNT_STATE_EXITED    = {alphaAmount = GLOBAL_ALPHA},
        --Combat
        PLAYER_COMBAT_STATE_ENTERED  = {alphaAmount = 1},
        PLAYER_COMBAT_STATE_RETURNED = {alphaAmount = 1},
        PLAYER_COMBAT_STATE_EXITED   = {alphaAmount = GLOBAL_ALPHA},
    }

    local current_state = states[state]
    if current_state then
        LAST_STATE_ALPHA_AMOUNT = current_state.alphaAmount
        self:UpdateGlobalAlpha()
        if string.find(state, "_EXITED") then
            LAST_STATE_ALPHA_AMOUNT = nil
        end
    end
end ]]