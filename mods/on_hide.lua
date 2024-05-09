local OnHide_mod = HideUI:NewModule("OnHide_mod", "AceHook-3.0")
local DB_mod
local Utils_mod

function OnHide_mod:OnInitialize()
    DB_mod = HideUI:GetModule("DB_mod")
    Utils_mod = HideUI:GetModule("Utils_mod")

    self.updateInterval = 0.01
    self.FramesUpdateInterval = 5
    self.FadeDelay = 0.25
end

function OnHide_mod:OnEnable()
    self:UpdateGlobalTransparency(DB_mod:Find("globalOpacity"))
    self:CollectFrames()
    self:CheckMouseOverState()
end

function OnHide_mod:OnDisable()
    self:DisableMouseOver()
    self:UpdateGlobalTransparency(1)
end

----------------------------------------------------------------------------
function OnHide_mod:CollectFrames()
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
        if not self.staticFrames[frame_name] then
            local frame = _G[frame_name]
            if frame then
                table.insert(realFrames, frame)
            end
        else
            table.insert(realFrames, self.staticFrames[frame_name])
        end
    end

    self.staticFrames = realFrames
    return realFrames
end

function OnHide_mod:UpdateGlobalTransparency(amount)
    local frames = self:CollectFrames()
    Utils_mod:Batch(frames, function(frame)
        Utils_mod:UpdateAlpha(frame, amount)
    end)
end

function OnHide_mod:CheckMouseOverState()
    if DB_mod:Find("isMouseover") then
        self:EnableMouseOver()
    else
        self:DisableMouseOver()
    end
end

function OnHide_mod:EnableMouseOver()
    self:CreateTimer()
end

function OnHide_mod:DisableMouseOver()
    self:CancelTimer()
    self:UpdateGlobalTransparency(DB_mod:Find("globalOpacity"))
end

function OnHide_mod:CreateTimer()
    if not self.timer then
        self.timer = C_Timer.NewTicker(self.updateInterval, function()
            self:OnLoop()
        end)
    end
end

function OnHide_mod:CancelTimer()
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
end

function OnHide_mod:OnLoop()
    Utils_mod:Wait(self, "CheckFrames", self.FramesUpdateInterval, true)
    Utils_mod:Wait(self, "DetectMouseOver", self.FadeDelay, true)

    self:UpdateAnimatedFramesAlpha()
end

function OnHide_mod:UpdateAnimatedFramesAlpha()
    local frames = {
        PlayerCastingBarFrame,
        MainStatusTrackingBarContainer,
    }

    for _, frame in pairs(frames) do
        if frame and frame:IsVisible() and frame:IsShown() then
            frame:SetAlpha(DB_mod:Find("globalOpacity"))
        end
    end
end

function OnHide_mod:CheckFrames()
    self.staticFrames = self:CollectFrames()
end

function OnHide_mod:DetectMouseOver()
    local max_alpha = 1
    local fadeInDuration = DB_mod:Find("mouseoverFadeIn")

    local alpha = DB_mod:Find("globalOpacity")
    local fadeOutDuration = DB_mod:Find("mouseoverFadeOut")

    local result = Utils_mod:Batch(self.staticFrames, function(frame)
        if frame:IsVisible() and frame:IsShown() then
            if frame:IsMouseOver() then
                frame.HideUI_isFadedIn = true
                UIFrameFadeIn(frame, fadeInDuration, frame:GetAlpha(), max_alpha)
            else
                if frame.HideUI_isFadedIn then
                    UIFrameFadeOut(frame, fadeOutDuration, frame:GetAlpha(), alpha)
                    frame.HideUI_isFadedIn = false
                end
            end
        end
        return false
    end)
end

function OnHide_mod:FadeInFrame(frame, alpha)
    print("ha entrado")
    local max_alpha = alpha or 1
    local fadeInDuration = DB_mod:Find("mouseoverFadeIn")

    if frame:IsShown() then
        UIFrameFadeIn(frame, fadeInDuration, frame:GetAlpha(), max_alpha)
    end
end

function OnHide_mod:FadeOutFrame(frame, alpha)
    print("ha salido")
    if self.isFadedIn then
        local alpha = original_alpha or DB_mod:Find("globalOpacity")
        local fadeOutDuration = DB_mod:Find("mouseoverFadeOut")

        if frame:IsShown() then
            UIFrameFadeOut(frame, fadeOutDuration, frame:GetAlpha(), alpha)
        end

        self.isFadedIn = false
    end
end

function OnHide_mod:FadeInFrames(alpha)
    --A todos los frames
    local max_alpha = alpha or 1
    local fadeInDuration = DB_mod:Find("mouseoverFadeIn")

    Utils_mod:Batch(self.staticFrames, function(frame) 
        if frame:IsShown() then
            UIFrameFadeIn(frame, fadeInDuration, frame:GetAlpha(), max_alpha)
        end
    end)
end

function OnHide_mod:FadeOutFrames(original_alpha)
    --A todos los frames
    if self.isFadedIn then
        local alpha = original_alpha or DB_mod:Find("globalOpacity")
        local fadeOutDuration = DB_mod:Find("mouseoverFadeOut")

        Utils_mod:Batch(self.staticFrames, function(frame) 
            if frame:IsShown() then
                UIFrameFadeOut(frame, fadeOutDuration, frame:GetAlpha(), alpha)
            end
        end)

        self.isFadedIn = false
    end
end
