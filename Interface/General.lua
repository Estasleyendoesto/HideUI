local General = HideUI:NewModule("General")
local Dispatcher
local Builder
local UIManager
local Data

local MENU_NAME = "General"
local MAPPINGS = {
    character_checkbox = "isCharacter",
    enable_checkbox = "isEnabled",
    mouseover_checkbox = "isMouseoverEnabled",
    fadeIn_slider = "mouseoverFadeInDuration",
    fadeOut_slider = "mouseoverFadeOutDuration",
    opacity_slider = "alphaAmount",
    afk_checkbox = "isAFKEnabled",
    mount_checkbox = "isMountEnabled",
    combat_checkbox = "isCombatEnabled",
    instance_checkbox = "isInstanceEnabled",
    afk_slider = "afkAlphaAmount",
    mount_slider = "mountAlphaAmount",
    combat_slider = "combatAlphaAmount",
    instance_slider = "instanceAlphaAmount",
    postcombat_slider = "combatEndDelay"
}

function General:OnInitialize()
    Dispatcher = HideUI:GetModule("Dispatcher")
    Builder = HideUI:GetModule("Builder")
    Data = HideUI:GetModule("Data")
    UIManager = HideUI:GetModule("UIManager")
end

function General:OnEnable()
    self.registry = {}
    self:Draw()
end

function General:OnDisable()
    self.registry = nil
end

function General:UpdateUI()
    local globals = Data:Find("globals")
    for variable, data in pairs(MAPPINGS) do
        Builder:SetVariableData(self.registry, variable, globals[data])
    end
end

function General:OnUpdate(variable, data)
    local mapping = MAPPINGS[variable]
    local is_enable = variable == "enable_checkbox"
    local is_character = variable == "character_checkbox"
    if is_enable then
        Dispatcher:HandleEnabledChange(data)
    elseif is_character then
        Builder:CreatePopupDialog(function(confirm)
            if confirm then
                Dispatcher:HandleProfileChange(data)
            else
                Builder:SetVariableData(General.registry, "character_checkbox", not data)
            end
        end)
    else
        Dispatcher:HandleGlobalSettings(mapping, data)
    end
end

function General:OnDefault()
    Builder:CreatePopupDialog(function(confirm)
        if confirm then
            Dispatcher:HandleRestoreGlobals()
        end
    end)
end

function General:TurnOn()
    self.categoryHeader:SetEnable()
    local section = self.scrollContainer:GetChildren()
    local children = {section.Container:GetChildren()}
    local frame = Builder:GetElementByVariable("enable_checkbox")
    for _, child_element in ipairs(children) do
        if child_element ~= frame then
            child_element:SetEnable()
        end
    end
end

function General:TurnOff()
    self.categoryHeader:SetDisable()
    local section = self.scrollContainer:GetChildren()
    local children = {section.Container:GetChildren()}
    local frame = Builder:GetElementByVariable(self.registry, "enable_checkbox")
    for _, child_element in ipairs(children) do
        if child_element ~= frame then
            child_element:SetDisable()
        end
    end
end

function General:Draw()
    self.subcategory, self.layout, self.frame = Builder:CreateLayoutSubcategory(UIManager.category, MENU_NAME)
    self.categoryHeader = Builder:CreateCategoryHeader(MENU_NAME, self.frame, self.OnDefault)
    self.scrollContainer = Builder:CreateScrollContainer(self.frame, {y = -50})

    local section
    local element
    local settings
    local transform
    local tooltip
    local yOffset
    local defaults = {data = self.registry, update = self.OnUpdate}

    -- Empty section
    transform = {y = -6}
    section   = Builder:CreateSection(nil, "empty", self.scrollContainer, nil, transform)

    -- Character-specific
    tooltip   = "Enable to apply changes to character-specific settings. Disable to revert to shared settings."
    settings  = Builder:RegisterSettings({name="Character-specific", type="checkbox", variable="character_checkbox", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings)
    
    -- Enabled
    tooltip   = "Toggle the addon's full functionality. Ideal for resetting in case of erratic behavior or as a replacement for Ctrl + Z. You can bind a key in Keybinds -> Addons."
    settings  = Builder:RegisterSettings({name="Enable HideUI", type="checkbox", variable="enable_checkbox", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    -- Mouseover
    tooltip   = "Toggle frame visibility on mouseover for all frames."
    settings  = Builder:RegisterSettings({name="Enable Mouseover", type="checkbox", variable="mouseover_checkbox", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    --Fade duration
    settings  = Builder:RegisterSettings({name="Fade In Duration", type="slider", variable="fadeIn_slider", max=2, unit="s"}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    settings  = Builder:RegisterSettings({name="Fade Out Duration", type="slider", variable="fadeOut_slider", max=2, unit="s"}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    --Global Opacity
    tooltip   = "Adjusts the overall opacity for all frames."
    settings  = Builder:RegisterSettings({name="Global Opacity", type="slider", variable="opacity_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    --AFk Event
    tooltip   = "Adjusts the global opacity when the player is away from the keyboard."
    settings  = Builder:RegisterSettings({name="AFK Opacity", type="checkbox_slider", variable="afk_checkbox_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    --Mount Event
    tooltip   = "Adjusts the global opacity when the player is mounted."
    settings  = Builder:RegisterSettings({name="Mounted Opacity", type="checkbox_slider", variable="mount_checkbox_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    --Combat Event
    tooltip   = "Adjusts global opacity upon entering combat."
    settings  = Builder:RegisterSettings({name="In-Combat Opacity", type="checkbox_slider", variable="combat_checkbox_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    --Instance Event
    tooltip   = "Adjusts global opacity while the player is inside an instance."
    settings  = Builder:RegisterSettings({name="In-Instance Opacity", type="checkbox_slider", variable="instance_checkbox_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    -- Combat End Delay
    tooltip   = "Delay before the interface begins changing opacity after combat ends."
    settings  = Builder:RegisterSettings({name="Post-Combat Fade Delay", type="slider", variable="postcombat_slider", tooltip=tooltip, max=2, unit="s"}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)
end