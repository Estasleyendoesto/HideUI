local FrameHandler_mod = HideUI:NewModule("FrameHandler_mod")
local DB_mod
local Utils_mod

function FrameHandler_mod:OnInitialize()
    DB_mod = HideUI:GetModule("DB_mod")
    Utils_mod = HideUI:GetModule("Utils_mod")

    self.updateInterval = 0.01 --Rápido, pero no más que un Hook a OnUpdate
    self.FramesUpdateInterval = 5
    self.FadeDelay = 0.25

    self.globalOpacity = nil
end

function FrameHandler_mod:OnEnable()
    self:Restore()
    self:EnableWithFade()
end

function FrameHandler_mod:OnDisable()
    self:DisableWithFade()
end

----------------------------------------------------------------------------
function FrameHandler_mod:CollectFrames()
    if not self.staticFrames then
        self.staticFrames = {}
    end
    local realFrames = {}
    local frames = {
        "PlayerFrame",
        "TargetFrame",
        "FocusFrame",
        "PetFrame",
        "PetActionBar",
        "MinimapCluster",
        "ObjectiveTrackerFrame",
        "BuffFrame",
        "MicroMenuContainer",
        "BagsBar",
        "MainMenuBar",
        "BattlefieldMapFrame",
        "MultiBarBottomLeft",
        "MultiBarBottomRight",
        "MultiBarRight",
        "MultiBarLeft",
        "Multibar5",
        "Multibar6",
        "Multibar7",
        "PlayerCastingBarFrame",
        "MainStatusTrackingBarContainer",
        -- "GameTooltip", -- Nop
        "EncounterBar", --Dragonflight
        "StanceBar", --Dragonflight
    } --21 registros

    --Obtiene de _G
    for _, frame_name in ipairs(frames) do
        local frame = self.staticFrames[frame_name] or _G[frame_name]
        if frame then
            -- realFrames[frame_name] = frame
            table.insert(realFrames, frame)
        end
    end

    self.staticFrames = realFrames
    return realFrames
end

function FrameHandler_mod:FindFrameAlpha(frame)
    local dbframes = DB_mod:Find("frames") 
    local db_frame = dbframes[frame:GetName()]
    if db_frame and db_frame.withAlpha then
        return db_frame.alpha
    else
        return nil
    end
end

function FrameHandler_mod:UpdateGlobalTransparency(amount) --From Core_mod
    self.globalOpacity = amount or DB_mod:Find("globalOpacity")
    local frames = self:CollectFrames()
    Utils_mod:Batch(frames, function(frame)
        local targetAlpha = self:FindFrameAlpha(frame) or self.globalOpacity -- own alpha
        Utils_mod:UpdateAlpha(frame, targetAlpha)
    end)
end

function FrameHandler_mod:UpdateFrameAlpha(frame_name, amount)
    for _, frame in ipairs(self.staticFrames) do
        if frame:GetName() == frame_name then
            local targetAlpha = amount or self:FindFrameAlpha(frame) or self.globalOpacity
            frame:SetAlpha(targetAlpha)
        end
    end
end

function FrameHandler_mod:CheckMouseOverState() --From Core_mod
    if DB_mod:Find("isMouseover") then
        self.isMouseoverEnabled = true
    else
        self.isMouseoverEnabled = false
    end
end

function FrameHandler_mod:TimerStart()
    if not self.timer then
        self.timer = C_Timer.NewTicker(self.updateInterval, function()
            self:OnLoop()
        end)
    end
end

function FrameHandler_mod:TimerEnd()
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
end

function FrameHandler_mod:OnLoop()
    Utils_mod:Wait(self, "CheckFrames", self.FramesUpdateInterval, true)

    if self.isMouseoverEnabled then
        Utils_mod:Wait(self, "DetectMouseOver", self.FadeDelay, true)
    end

    self:UpdateAnimatedFramesAlpha()
end

function FrameHandler_mod:UpdateAnimatedFramesAlpha()
    local frames = {
        PlayerCastingBarFrame,
        MainStatusTrackingBarContainer,
    }

    for _, frame in pairs(frames) do
        if frame and frame:IsVisible() and frame:IsShown() then
            frame:SetAlpha(self.globalOpacity)
        end
    end
