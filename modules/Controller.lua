local Controller = HideUI:NewModule("Controller", "AceEvent-3.0")
local Model
local Interface

function Controller:OnInitialize()
    Model = HideUI:GetModule("Model")
    Interface = HideUI:GetModule("Interface")
end

function Controller:OnEnable()
    self:ModulesHandler()
end

function Controller:OnDisable()
    self:ModulesHandler()
end

function Controller:ModulesHandler()
    if Model:Find("isEnabled") then
        HideUI:EnableModule("FrameManager")
        HideUI:EnableModule("StateManager")
    else
        HideUI:DisableModule("StateManager")
        HideUI:DisableModule("FrameManager")
    end
end

-------------------------------------------------------------------------------->>>
-- Bindings.xml
function HideUI_Enable_Keydown()
    Controller:HandleEnabledChange(not Model:Find("isEnabled"))
    Interface:UpdateUI()
end

-------------------------------------------------------------------------------->>>
-- Interface.lua...
function Controller:HandleEnabledChange(checked) --Toggle All
    Model:Update("isEnabled", checked)
    self:ModulesHandler()
end

function Controller:HandleAlphaChange(amount) --To FrameManager
    Model:Update("globalAlphaAmount", amount)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", "ALPHA_AMOUNT", amount)
end

function Controller:HandleMouseoverChange(checked) --To MouseOver
    Model:Update("isMouseoverEnabled", checked)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", "MOUSEOVER", checked)
end

function Controller:HandleMouseoverFadeAmount(fade_type, amount) --To MouseOver
    local field
    if fade_type == "FADE_IN" then
        field = "mouseoverFadeInAmount"
    else
        field = "mouseoverFadeOutAmount"
    end

    Model:Update(field, amount)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", "MOUSEOVER_" .. fade_type .. "_AMOUNT", amount)
end

function Controller:HandleCombatChange(checked) --To Combat
    Model:Update("isCombatEnabled", checked)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", "COMBAT", checked)
end

function Controller:HandleAFKChange(checked) --To AFK
    Model:Update("isAFKEnabled", checked)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", "AFK", checked)
end

function Controller:HandleMountChange(checked) --To Mount
    Model:Update("isMountEnabled", checked)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", "MOUNT", checked)
end

function Controller:HandleInstanceChange(checked) --To Instance
    Model:Update("isInstanceEnabled", checked)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", "INSTANCE", checked)
end

--[[ local Controller = HideUI:NewModule("Controller", "AceEvent-3.0")
local Model
local UIMenu

function Controller:OnInitialize()
    Model  = HideUI:GetModule("Model")
    UIMenu = HideUI:GetModule("UIMenu")
end

function Controller:OnEnable()
    self:ModulesHandler()
end

function Controller:ModulesHandler()
    local status = Model:Find("isEnabled")
    if status then
        HideUI:EnableModule("FrameManager")
        HideUI:EnableModule("ChatManager")
        self:MouseOverModuleHandler()
        self:CombatModuleHandler()
        self:AFKManagerModuleHandler()
        self:MountModeModuleHandler()
    else
        HideUI:DisableModule("FrameManager")
        HideUI:DisableModule("ChatManager")
        HideUI:DisableModule("MouseOver")
        HideUI:DisableModule("Combat")
        HideUI:DisableModule("AFKManager")
        HideUI:DisableModule("MountMode")
    end
end

function Controller:MouseOverModuleHandler()
    local status = Model:Find("isMouseOverEnabled")
    if status then
        HideUI:EnableModule("MouseOver")
    else
        HideUI:DisableModule("MouseOver")
    end
end

function Controller:CombatModuleHandler()
    local status = Model:Find("isCombatEnabled")
    if status then
        HideUI:EnableModule("Combat")
    else
        HideUI:DisableModule("Combat")
    end
end

function Controller:AFKManagerModuleHandler()
    local status = Model:Find("isAFKEnabled")
    if status then
        HideUI:EnableModule("AFKManager")
    else
        HideUI:DisableModule("AFKManager")
    end
end

function Controller:MountModeModuleHandler()
    local status = Model:Find("isMountEnabled")
    if status then
        HideUI:EnableModule("MountMode")
    else
        HideUI:DisableModule("MountMode")
    end
end

function Controller:HandleEnabledChange(checked)
    Model:Update("isEnabled", checked)
    self:ModulesHandler()
end

function Controller:HandleAlphaChange(amount) --To FrameManager
    Model:Update("globalAlphaAmount", amount)
    self:SendMessage("GLOBAL_ALPHA_UPDATED", amount)
end

function Controller:HandleFrameAlpha(frame_name, checked) --To FrameManager
    Model:UpdateTable(frame_name, "isAlphaEnabled", checked)
    if checked then
        self:SendMessage("FRAME_ALPHA_ENABLED", frame_name)
    else
        self:SendMessage("FRAME_ALPHA_DISABLED", frame_name)
    end
end

function Controller:HandleFrameAlphaAmount(frame_name, amount) --To FrameManager
    Model:UpdateTable(frame_name, "alphaAmount", amount)
    self:SendMessage("FRAME_ALPHA_UPDATED", frame_name)
end

function Controller:HandleMouseoverChange(checked) --To MouseOver
    Model:Update("isMouseOverEnabled", checked)
    self:ModulesHandler()
end

function Controller:HandleMouseOverFadeAmount(fade_type, amount) --To MouseOver
    if fade_type == "FADE_IN" then
        Model:Update("mouseOverFadeInAmount", amount)
    elseif fade_type == "FADE_OUT" then
        Model:Update("mouseOverFadeOutAmount", amount)
    else
        ---
    end

    if HideUI:FindModule("MouseOver") then
        self:SendMessage("MOUSEOVER_FADE_TIME_UPDATED", fade_type, amount)
    end
end

function Controller:HandleCombatChange(checked) --To Combat
    Model:Update("isCombatEnabled", checked)
    self:ModulesHandler()
end

function Controller:HandleAFKChange(checked) --To AFK
    Model:Update("isAFKEnabled", checked)
    self:ModulesHandler()
end

function Controller:HandleMountChange(checked) --To Mount
    Model:Update("isMountEnabled", checked)
    self:ModulesHandler()
end

function Controller:HandleChatChange(checked) --To Mount
    Model:UpdateChatTable("isAlphaEnabled", checked)
    self:SendMessage("CHAT_STATE_UPDATED", checked)
end

function Controller:HandleChatAlphaAmount(amount) --To FrameManager
    Model:UpdateChatTable("alphaAmount", amount)
    self:SendMessage("CHAT_ALPHA_UPDATED", amount)
end

function HideUI_Enable_Keydown()
    Controller:HandleEnabledChange(not Model:Find("isEnabled"))
    UIMenu:UpdateUI()
end ]]