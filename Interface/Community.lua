local Community = HideUI:NewModule("Community")
local Dispatcher
local Builder
local UIManager
local Data

local MENU_NAME = "Community"
local HEADER = "Third-Party Frames"
local FRAMES = {}
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
}

function Community:OnInitialize()
    Dispatcher = HideUI:GetModule("Dispatcher")
    Builder = HideUI:GetModule("Builder")
    Data = HideUI:GetModule("Data")
    UIManager = HideUI:GetModule("UIManager")
end

function Community:OnEnable()
    self.registry = {}
    self:LoadCommunityFrames()
    self:Draw()
    self:UpdateUI()
end

function Community:OnDisable()
    self.registry = nil
end

function Community:UpdateUI()
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

function Community:OnUpdate(variable, data)
    local frame, setup = strsplit(".", variable)
    local field = MAPPINGS[setup]
    Dispatcher:HandleFrameSettings(frame, field, data)

    if field == "isEnabled" then
        Builder:SetExpandableState(Community.registry, variable, data)
    end
end

function Community:OnDefault()
    Builder:CreatePopupDialog(function(confirm)
        if confirm then
            Dispatcher:HandleRestoreCommunityFrames()
        end
    end)
end

function Community:LoadCommunityFrames()
    FRAMES = {}
    local data = Data:Find("frames")
    for _, frame in pairs(data) do
        if frame.source == "community" then
            table.insert(FRAMES, {name = frame.name, alias = frame.alias or frame.name})
        end
    end
end

function Community:Refresh()
    self.registry = {}
    self:LoadCommunityFrames()
    local index
    local sections = {self.scrollContainer:GetChildren()}
    for _, child_section in ipairs(sections) do
        index = Builder:GetIndex(child_section)
        if index > 1 then
            child_section:Hide()
            child_section:SetParent(nil)
            child_section = nil
        end
    end
    self:InsertSections()
    self:UpdateUI()
end

function Community:OnCommand(command, input, control)
    if command == "add" then
        local result = Dispatcher:OnFrameRegister(input)
        if result then
            Community:Refresh()
            control.SetTextSuccessful("Frame successfully registered.")
        else
            control.SetTextError("Frame not found or already registered.")
        end
    elseif command == "remove" then
        local result = Dispatcher:OnFrameUnregister(input)
        if result then
            Community:Refresh()
            control.SetTextSuccessful("Frame successfully unregistered.")
        else
            control.SetTextError("Frame not found.")
        end
    end
end

function Community:Draw()
    self.subcategory, self.layout, self.frame = Builder:CreateLayoutSubcategory(UIManager.category, MENU_NAME)
    self.categoryHeader = Builder:CreateCategoryHeader(HEADER, self.frame, self.OnDefault)
    self.scrollContainer = Builder:CreateScrollContainer(self.frame, {y = -50})

    local tooltip = {
        name = "Search",
        text = "Search for a frame by its name; you can find it by typing /fstack in the chat."
    }
    self.searchbox = Builder:CreateSearchBox(self.scrollContainer, nil, self.OnCommand, tooltip)
    self:InsertSections()
end

function Community:InsertSections()
    self.before = nil
    for k, frame in ipairs(FRAMES) do
        self:BuildSection(frame.name, frame.alias)
    end

    local a =Builder:CreateSection(nil, "empty", self.scrollContainer, self.before, {h = 50})
end

function Community:BuildSection(frame, header)
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
        self.before = self.searchbox
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

function Community:AttachExtras(frame, defaults, before, section)
    local name
    local variable
    local tooltip
    local settings
    local element

    return element or before
end