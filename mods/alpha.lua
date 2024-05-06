local Alpha_mod = HideUI:NewModule("Alpha_mod", "AceHook-3.0")
local DB_mod
local Core_mod

function Alpha_mod:OnInitialize()
    --Load Modules
    DB_mod = HideUI:GetModule("DB_mod")
    Core_mod = HideUI:GetModule("Core_mod")
end

function Alpha_mod:OnEnable()
    self:UpdateAllFramesOpacity( DB_mod:Find("globalOpacity") )
    self:HookAnimatedFrames()
end

function Alpha_mod:OnDisable()
    self:UpdateAllFramesOpacity(100)
    self:UnhookAnimatedFrames()
end

function Alpha_mod:GetStaticFrames()
    --Interpretado como Static al no ser alterado su opacidad desde el WoW
    return {
        PlayerFrame,
        TargetFrame,
        FocusFrame,
        PetFrame,
        PetActionBar,
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
        StanceBar,--Dragonflight
        -- UIWidgetPowerBarContainerFrame --Dragonflight
    }
end

function Alpha_mod:GetAnimatedFrames()
    --Interpretado como Animated al ser alterado su opacidad desde el WoW
    return {
        PlayerCastingBarFrame,
        MainStatusTrackingBarContainer,
        -- Requiere Hook (No hookscript), omitido,
        -- Este cambio puede interferir con otros addons
        -- GameTooltip, 
    }
end

function Alpha_mod:UpdateFrameOpacity(frame, amount)
    --Opacidad a un unico frame
    if frame and frame:IsVisible() then
        frame:SetAlpha(amount / 100)
    end
end

function Alpha_mod:UpdateFramesOpacity(frames, amount)
    for _, frame in pairs(frames) do
        if frame then
            self:UpdateFrameOpacity(frame, amount)
        end
    end
end

function Alpha_mod:UpdateAllFramesOpacity(opacity)
    self:UpdateFramesOpacity(self:GetStaticFrames(), opacity)
end

function Alpha_mod:HookAnimatedFrames()
    local frames = self:GetAnimatedFrames()
    for _, frame in pairs(frames) do
        if not self:IsHooked(frame, "OnUpdate") then
            self:HookScript(frame, "OnUpdate", "OnAnimatedFrameUpdate")
        end
    end
end

function Alpha_mod:UnhookAnimatedFrames()
    local frames = self:GetAnimatedFrames()
    for _, frame in pairs(frames) do
        if self:IsHooked(frame, "OnUpdate") then
            self:Unhook(frame, "OnUpdate")
            self:UpdateFrameOpacity(frame, 100)
        end
    end
end

function Alpha_mod:OnAnimatedFrameUpdate(frame)
    if not frame:IsVisible() then
        return
    end
    if frame:GetAlpha() == (DB_mod:Find("globalOpacity") / 100) then
        return --Reduce impacto de rendimiento de OnUpdate
    else
        if not frame.isMouseEnter and not frame.isMouseOut then
            self:UpdateFrameOpacity(frame, DB_mod:Find("globalOpacity"))
        end
    end
end