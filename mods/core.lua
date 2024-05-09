local Core_mod = HideUI:NewModule("Core_mod")
local DB_mod
local OnHide_mod
local Combat_mod
local AFK_mod
local Nameplates_mod
local Chat_mod
local UI_mod

function Core_mod:OnInitialize()
    --Load Modules
    DB_mod         = HideUI:GetModule("DB_mod")
    Chat_mod       = HideUI:GetModule("Chat_mod")
    OnHide_mod     = HideUI:GetModule("OnHide_mod")
    Combat_mod     = HideUI:GetModule("Combat_mod")
    -- AFK_mod        = HideUI:GetModule("AFK_mod")
    -- Nameplates_mod = HideUI:GetModule("Nameplates_mod")
    UI_mod         = HideUI:GetModule("UI_mod")
end

function Core_mod:OnEnable()
    self:RestoreUI()
end

function Core_mod:OnDisable()
end

-- CORE
----------------------------------------------------------------------------
function Core_mod:IsActive()
    return DB_mod:Find("isEnabled")
end

function Core_mod:RestoreUI()
    self:DisableModules()
    self:ToggleModules()
end

function Core_mod:ToggleModules()
    if self:IsActive() then
        self:EnableModules()
    else
        self:DisableModules()
    end
end

function Core_mod:EnableModules()
    OnHide_mod:Enable()
    Combat_mod:Enable()
    Chat_mod:Enable()
    -- AFK_mod:Enable()
    -- Nameplates_mod:Enable()
end

function Core_mod:DisableModules()
    OnHide_mod:Disable()
    Chat_mod:Disable()
    Combat_mod:Disable()
    -- AFK_mod:Disable()
    -- Nameplates_mod:Disable()
end

-- KEYBINDING EVENT
----------------------------------------------------------------------------
function ToggleMinimalUI() 
    Core_mod:OnActiveToggle()
end

-- UI BEHAVIOUR
----------------------------------------------------------------------------
function Core_mod:OnActiveToggle(checked)
    DB_mod:Update("isEnabled", checked or not DB_mod:Find("isEnabled"))
    Core_mod:ToggleModules() --Core_mod
    UI_mod:UpdateUI() --UI_mod
end

function Core_mod:UpdateGlobalTransparency(amount)
    DB_mod:Update("globalOpacity", amount)
    if self:IsActive() then 
        OnHide_mod:UpdateGlobalTransparency(amount) --OnHide_mod
        Chat_mod:UpdateGlobalTransparency(amount) --Chat_mod
    end
end

function Core_mod:OnMouseoverToggle(checked)
    DB_mod:Update("isMouseover", checked)
    if self:IsActive() then
        Chat_mod:CheckMouseOverState()
        OnHide_mod:CheckMouseOverState()
    end
end

function Core_mod:UpdateMouseoverFadeInAmount(amount)
    DB_mod:Update("mouseoverFadeIn", amount)
end

function Core_mod:UpdateMouseoverFadeOutAmount(amount)
    DB_mod:Update("mouseoverFadeOut", amount)
end

function Core_mod:OnCombatToggle(checked)
    DB_mod:Update("isCombat", checked)
end 

function Core_mod:OnAFKToggle(checked)
    DB_mod:Update("isAFK", checked)
end 