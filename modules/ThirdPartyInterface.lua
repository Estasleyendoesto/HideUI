local ThirdPartyInterface = HideUI:NewModule("ThirdPartyInterface")
local Data
local Controller
local AmigableUI

local THIRD_PARTY_SETTINGS_PANEL

local BINDINGS = {}

function ThirdPartyInterface:OnInitialize()
    Data       = HideUI:GetModule("Data")
    Controller = HideUI:GetModule("Controller")
    AmigableUI = HideUI:GetModule("AmigableUI")

    local data = Data:Find("frames")
    for _, frame in pairs(data) do
        if frame.source == "third_party" then
            table.insert(BINDINGS, {name = frame.name})
        end
    end
end

function ThirdPartyInterface:UpdateUI()
    local panel = THIRD_PARTY_SETTINGS_PANEL
    local data = Data:Find("frames")

    for _, frame in pairs(data) do
        if frame.source == "third_party" then
            panel[frame.name].content.panel["isEnabled_checkbox"]:SetChecked(frame.isEnabled)
            panel[frame.name].content.panel["isAlphaEnabled_checkbox"]:SetChecked(frame.isAlphaEnabled)
            panel[frame.name].content.panel["alphaAmount_slider"]:SetValue(frame.alphaAmount)
            panel[frame.name].content.panel["isMouseoverEnabled_checkbox"]:SetChecked(frame.isMouseoverEnabled)
            panel[frame.name].content.panel["isCombatEnabled_checkbox"]:SetChecked(frame.isCombatEnabled)
            panel[frame.name].content.panel["isMountEnabled_checkbox"]:SetChecked(frame.isMountEnabled)
            panel[frame.name].content.panel["isAFKEnabled_checkbox"]:SetChecked(frame.isAFKEnabled)
            panel[frame.name].content.panel["isInstanceEnabled_checkbox"]:SetChecked(frame.isInstanceEnabled)

            if frame.isEnabled then
                panel[frame.name]:SetBackdropBorderColor(1, 1, 0, 0.5)
            end
        end
    end
end

function ThirdPartyInterface:Menu_Build(panel)
    THIRD_PARTY_SETTINGS_PANEL = panel

    -- Reset pool
    AmigableUI.poolContainer = nil

    -- Panel
    AmigableUI:ScrollBox("panel_scroll", THIRD_PARTY_SETTINGS_PANEL, true)
    AmigableUI:Header("panel_header", "Third Party Settings")

    -- Third Party Editor
    AmigableUI:Title("title_editor", "Manager")
    
    AmigableUI:ThirdPartyEditor("panel_editor", function(action, captured)
        -- Si no hay texto, exit
        if captured == "" then return end

        -- Si no existe el frame, exit
        local frame = _G[captured]
        if frame == nil then return end

        -- Si existe...
        local data = Data:Find("frames")
        local third = data[captured]

        if action == "add" and not third then
            Controller:RegisterFrame(captured)
            -- data[captured] = {
            --     name = captured,
            --     source = "third_party",
            --     alphaAmount = 0.5,
            --     isEnabled = false,
            --     isAlphaEnabled = false,
            --     isCombatEnabled = true,
            --     isAFKEnabled = true,
            --     isMountEnabled = true,
            --     isMouseoverEnabled = true,
            --     isInstanceEnabled = true,
            -- }

            AmigableUI:Pool(captured, captured, 270)
            self:AttachSettings(captured)
            self:UpdateUI()

            -- if not frame.HideUI then
            --     local globals = Data:Find("globals")
            --     frame.HideUI = FrameTemplate:Create(frame, data[captured], globals)
            --     frame.HideUI:OnReady()
            -- end
        elseif action == "remove" and third and third.source == "third_party" then
            -- frame.HideUI:OnDestroy()
            -- frame.HideUI = nil
            -- data[captured] = nil
            Controller:UnregisterFrame(captured)

            local section = panel[captured]
            section:SetBackdropBorderColor(1, 1, 1, 0.2)
            section:SetBackdropColor(0.5, 0.5, 0.5, 0.1)

            section.header:SetText("Deleted")
            section.header:SetTextColor(1, 1, 1, 0.4)
            section.icon:Hide()
            section.content:Show()
            section.content:ToggleAccordion()
            section.content.parent:SetScript("OnMouseDown", nil)
        end
    end)
    
    AmigableUI:Title("title_frames", "Registry")

    -- Frame Settings
    for _, frame in ipairs(BINDINGS) do
        AmigableUI:Pool(frame.name, frame.name, 270)
        self:AttachSettings(frame.name)
    end
end

function ThirdPartyInterface:AttachSettings(frame)
    local pool = AmigableUI.lastElement

    AmigableUI:Checkbox("isEnabled_checkbox", "Custom Enabled", false, function(e)
        Controller:HandleFrameSettings(frame, "isEnabled", e)
        if e then
            pool:SetBackdropBorderColor(1, 1, 0, 0.5)
        else
            pool:SetBackdropBorderColor(1, 1, 1, 0.5)
        end
    end)
    AmigableUI:Checkbox("isAlphaEnabled_checkbox", "Custom Alpha", false, function(e) Controller:HandleFrameSettings(frame, "isAlphaEnabled", e) end)
    AmigableUI:Slider("alphaAmount_slider", "Alpha Amount", 0, 1, 0.5, 0.01, function(e) Controller:HandleFrameSettings(frame, "alphaAmount", e) end)
    AmigableUI:Checkbox("isMouseoverEnabled_checkbox", "Reveal on Mouseover", false, function(e) Controller:HandleFrameSettings(frame, "isMouseoverEnabled", e) end)
    AmigableUI:Checkbox("isCombatEnabled_checkbox", "Reveal on Combat", false, function(e) Controller:HandleFrameSettings(frame, "isCombatEnabled", e) end)
    AmigableUI:Checkbox("isAFKEnabled_checkbox", "Hide on AFK", false, function(e) Controller:HandleFrameSettings(frame, "isAFKEnabled", e) end)
    AmigableUI:Checkbox("isMountEnabled_checkbox", "Hide on Mount", false, function(e) Controller:HandleFrameSettings(frame, "isMountEnabled", e) end)
    AmigableUI:Checkbox("isInstanceEnabled_checkbox", "Reveal on Instance", false, function(e) Controller:HandleFrameSettings(frame, "isInstanceEnabled", e) end)

    AmigableUI.lastElement = pool
end