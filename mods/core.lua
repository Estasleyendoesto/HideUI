local Core_mod = HideUI:NewModule("Core_mod", "AceEvent-3.0")
local Alpha_mod
local Mouseover_mod
local Combat_mod
local AFK_mod
local Nameplates_mod
local Chat_mod
local UI_mod

function Core_mod:OnInitialize()
    --Load Modules
    Alpha_mod = HideUI:GetModule("Alpha_mod")
    Alpha_mod.db = self.db
    Mouseover_mod = HideUI:GetModule("Mouseover_mod")
    Mouseover_mod.db = self.db
    Chat_mod = HideUI:GetModule("Chat_mod")
    Chat_mod.db = self.db
    Combat_mod = HideUI:GetModule("Combat_mod")
    Combat_mod.db = self.db
    AFK_mod = HideUI:GetModule("AFK_mod")
    AFK_mod.db = self.db
    Nameplates_mod = HideUI:GetModule("Nameplates_mod")
    Nameplates_mod.db = self.db
    UI_mod = HideUI:GetModule("UI_mod")
    UI_mod.db = self.db
end

function Core_mod:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "RestoreUI")
end

function Core_mod:OnDisable()
    self:UnegisterEvent("PLAYER_ENTERING_WORLD")
end

-- SCRIPTS
----------------------------------------------------------------------------
function Core_mod:IsActive()
    return self.db.profile.isEnabled
end

function Core_mod:RestoreUI()
    --off all
    Mouseover_mod:Disable()
    Combat_mod:Disable()
    AFK_mod:Disable()
    Alpha_mod:Disable()
    Nameplates_mod:Disable()
    self:ToggleAll()
end

function Core_mod:ToggleAll()
    if self:IsActive() then
        Alpha_mod:Enable()
        Mouseover_mod:Enable()
        Combat_mod:Enable()
        Chat_mod:Enable()
        AFK_mod:Enable()
        Nameplates_mod:Enable()
    else
        Alpha_mod:Disable()
        Mouseover_mod:Disable()
        Combat_mod:Disable()
        Chat_mod:Disable()
        AFK_mod:Disable()
        Nameplates_mod:Disable()
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
    --Toggle Addon
    self:ToggleAll()
    --Update UI
    UI_mod:UpdateUI() --UI_mod
end

function Core_mod:UpdateGlobalTransparency(amount)
    self.db.profile.globalOpacity = amount
    Alpha_mod:UpdateAllFramesOpacity(amount) --Alpha_mod
end

function Core_mod:OnMouseoverToggle(checked)
    self.db.profile.isMouseover = checked

    if checked then
        Mouseover_mod:Enable()
    else
        Mouseover_mod:Disable()
    end
end

function Core_mod:UpdateMouseoverFadeInAmount(amount)
    self.db.profile.mouseoverFadeIn = amount
end

function Core_mod:UpdateMouseoverFadeOutAmount(amount)
    self.db.profile.mouseoverFadeOut = amount
end

function Core_mod:OnCombatToggle(checked)
    self.db.profile.isCombat = checked

    if checked then
        Combat_mod:Enable()
    else
        Combat_mod:Disable()
    end
end 

function Core_mod:OnAFKToggle(checked)
    self.db.profile.isAFK = checked

    if checked then
        AFK_mod:Enable()
    else
        AFK_mod:Disable()
    end
end 