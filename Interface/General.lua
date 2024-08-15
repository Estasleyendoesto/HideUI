local General = HideUI:NewModule("General")
local Builder
local Menu
local Data

local MENU_NAME = "General"

function General:OnInitialize()
    Builder = HideUI:GetModule("Builder")
    Menu = HideUI:GetModule("Menu")
    Data = HideUI:GetModule("Data")
end

function General:OnEnable()
    self.registry = {}
    self:Draw()
    self:UpdateUI()
end

function General:OnDisable()
    self.registry = nil
end

function General:UpdateUI()
    -- Builder:SetVariableData(self.registry, "enabled", true)
    -- Builder:SetVariableData(self.registry, "slider", 0.85)
end

function General:OnDefault()
    print("Mostrar cuadro de aviso con aceptar/cancelar y reestablecer")
end

function General:OnUpdate(var_name, data)
    print(var_name, data)
end

function General:Draw()
    self.subcategory, self.layout, self.frame = Builder:CreateLayoutSubcategory(Menu.category, MENU_NAME)
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
    transform = {y = -11}
    section   = Builder:CreateSection(nil, "empty", self.scrollContainer, nil, transform)

    -- Vertical offset for all elements
    yOffset   = -5
    transform = {y = yOffset}

    -- Character-specific
    tooltip   = "Enable to make changes character-specific settings."
    settings  = Builder:RegisterSettings({name="Character-specific", type="checkbox", variable="character_checkbox", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings)
    
    -- Enabled
    tooltip   = "Toggle the addon's full functionality. Ideal for resetting in case of erratic behavior. Bind a key in Keybinds -> Addons."
    settings  = Builder:RegisterSettings({name="Enable HideUI", type="checkbox", variable="enable_checkbox", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, transform)

    -- Mouseover
    tooltip   = "Toggle frame reveal on mouseover for all frames."
    settings  = Builder:RegisterSettings({name="Enable Mouseover", type="checkbox", variable="mouseover_checkbox", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, transform)

    --Fade duration
    settings  = Builder:RegisterSettings({name="Fade In Duraction", type="slider", variable="fadeIn_slider", max=2, unit="s"}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, transform)

    settings  = Builder:RegisterSettings({name="Fade Out Duraction", type="slider", variable="fadeOut_slider", max=2, unit="s"}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, transform)
    
    --AFk Event
    tooltip   = "Adjusts global opacity when the player is away from keyboard."
    settings  = Builder:RegisterSettings({name="AFK Opacity", type="checkbox_slider", variable="afk_checkbox_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, transform)

    --Mount Event
    tooltip   = "Adjusts global opacity when the player is on a mount."
    settings  = Builder:RegisterSettings({name="Mounted Opacity", type="checkbox_slider", variable="mount_checkbox_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, transform)

    --Combat Event
    tooltip   = "Customizes global opacity when entering combat."
    settings  = Builder:RegisterSettings({name="In-Combat Opacity", type="checkbox_slider", variable="combat_checkbox_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, transform)

    --Instance Event
    tooltip   = "Adjusts global opacity when the player is inside an instance."
    settings  = Builder:RegisterSettings({name="In-Instance Opacity", type="checkbox_slider", variable="instance_checkbox_slider", tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, transform)
end