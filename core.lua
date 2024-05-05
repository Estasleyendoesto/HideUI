local Core_mod = HideUI:NewModule("Core_mod", "AceHook-3.0", "AceEvent-3.0")
local Mouseover_mod
local Chat_mod
local UI_mod

function Core_mod:OnInitialize()
    --Load Modules
    Mouseover_mod = HideUI:GetModule("Mouseover_mod")
    Mouseover_mod.db = self.db
    Chat_mod = HideUI:GetModule("Chat_mod")
    Chat_mod.db = self.db
    UI_mod = HideUI:GetModule("UI_mod")
    UI_mod.db = self.db
end

function Core_mod:OnEnable()
    --Limpiar todo al entrar al juego (cuando todo ha cargado)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "RestoreUI")
end

function Core_mod:OnDisable()
    self:UnhookAnimatedFrames()
end

-- SCRIPTS
----------------------------------------------------------------------------
function Core_mod:IsActive()
    return self.db.profile.isEnabled
end

function Core_mod:RestoreUI()
    --off all
    Core_mod:UnhookAnimatedFrames()
    Mouseover_mod:Disable()
    ---
    self:ToggleAll()
end

function Core_mod:ToggleAll()
    if self:IsActive() then
        self:UpdateAllFramesOpacity(self.db.profile.globalOpacity)
        self:HookAnimatedFrames()
        Mouseover_mod:Enable()
    else
        self:UpdateAllFramesOpacity(100)
        self:UnhookAnimatedFrames()
        Mouseover_mod:Disable()
    end
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
        EncounterBar,--Dragonflight
        -- UIWidgetPowerBarContainerFrame --Dragonflight
    }
end

function Core_mod:GetAnimatedFrames()
    --Interpretado como Animated al ser alterado su opacidad desde el WoW
    return {
        PlayerCastingBarFrame,
        MainStatusTrackingBarContainer,
        -- Requiere Hook (No hookscript), omitido,
        -- Este cambio puede interferir con otros addons
        -- GameTooltip, 
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
        if not self:IsHooked(frame, "OnUpdate") then
            self:HookScript(frame, "OnUpdate", "OnAnimatedFrameUpdate")
        end
    end
end

function Core_mod:UnhookAnimatedFrames()
    local frames = self:GetAnimatedFrames()
    for _, frame in pairs(frames) do
        if self:IsHooked(frame, "OnUpdate") then
            self:Unhook(frame, "OnUpdate")
            self:OnAnimatedFrameOff(frame)
        end
    end
end

function Core_mod:OnAnimatedFrameUpdate(frame)
    if not frame:IsVisible() then
        return
    end
    if frame:GetAlpha() == (self.db.profile.globalOpacity / 100) then
        return --Reduce impacto de rendimiento de OnUpdate
    else
        if not frame.isMouseEnter and not frame.isMouseOut then
            self:UpdateFrameOpacity(frame, self.db.profile.globalOpacity)
        end
    end
end

function Core_mod:OnAnimatedFrameOff(frame)
    self:UpdateFrameOpacity(frame, 100)
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
    --Toggle Addon
    self:ToggleAll()
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
    self.db.profile.isMouseover = checked
end

function Core_mod:UpdateMouseoverFadeInAmount(amount)
    self.db.profile.mouseoverFadeIn = amount
end

function Core_mod:UpdateMouseoverFadeOutAmount(amount)
    self.db.profile.mouseoverFadeOut = amount
end