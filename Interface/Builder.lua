
local Builder = HideUI:NewModule("Builder")

function Builder:OnInitialize()
end

function Builder:OnEnable()
end

-----------------------------------------------------------------
-- Documentación Importante
-----------------------------------------------------------------
-- https://www.townlong-yak.com/framexml/beta/Blizzard_Settings_Shared/Blizzard_SettingControls.xml
-- https://www.townlong-yak.com/framexml/beta/Blizzard_Settings_Shared/Blizzard_SettingControls.lua

-----------------------------------------------------------------
-- Utils
-----------------------------------------------------------------
function Builder:CreateTransform(args)
    args = args or {}
    local x = args.x or 0
    local y = args.y or 0
    local w = args.w or 1
    local h = args.h or 1

    return {x=x, y=y, w=w, h=h}
end

function Builder:GetLastElement(container)
    local children = {container:GetChildren()}
    local lastChild

    for _, child in ipairs(children) do
        child.index = child.index or 0
        if not lastChild or child.index > lastChild.index then
            lastChild = child
        end
    end

    if lastChild then
        return lastChild.index, lastChild
    else
        return 0
    end
end

function Builder:SetIndex(frame)
    local parent = frame:GetParent()
    frame.index = self:GetLastElement(parent) + 1
    return frame.index
end

function Builder:GetIndex(frame)
    return frame.index or 0
end

function Builder:CalculateWidth(frame, noSet)
    local parent = frame:GetParent()
    local width = parent:GetWidth()

    noSet = noSet or false
    if not noSet then
        frame:SetWidth(width)
        if frame.Container then
            frame.Container:SetWidth(width)
        end
    end

    return width
end

function Builder:CalculateHeight(frame, noSet)
    local height = 0
    local extra  = 0
    local total

    if frame.Header then
        local _, _, _, _, offsetY = frame.Header:GetPoint()
        extra = math.abs(offsetY) + frame.Header:GetHeight() + extra
    end
    if frame.Button then
        local _, _, _, _, offsetY = frame.Button:GetPoint()
        extra = math.abs(offsetY) + frame.Button:GetHeight() + extra
    end
    if frame.Container then
        local children = {frame.Container:GetChildren()}
        for _, child in ipairs(children) do
            local _, _, _, _, offsetY = child:GetPoint()
            height = math.abs(offsetY) + child:GetHeight() + height
        end
    end

    total = height + extra

    noSet = noSet or false
    if not noSet then
        frame:SetHeight(total)
        if frame.Container then
            frame.Container:SetHeight(height)
        end
    end

    return total, height, extra
end

function Builder:GetNextChild(frame)
    local container = frame:GetParent()
    local children = {container:GetChildren()}
    local index = self:GetIndex(frame)
    for _, child in ipairs(children) do
        local childIndex = self:GetIndex(child)
        if (index + 1) == childIndex then
            return child
        end
    end

    return nil --No hay siguiente...
end

function Builder:FixTo(frame, relativeTo, transform)
    frame:ClearAllPoints()
    transform = self:CreateTransform(transform)
    if relativeTo then
        frame:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", transform.x, transform.y)
    else
        frame:SetPoint("TOPLEFT", transform.x, transform.y)
    end
end

function Builder:Debug(frame, channel)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(channel.r or 0, channel.g or 0, channel.b or 0, 0.25)
    frame.bg = bg
end

function Builder:Unpack(tbl)
    local unpack = table.unpack or unpack --Compatibilidad
    return unpack(tbl)
end

function Builder:RegisterVariable(tbl, variable_name, element)
    tbl[variable_name] = element
end

function Builder:SetVariableData(tbl, variable_name, data)
    local frame = tbl[variable_name]
    local name  = frame:GetName()

    if name == "HideUICheckboxSlider" then
        if type(data) == "number" then
            frame.Sliderbox.Slider:SetValue(data)
        elseif type(data) == "boolean" then
            frame.Checkbox:SetChecked(data)
        end
    elseif name == "HideUICheckbox" then
        frame.Checkbox:SetChecked(data)
    elseif name == "HideUISlider" then
        frame.Sliderbox.Slider:SetValue(data)
    end
