local Blizzard = HideUI:NewModule("Blizzard")
local Dispatcher
local Builder
local UIManager
local Data

local MENU_NAME = "Frames"
local HEADER = "Frames"
local BINDINGS = {
    -- Chatbox
    {name = "Chatbox",                             alias = "Chat"},
    -- Frames
    {name = "PlayerFrame",                         alias = "Player"},
    {name = "TargetFrame",                         alias = "Target"},
    {name = "FocusFrame",                          alias = "Focus"},
    {name = "PetFrame",                            alias = "Pet Frame"},
    -- Misc
    {name = "MinimapCluster",                      alias = "Minimap"},
    {name = "ObjectiveTrackerFrame",               alias = "Quests"},
    {name = "BuffFrame",                           alias = "Buffs"},
    {name = "MicroMenuContainer",                  alias = "Menu"},
    {name = "BagsBar",                             alias = "Bags"},
    {name = "BattlefieldMapFrame",                 alias = "Zone Map"},
    {name = "EncounterBar",                        alias = "Dragonriding Bar"},
    {name = "PlayerCastingBarFrame",               alias = "Casting Bar"},
    {name = "MainStatusTrackingBarContainer",      alias = "Tracking Bar"},
    {name = "SecondaryStatusTrackingBarContainer", alias = "Secondary Tracking Bar"},
    {name = "StanceBar",                           alias = "Stance Bar"},
    {name = "PartyFrame",                          alias = "Party Frame"},
    -- {name = "WorldFrame",                   alias = "World Frame"},
    -- Spell Bars
    {name = "MainMenuBar",                         alias = "Action Bar 1"},
    {name = "MultiBarBottomLeft",                  alias = "Action Bar 2"},
    {name = "MultiBarBottomRight",                 alias = "Action Bar 3"},
    {name = "MultiBarRight",                       alias = "Action Bar 4"},
    {name = "MultiBarLeft",                        alias = "Action Bar 5"},
    {name = "MultiBar5",                           alias = "Action Bar 6"},
    {name = "MultiBar6",                           alias = "Action Bar 7"},
    {name = "MultiBar7",                           alias = "Action Bar 8"},
    {name = "PetActionBar",                        alias = "Pet Action Bar"},
    {name = "ZoneAbilityFrame",                    alias = "Zone Action Bar"},
}
local MAPPINGS = {
    enable_checkbox     = "isEnabled",
    mouseover_checkbox  = "isMouseoverEnabled",
    -- alpha_checkbox      = "isAlphaEnabled",
    alpha_slider        = "alphaAmount",
    afk_checkbox        = "isAFKEnabled",
    mount_checkbox      = "isMountEnabled",
    combat_checkbox     = "isCombatEnabled",
    instance_checkbox   = "isInstanceEnabled",
    afk_slider          = "afkAlphaAmount",
    mount_slider        = "mountAlphaAmount",
    combat_slider       = "combatAlphaAmount",
    instance_slider     = "instanceAlphaAmount",
    -- Extras
    text_checkbox       = "isTextModeEnabled",
}

function Blizzard:OnInitialize()
    Dispatcher = HideUI:GetModule("Dispatcher")
    Builder    = HideUI:GetModule("Builder")
    Data       = HideUI:GetModule("Data")
    UIManager  = HideUI:GetModule("UIManager")
end

function Blizzard:OnEnable()
    self.registry = {}
    self:Draw()
    self:UpdateUI()
end

function Blizzard:OnDisable()
    self.registry = nil
end

function Blizzard:UpdateUI()
    local field
    local frame
    local setup
    local data = Data:Find("frames")
    for variable, _ in pairs(self.registry) do
        frame, setup = strsplit(".", variable)
        field = MAPPINGS[setup]
        Builder:SetVariableData(self.registry, variable, data[frame][field])
    end
    -- Segundo recorrido necesario para deshabilitar completamente los checkbox_slider
    for variable, _ in pairs(self.registry) do
        frame, setup = strsplit(".", variable)
        field = MAPPINGS[setup]
        if field == "isEnabled" then
            Builder:SetExpandableState(self.registry, variable, data[frame][field])
        end
    end
end

function Blizzard:OnUpdate(variable, data)
    local frame, setup = strsplit(".", variable)
    local field = MAPPINGS[setup]
    Dispatcher:HandleFrameSettings(frame, field, data)

    if field == "isEnabled" then
        Builder:SetExpandableState(Blizzard.registry, variable, data)
    end