end

function FrameHandler_mod:CheckFrames()
    self.staticFrames = self:CollectFrames()
end

function FrameHandler_mod:DetectMouseOver()
    local max_alpha = 1
    local fadeInDuration = DB_mod:Find("mouseoverFadeIn")

    local alpha = self.globalOpacity
    local fadeOutDuration = DB_mod:Find("mouseoverFadeOut")

    local result = Utils_mod:Batch(self.staticFrames, function(frame)
        if frame:IsVisible() and frame:IsShown() then
            if frame:IsMouseOver() then
                frame.HideUI_isFadedIn = true
                UIFrameFadeIn(frame, fadeInDuration, frame:GetAlpha(), max_alpha)
            else
                if frame.HideUI_isFadedIn then
                    local targetAlpha = alpha
                    if not self.inAFK then
                        targetAlpha = self:FindFrameAlpha(frame) or alpha -- own alpha
                    end
                    UIFrameFadeOut(frame, fadeOutDuration, frame:GetAlpha(), targetAlpha)
                    frame.HideUI_isFadedIn = false
                end
            end
        end
        return false
    end)
end

function FrameHandler_mod:FadeInFrame(frame, alpha, fade_duration)
    local max_alpha = alpha or 1
    local fadeInDuration = fade_duration or DB_mod:Find("mouseoverFadeIn")

    if frame:IsShown() then
        UIFrameFadeIn(frame, fadeInDuration, frame:GetAlpha(), max_alpha)
    end
end

function FrameHandler_mod:FadeOutFrame(frame, original_alpha, fade_duration)
    if self.isFadedIn then
        local alpha = original_alpha or self.globalOpacity
        local fadeOutDuration = fade_duration or DB_mod:Find("mouseoverFadeOut")

        if frame:IsShown() then
            local targetAlpha = self:FindFrameAlpha(frame) or alpha -- own alpha
            UIFrameFadeOut(frame, fadeOutDuration, frame:GetAlpha(), targetAlpha)
        end

        self.isFadedIn = false
    end
end

function FrameHandler_mod:FadeInFrames(alpha, fade_duration)
    --A todos los frames
    local max_alpha = alpha or 1
    local fadeInDuration = fade_duration or DB_mod:Find("mouseoverFadeIn")

    Utils_mod:Batch(self.staticFrames, function(frame)
        if frame:IsShown() then
            local targetAlpha = max_alpha
            if self.inAFK then
                targetAlpha = self:FindFrameAlpha(frame) or max_alpha -- own alpha
            end
            UIFrameFadeIn(frame, fadeInDuration, frame:GetAlpha(), targetAlpha)
        end
    end)
end

function FrameHandler_mod:FadeOutFrames(alpha, fade_duration)
    --A todos los frames
    local frames = self:CollectFrames()

    local base_alpha = alpha or self.globalOpacity
    local fadeOutDuration = fade_duration or DB_mod:Find("mouseoverFadeOut")

    Utils_mod:Batch(frames, function(frame) 
        if frame:IsShown() then
            local targetAlpha = base_alpha
            if not self.inAFK then
                targetAlpha = self:FindFrameAlpha(frame) or base_alpha -- own alpha
            end
            UIFrameFadeOut(frame, fadeOutDuration, frame:GetAlpha(), targetAlpha)
        end
    end)
end

function FrameHandler_mod:EnableWithFade(alpha, duration)
    self.globalOpacity = DB_mod:Find("globalOpacity")
    self:TimerStart()
    self:CheckMouseOverState()
    self:FadeOutFrames(alpha, duration) --Fade On
end

function FrameHandler_mod:DisableWithFade(alha, duration)
    self:TimerEnd()
    self:FadeInFrames(alpha, duration) --Fade Off
end

function FrameHandler_mod:Restore()
    self:TimerEnd()
    self:UpdateGlobalTransparency(1) --1 = Game base Alpha
end