end

function Builder:GetVariableData(tbl, var_name)
    local frame = tbl[var_name]
    local name  = frame:GetName()

    if name == "HideUICheckbox" then
        return frame.Checkbox:GetChecked()
    elseif name == "HideUISlider" then
        return frame.SliderFrame.Slider:GetValue()
    elseif name == "HideUICheckboxSlider" then
        return frame.Checkbox:GetChecked(), frame.SliderFrame.Slider:GetValue()
    end

    return nil
end

-----------------------------------------------------------------
-- Subcategory
-----------------------------------------------------------------
function Builder:CreateLayoutSubcategory(category, name)
    local frame = CreateFrame("Frame", "HideUI" .. name .. "Frame", UIParent)
    local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, frame, name)
    frame.name = name
    return subcategory, layout, frame
end

-----------------------------------------------------------------
-- Scroll
-----------------------------------------------------------------
function Builder:CreateScrollContainer(parent, transform, fill)
    local scrollFrame = CreateFrame("ScrollFrame", "HideUIScroll", parent, "HideUIScrollFrameTemplate")

    transform = self:CreateTransform(transform)
    scrollFrame:SetPoint("TOPLEFT", transform.x, transform.y)

    fill = fill or true
    if fill then
        scrollFrame:SetPoint("BOTTOMRIGHT")
    end

    local scrollChild = scrollFrame:GetScrollChild()

    --Lo único que se me ocurre para este calvario...
    local width = UIParent:GetWidth() * 0.344

    scrollChild:SetSize(width, 1)
    scrollChild:SetPoint("TOPLEFT")
    scrollChild:SetPoint("BOTTOMRIGHT")

    return scrollChild, scrollFrame
end

-----------------------------------------------------------------
-- Header
-----------------------------------------------------------------
function Builder:CreateCategoryHeader(name, parent, func)
    local headerFrame = CreateFrame("Frame", "HideUIHeader", parent, "HideUIHeaderTemplate")
    headerFrame:SetHeight(50)
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetPoint("TOPRIGHT")

    headerFrame.Header.Title:SetText(name)
    headerFrame.Header.DefaultsButton:SetText("Defaults")
    headerFrame.Header.DefaultsButton:SetScript("OnClick", func)
end

-----------------------------------------------------------------
-- Sections
-----------------------------------------------------------------
function Builder:CreateSection(name, type, parent, relativeTo, transform)
    local section
    
    if type == "empty" then
        section = self:CreateEmptySection(parent, relativeTo, transform)
    elseif type == "header" then
        section = self:CreateHeaderSection(name, parent, relativeTo, transform)
    elseif type == "expandable" then
        section = self:CreateExpandableSection(name, parent, relativeTo, transform)
    end

    return section
end

function Builder:CreateEmptySection(parent, relativeTo, transform)
    local section = CreateFrame("Frame", "HideUIEmptySection", parent, "HideUIEmptySectionTemplate")
    self:CalculateWidth(section)
    self:CalculateHeight(section)
    self:SetIndex(section)
    self:FixTo(section, relativeTo, transform)

    if transform and transform.h then
        section:SetHeight(transform.h)
    end

    return section
end

function Builder:CreateHeaderSection(name, parent, relativeTo, transform)
    local section = CreateFrame("Frame", "HideUISection", parent, "HideUISectionTemplate")
    self:CalculateWidth(section)
    self:CalculateHeight(section)
    self:SetIndex(section)
    self:FixTo(section, relativeTo, transform)

    section.Header.Title:SetText(name)

    return section
end

function Builder:CreateExpandableSection(name, parent, relativeTo, transform)
    local section = CreateFrame("Frame", "HideUIExpandableSection", parent, "HideUIExpandableSectionTemplate")
    self:CalculateWidth(section)
    self:CalculateHeight(section)
    self:SetIndex(section)
    self:FixTo(section, relativeTo, transform)

    -- Container Visibility
    section.HideContainer = function()
        local height = section:GetHeight() - section.Container:GetHeight()
        section:SetHeight(height)
        section.Container:SetHeight(0)
        section.Container:Hide()
    end
    section.ShowContainer = function()
        self:CalculateHeight(section)
        section.Container:Show()
    end

    section.Button.Text:SetText(name)

    -- Expanded function
    section.Button.expanded = false
    section.Button:SetScript("OnClick", function(button)
        button.expanded = not button.expanded
        self:OnExpandedChange(section, button.expanded)
    end)

    return section