end

function Blizzard:OnDefault()
    Builder:CreatePopupDialog(function(confirm)
        if confirm then
            Dispatcher:HandleRestoreBlizzardFrames()
        end
    end)
end

function Blizzard:TurnOn()
    self.categoryHeader:SetEnable()
    local sections = {self.scrollContainer:GetChildren()}
    for _, child_section in ipairs(sections) do
        child_section:SetEnable()
    end
end

function Blizzard:TurnOff()
    self.categoryHeader:SetDisable()
    local sections = {self.scrollContainer:GetChildren()}
    for _, child_section in ipairs(sections) do
        child_section:SetDisable()
    end
end

function Blizzard:Draw()
    self.subcategory, self.layout, self.frame = Builder:CreateLayoutSubcategory(UIManager.category, MENU_NAME)
    self.categoryHeader = Builder:CreateCategoryHeader(HEADER, self.frame, self.OnDefault)
    self.scrollContainer = Builder:CreateScrollContainer(self.frame, {y = -50})

    for k, frame in ipairs(BINDINGS) do
        self:BuildSection(frame.name, frame.alias)
    end

    Builder:CreateSection(nil, "empty", self.scrollContainer, self.before, {h = 50})
end

function Blizzard:BuildSection(frame, header)
    local section
    local element
    local settings
    local tooltip
    local offset
    local name
    local variable
    local defaults = {data = self.registry, update = self.OnUpdate}

    if self.before then
        offset = -9
    else
        offset = -20
    end

    -- Expandable Section
    section = Builder:CreateSection(header, "expandable", self.scrollContainer, self.before, {y = offset})
    
    -- Enabled
    name      = "Enable " .. frame
    variable  = frame .. ".enable_checkbox"
    tooltip   = "Enable customization for the selected frame."
    settings  = Builder:RegisterSettings({name=name, type="checkbox", variable=variable, tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element, {y = -13})

    -- Mouseover
    name      = "Enable Mouseover"
    variable  = frame .. ".mouseover_checkbox"
    tooltip   = "Enable mouseover reveal for the selected frame."
    settings  = Builder:RegisterSettings({name=name, type="checkbox", variable=variable, tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    -- Alpha
    name      = "Opacity"
    variable  = frame .. ".alpha_slider"
    tooltip   = "Adjust the opacity of the selected frame."
    settings  = Builder:RegisterSettings({name=name, type="slider", variable=variable, tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    -- AFK Event
    name      = "AFK Opacity"
    variable  = frame .. ".afk_checkbox_slider"
    tooltip   = "Adjusts frame opacity when the player is away from keyboard."
    settings  = Builder:RegisterSettings({name=name, type="checkbox_slider", variable=variable, tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    -- Mount Event
    name      = "Mounted Opacity"
    variable  = frame .. ".mount_checkbox_slider"
    tooltip   = "Adjusts frame opacity when the player is on a mount."
    settings  = Builder:RegisterSettings({name=name, type="checkbox_slider", variable=variable, tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    -- Combat Event
    name      = "In-Combat Opacity"
    variable  = frame .. ".combat_checkbox_slider"
    tooltip   = "Customizes frame opacity when entering combat."
    settings  = Builder:RegisterSettings({name=name, type="checkbox_slider", variable=variable, tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    -- Instance Event
    name      = "In-Instance Opacity"
    variable  = frame .. ".instance_checkbox_slider"
    tooltip   = "Adjusts frame opacity when the player is inside an instance."
    settings  = Builder:RegisterSettings({name=name, type="checkbox_slider", variable=variable, tooltip=tooltip}, defaults)
    element   = Builder:AddElementToSection(section, settings, element)

    element = self:AttachExtras(frame, defaults, element, section)

    settings  = Builder:RegisterSettings({type="separator"})
    element   = Builder:AddElementToSection(section, settings, element, {y = -20})

    self.before = section
end

function Blizzard:AttachExtras(frame, defaults, before, section)
    local name
    local variable
    local tooltip
    local settings
    local element
    if frame == "Chatbox" then
        -- Mouseover
        name      = "Enable Text Mode"
        variable  = frame .. ".text_checkbox"
        tooltip   = "Hide the chat box, leaving only the messages visible."
        settings  = Builder:RegisterSettings({name=name, type="checkbox", variable=variable, tooltip=tooltip}, defaults)
        element   = Builder:AddElementToSection(section, settings, before)
    end

    return element
end