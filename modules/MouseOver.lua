local MouseOver = HideUI:NewModule("MouseOver", "AceEvent-3.0")

local UI_FRAMES = {}
local CHAT_FRAMES = {}

local FADE_IN_DURATION = 0.5
local FADE_OUT_DURATION = 0.5

local TIME_INTERVAL = 0.25

function MouseOver:OnInitialize()
end

function MouseOver:OnEnable()
    self:RegisterMessage("UI_FRAMES_UPDATED", "UpdateUIFrames")
    self:RegisterMessage("MOUSEOVER_FADE_TIME_UPDATED", "UpdateFadeTime")
    self:TimerStart()
end

function MouseOver:OnDisable()
    self:UnregisterMessage("UI_FRAMES_UPDATED")
    self:UnregisterMessage("MOUSEOVER_FADE_TIME_UPDATED")
    self:TimerStop()
end

function MouseOver:UpdateUIFrames(msg, frames) --UI_FRAMES_UPDATED
    UI_FRAMES = frames
end

function MouseOver:UpdateFadeTime(msg, fade_type, amount) --MOUSEOVER_FADE_TIME_UPDATED
    if fade_type == "FADE_IN" then
        FADE_IN_DURATION = amount
    elseif fade_type == "FADE_OUT" then
        FADE_OUT_DURATION = amount
    end
end

function MouseOver:TimerStart()
    if not self.timer then
        self.timer = C_Timer.NewTicker(TIME_INTERVAL, function()
            self:OnLoop()
        end)
    end
end

function MouseOver:TimerStop()
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
end

function MouseOver:OnLoop()
    -- For UI_FRAMES
    for _, frame in pairs(UI_FRAMES) do
        if frame and frame:IsVisible() and frame:IsShown() then
            if frame:IsMouseOver() then
                self:SendMessage("MOUSEIN_ON_UI_FRAME", frame, FADE_IN_DURATION) --To FrameManager
            else
                self:SendMessage("MOUSEOUT_ON_UI_FRAME", frame, FADE_OUT_DURATION) --To FrameManager
            end
        end
    end

    -- For CHAT_FRAMES
    -- ...
end