end

function Builder:OnExpandedChange(section, expanded)
    local button = section.Button
    if expanded then
        section:ShowContainer()
        button.Right:SetAtlas("Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize)
    else
        section:HideContainer()
        button.Right:SetAtlas("Options_ListExpand_Right", TextureKitConstants.UseAtlasSize)
    end
end

-----------------------------------------------------------------
-- Quick Elements
-----------------------------------------------------------------
function Builder:RegisterSettings(args, defaults)
    local settings = {}
    for k, v in pairs(defaults or {}) do
        settings[k] = v
    end
    for k, v in pairs(args) do
        settings[k] = v
    end

    return settings
end

function Builder:AddElementToSection(section, settings, relativeTo, transform)
    local element
    local container = section.Container
    local slider_settings = {
        default = settings.slider_default,
        step = settings.step,
        min = settings.min,
        max = settings.max,
        unit = settings.unit
    }
    
    local update = function(element, data)
        self:SetVariableData(settings.data, settings.variable, data)
        settings.update(nil, settings.variable, data) --nil -> evita el self
    end
    
    if settings.type == "checkbox" then
        element = self:CreateCheckbox(settings.name, container, relativeTo, transform, update, settings.tooltip, settings.default)
    elseif settings.type == "slider" then
        local default = settings.default or settings.slider_default
        element = self:CreateSlider(settings.name, container, relativeTo, transform, update, settings.tooltip, slider_settings)
    elseif settings.type == "checkbox_slider" then
        element = self:CreateCheckboxSlider(settings.name, container, relativeTo, transform, update, settings.tooltip, settings.default, slider_settings)
    end

    self:CalculateHeight(section)
    self:RegisterVariable(settings.data, settings.variable, element)

    return element
end

-----------------------------------------------------------------
-- Tooltip
-----------------------------------------------------------------
function Builder:CreateTooltip(frame, name, text)
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(name, 1, 1, 1)

        if text then
            GameTooltip:AddLine(text, 1, 0.84, 0, true)
        end

        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-----------------------------------------------------------------
-- Checkbox
-----------------------------------------------------------------
function Builder:CreateCheckbox(name, parent, relativeTo, transform, update, tooltip, default, frame_name)
    default = default or false
    update  = update or function() end
    frame_name = frame_name or "HideUICheckbox"

    -- Checkbox Container
    local control = CreateFrame("Frame", frame_name, parent, "HideUICheckboxControlTemplate")
    self:SetIndex(control)
    self:FixTo(control, relativeTo, transform)

    -- Checkbox text
    control.Text:SetText(name)
    control.Text:SetPoint("LEFT", control, "LEFT", 45, 0)
    control.Text:SetWidth(200)
    control.Text:SetMaxLines(1)
    control.Text:SetNonSpaceWrap(false)

    -- Checkbox button
    local checkbox = CreateFrame("CheckButton", nil, control, "HideUICheckboxTemplate")
    checkbox:SetPoint("LEFT", parent, "CENTER", -85, 0)
    checkbox:SetPoint("TOP", control, "TOP", 0, 0)
    checkbox:SetChecked(default)
    checkbox:SetScript("OnClick", function() update(checkbox, checkbox:GetChecked()) end)

    -- Tooltip
    self:CreateTooltip(control.Text, name, tooltip)

    control.Checkbox = checkbox
    return control
end

-----------------------------------------------------------------
-- Slider
-----------------------------------------------------------------
function Builder:SliderSettingsInitializer(args)
    local default = args.default or 1
    local step = args.step or 0.01
    local min = args.min or 0
    local max = args.max or 1
    local unit = args.unit or "%"

    return {default, step, min, max, unit}
end

function Builder:CreateSliderbox(control, update, default, step, min, max, unit)
    local parent = control:GetParent()

    --Slider frame
    local sliderbox = CreateFrame("Frame", nil, control, "HideUISliderTemplate")
    sliderbox:SetPoint("LEFT", parent, "CENTER", -85, 0)
    sliderbox:SetPoint("TOP", control, "TOP", 0, 0)

    sliderbox.DefineText = function(text, value)
        if text == "%" then
            value = value * 100
            text = string.format("%.0f", value) .. text
        else
            text = string.format("%.1f", value) .. text
        end
        sliderbox.RightText:SetText(text)
        return text
    end
        
    local text = sliderbox.RightText
    if text then
        sliderbox.DefineText(unit, default)
        text:Show()
    end

    --Slider
    local slider = sliderbox.Slider
    if slider then
        slider:SetMinMaxValues(min, max)
        slider:SetValue(default) --Usar esto para actualizar su valor
        slider:SetValueStep(step)
        slider:SetScript("OnValueChanged", function(slider, value)
            sliderbox.DefineText(unit, value)
            update(slider, value)
        end)
    end

    --Slider Arrows
    local backButton = sliderbox.Back
    if backButton then
        backButton:SetScript("OnClick", function()
            local currentValue = slider:GetValue()
            slider:SetValue(currentValue - step)
            sliderbox.DefineText(unit, slider:GetValue())
        end)
    end

    local forwardButton = sliderbox.Forward
    if forwardButton then
        forwardButton:SetScript("OnClick", function()
            local currentValue = slider:GetValue()
            slider:SetValue(currentValue + step)
            sliderbox.DefineText(unit, slider:GetValue())
        end)
    end

    return sliderbox
end

function Builder:CreateSlider(name, parent, relativeTo, transform, update, tooltip, slider_settings)
    update = update or function() end
    slider_settings = self:SliderSettingsInitializer(slider_settings)

    --Slider Container
    local control = CreateFrame("Frame", "HideUISlider", parent, "HideUISliderControlTemplate")
    self:SetIndex(control)
    self:FixTo(control, relativeTo, transform)

    --Slider Text
    control.Text:SetText(name)
    control.Text:SetPoint("LEFT", control, "LEFT", 45, 0)
    control.Text:SetWidth(201)
    control.Text:SetMaxLines(1)
    control.Text:SetNonSpaceWrap(false)

    --Slider Controller
    local sliderbox = self:CreateSliderbox(
        control,
        update,
        self:Unpack(slider_settings)
    )

    -- Tooltip
    self:CreateTooltip(control.Text, name, tooltip)

    control.Sliderbox = sliderbox
    return control
end

-----------------------------------------------------------------
-- Checkbox Slider
-----------------------------------------------------------------
function Builder:CreateCheckboxSlider(name, parent, relativeTo, transform, update, tooltip, checkbox_default, slider_settings)
    local frame_name = "HideUICheckboxSlider"
    update = update or function() end
    slider_settings = self:SliderSettingsInitializer(slider_settings)
    
    local checkbox_update = function(checkbox, checked)
        local sliderbox = checkbox:GetParent().Sliderbox
        if checked then
            sliderbox:SetEnable()
        else
            sliderbox:SetDisable()
        end
        update(checkbox, checked)
    end

    local control = self:CreateCheckbox(name, parent, relativeTo, transform, checkbox_update, tooltip, checkbox_default, frame_name)
    control:SetWidth(545)

    local sliderbox = self:CreateSliderbox(control, update, self:Unpack(slider_settings))
    sliderbox:ClearAllPoints()
    sliderbox:SetPoint("LEFT", parent, "CENTER", -50, 0)
    sliderbox:SetPoint("TOP", control, "TOP", 0, 0)
    sliderbox:SetWidth(215)

    sliderbox.SetEnable = function(self)
        self:SetAlpha(1)
        self.Slider:Enable()
        self.Slider:SetAlpha(1)
    end

    sliderbox.SetDisable = function(self)
        self:SetAlpha(0.4)
        self.Slider:Disable()
        self.Slider:SetAlpha(0.4)
    end

    if checkbox_default then
        sliderbox:SetEnable()
    else
        sliderbox:SetDisable()
    end

    control.Sliderbox = sliderbox
    return control
end