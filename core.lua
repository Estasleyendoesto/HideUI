local Core_mod = HideUI:NewModule("Core_mod")
local UI_mod

function Core_mod:OnInitialize()
    UI_mod = HideUI:GetModule("UI_mod")
end

function Core_mod:OnEnable()
end

-- SCRIPTS
----------------------------------------------------------------------------
function Core_mod:GetNormalFrames()
    --Non persistent frames
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
        UIWidgetPowerBarContainerFrame, --Dragonflight
    }
end

function Core_mod:UpdateFramesOpacity(frames, amount)
    for _, frame in pairs(frames) do
        if frame then
            frame:SetAlpha(amount / 100)
        end
    end
end

function Core_mod:ToggleAllBehaviour()
    --Función exclusiva desde OnActiveToggle()
    --Si en ON recupera todo, si en OFF desactiva todo
    if self.db.profile.isEnabled then
        Core_mod:UpdateFramesOpacity(
            Core_mod:GetNormalFrames(),
            self.db.profile.globalOpacity
        )
    else
        Core_mod:UpdateFramesOpacity(
            Core_mod:GetNormalFrames(),
            100
        )
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
    UI_mod:UpdateUI()
    Core_mod:ToggleAllBehaviour() --Tras toggle, activa/desactiva todo
end

function Core_mod:UpdateGlobalTransparency(amount)
    self.db.profile.globalOpacity = amount
    if self.db.profile.isEnabled then 
        --Segun isEnabled, permite/evita el alpha tras mover el slider
        --Sin embargo, aun estando OFF guarda su valor en la DB
        Core_mod:UpdateFramesOpacity(
            Core_mod:GetNormalFrames(), 
            amount
        )
    end
end