local Core_mod = HideUI:NewModule("Core_mod", "AceHook-3.0")
local UI_mod

function Core_mod:OnInitialize()
    HideUI:GetModule("Mouseover_mod").db = self.db
    HideUI:GetModule("Chad_mod").db = self.db
    UI_mod = HideUI:GetModule("UI_mod")
end

function Core_mod:OnEnable()
    self:HookAnimatedFrames()
end

-- SCRIPTS
----------------------------------------------------------------------------
function Core_mod:IsActive()
    return self.db.profile.isEnabled
end

function Core_mod:GetStaticFrames()
    --Interpretado como Static al no ser alterado su opacidad desde el WoW
    return {
        PlayerFrame,
        TargetFrame,
        FocusFrame,
        PetFrame,
        MinimapCluster,
        ObjectiveTrackerFrame,
        BuffFrame,
        MicroMenuContainer,
        BagsBar,
        MainMenuBar,
        MultiBarBottomLeft,
        MultiBarBottomRight,
        MultiBarRight,
        MultiBarLeft,
        Multibar5,
        Multibar6,
        Multibar7,
        EncounterBar,
        UIWidgetPowerBarContainerFrame --Dragonflight
    }
end

function Core_mod:GetAnimatedFrames()
    --Interpretado como Animated al ser alterado su opacidad desde el WoW
    return {
        PlayerCastingBarFrame,
        MainStatusTrackingBarContainer,
        -- GameTooltip, --Tiene un problema, no solo necesita OnUpdate sino que también OnShow
    }
end

function Core_mod:UpdateFrameOpacity(frame, amount)
    --Opacidad a un unico frame
    if frame then
        frame:SetAlpha(amount / 100)
    end
end

function Core_mod:UpdateFramesOpacity(frames, amount)
    for _, frame in pairs(frames) do
        if frame then
            self:UpdateFrameOpacity(frame, amount)
        end
    end
end

function Core_mod:UpdateAllFramesOpacity(opacity)
    self:UpdateFramesOpacity(self:GetStaticFrames(), opacity)
end

function Core_mod:HookAnimatedFrames()
    local frames = self:GetAnimatedFrames()
    for _, frame in pairs(frames) do
        self:HookScript(frame, "OnUpdate", "OnAnimatedFrameUpdate")
    end
end

function Core_mod:OnAnimatedFrameUpdate(frame)
    --Reduce impacto de rendimiento de OnUpdate
    if frame:GetAlpha() == (self.db.profile.globalOpacity / 100) then
        return
    end
    --
    if self:IsActive() then
        self:UpdateFrameOpacity(frame, self.db.profile.globalOpacity)
    else
        self:UpdateFrameOpacity(frame, 100)
    end
end

-- KEYBINDING EVENT
----------------------------------------------------------------------------
function ToggleMinimalUI() 
    Core_mod:OnActiveToggle()
end

-- UI BEHAVIOUR
----------------------------------------------------------------------------
function Core_mod:OnActiveToggle(checked)
    if checked then
        self.db.profile.isEnabled = checked
    else
        self.db.profile.isEnabled = not self.db.profile.isEnabled
    end
    --Toggle Alpha
    if self:IsActive() then
        self:UpdateAllFramesOpacity(self.db.profile.globalOpacity)
    else
        self:UpdateAllFramesOpacity(100)
    end
    --Update UI
    UI_mod:UpdateUI()
end

function Core_mod:UpdateGlobalTransparency(amount)
    self.db.profile.globalOpacity = amount
    if self:IsActive() then 
        self:UpdateAllFramesOpacity(amount)
    end
end

function Core_mod:OnMouseoverToggle(checked)
    self.db.profile.isMouseOver = checked
end

function Core_mod:UpdateMouseoverFadeInAmount(amount)
    self.db.profile.mouseoverFadeIn = amount
end

function Core_mod:UpdateMouseoverFadeOutAmount(amount)
    self.db.profile.mouseoverFadeOut = amount
end